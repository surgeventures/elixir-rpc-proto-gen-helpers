defmodule RPCProtoGenHelpers.CLI do
  @moduledoc false

  require Logger

  defmodule EExHelper do
    require EEx

    EEx.function_from_file(:def, :rpc_client_behaviour, "behaviour.eex", [
      :module_root,
      :methods
    ])

    EEx.function_from_file(:def, :rpc_client_impl, "impl.eex", [
      :module_root,
      :methods
    ])
  end

  def main(["--version"]) do
    {:ok, version} = :application.get_key(:rpc_proto_gen_helpers, :vsn)
    IO.puts(to_string(version))
  end

  def main([opt]) when opt in ["--help", "-h"] do
    IO.puts("""
    protoc plugin for generating RPC helpers: a behaviour module and an "impl" module for each RPC service.

    See `protoc -h` for details.
    NOTICE: protoc-gen-elixir-rpc (this name is important) must be in $PATH

    If using buf, specify the plugin name as elixir-rpc.

    protoc examples:
      $ protoc --elixir_out=./lib your.proto
      $ protoc --elixir_out=plugins=grpc:./lib/ *.proto
      $ protoc -I protos --elixir_out=./lib protos/namespace/*.proto

    Options:
    --version       Print version of rpc_proto_gen_helpers
    """)
  end

  def main(_) do
    # https://groups.google.com/forum/#!topic/elixir-lang-talk/T5enez_BBTI
    :io.setopts(:standard_io, encoding: :latin1)

    # Binary parsing logic adapted from `protobuf` CLI logic
    # https://github.com/elixir-protobuf/protobuf/blob/v0.7.1/lib/protobuf/protoc/cli.ex
    bin = IO.binread(:all)
    request = Protobuf.Decoder.decode(bin, Google.Protobuf.Compiler.CodeGeneratorRequest)

    files =
      request.proto_file
      |> Stream.filter(&rpc_service?/1)
      |> Stream.reject(&package_in_excluded_packages?(&1, request.parameter))
      |> Stream.map(&build_service_metadata/1)
      |> Enum.flat_map(fn metadata ->
        [
          %Google.Protobuf.Compiler.CodeGeneratorResponse.File{
            name: metadata.behaviour_path,
            content: metadata.behaviour_module
          },
          %Google.Protobuf.Compiler.CodeGeneratorResponse.File{
            name: metadata.impl_path,
            content: metadata.impl_module
          }
        ]
      end)

    response = %Google.Protobuf.Compiler.CodeGeneratorResponse{
      file: files,
      supported_features: Google.Protobuf.Compiler.CodeGeneratorResponse.Feature.value(:FEATURE_PROTO3_OPTIONAL)
    }

    IO.binwrite(Protobuf.Encoder.encode(response))
  end

  # Assume 1 package per service
  defp rpc_service?(%Google.Protobuf.FileDescriptorProto{service: [_]}), do: true
  defp rpc_service?(%Google.Protobuf.FileDescriptorProto{service: _}), do: false

  defp build_service_metadata(%Google.Protobuf.FileDescriptorProto{
         name: file_path,
         package: package,
         service: [
           %Google.Protobuf.ServiceDescriptorProto{name: service_name, method: methods}
         ],
         source_code_info: %Google.Protobuf.SourceCodeInfo{
           location: source_code_locations
         }
       }) do
    package_components = package |> String.split(".")
    package_to_pascal = package_components |> Enum.map_join(".", &Recase.to_pascal/1)
    module_root = "#{package_to_pascal}.#{service_name}"
    file_name = file_path |> Path.basename() |> Path.rootname()

    comment_map = extract_comments(source_code_locations)

    methods =
      methods
      |> Enum.with_index()
      |> Enum.map(fn {method, method_index} ->
        %{
          name: Recase.to_snake(method.name),
          request: extract_request(method),
          response: extract_response(method),
          comments: comment_map[method_index]
        }
      end)

    behaviour_module = EExHelper.rpc_client_behaviour(module_root, methods)
    impl_module = EExHelper.rpc_client_impl(module_root, methods)

    dir_path = Path.dirname(file_path)

    behaviour_path = Path.join(dir_path, "#{file_name}_client_behaviour.ex")

    impl_path = Path.join(dir_path, "#{file_name}_client_impl.ex")

    %{
      behaviour_path: behaviour_path,
      behaviour_module: behaviour_module,
      impl_path: impl_path,
      impl_module: impl_module
    }
  end

  defp extract_comments(source_code_locations) do
    source_code_locations
    |> Enum.reduce(%{}, &extract_comment/2)
    |> Enum.map(fn {index, comments} ->
      {index, comments |> Enum.reverse() |> join_and_format_comments}
    end)
    |> Map.new()
  end

  # Assume we can't have leading + trailing in same block
  defp extract_comment(
         %Google.Protobuf.SourceCodeInfo.Location{
           # This path extraction might seem arbitrary, but see
           # https://groups.google.com/g/protobuf/c/AyOQvhtwvYc?pli=1 and
           # https://github.com/protocolbuffers/protobuf/blob/5b32936822e64b796fa18fcff53df2305c6b7686/src/google/protobuf/descriptor.proto#L1125
           # for more explanation. The TL;DR is:
           # 6 - service field
           # 0 - first service (i.e. RPCService)
           # 2 - method field
           # index - the index of that method
           # This means we only extract comments before each method, and not for imports etc.
           path: [6, 0, 2, method_index],
           leading_comments: leading_comment,
           trailing_comments: nil
         },
         comments
       )
       when is_binary(leading_comment) do
    add_comment(comments, method_index, leading_comment)
  end

  defp extract_comment(
         %Google.Protobuf.SourceCodeInfo.Location{
           path: [6, 0, 2, method_index],
           leading_comments: nil,
           trailing_comments: trailing_comment
         },
         comments
       )
       when is_binary(trailing_comment) do
    add_comment(comments, method_index, trailing_comment)
  end

  defp extract_comment(%Google.Protobuf.SourceCodeInfo.Location{}, comments) do
    comments
  end

  # There may be more than one comment block per method
  defp add_comment(comments, method_index, comment) do
    Map.update(comments, method_index, [comment], &[comment | &1])
  end

  defp join_and_format_comments(comments = [_ | _]) do
    Enum.map_join(comments, "\n\n  ", fn str ->
      str |> String.trim() |> String.replace(~r|(\n +)|, "\n  ")
    end)
  end

  # These will be like ".rpc.deals.v1alpha1.ApplyDealRequest"
  defp extract_request(%{input_type: "." <> req}), do: dotted_path_to_pascal(req)
  defp extract_response(%{output_type: "." <> res}), do: dotted_path_to_pascal(res)

  defp dotted_path_to_pascal(str) do
    str |> String.split(".") |> Enum.map_join(".", &Recase.to_pascal/1)
  end

  defp package_in_excluded_packages?(
         %Google.Protobuf.FileDescriptorProto{package: package},
         parameter
       ) do
    keys_and_values = Regex.scan(~r/(\w+)=(.*?)(?=,\w+=|$)/, parameter, capture: :all_but_first)

    keys_and_values
    |> Enum.any?(fn
      ["exclude_packages", excluded_packages] ->
        package in String.split(excluded_packages, ",")

      _ ->
        false
    end)
  end
end
