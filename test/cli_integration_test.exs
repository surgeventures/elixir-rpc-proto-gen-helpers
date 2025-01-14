defmodule RPCProtoGenHelpers.CLITest do
  use ExUnit.Case

  describe "generates Elixir helper modules" do
    setup :tmp_dir

    test "legacy style package - impl and behaviour modules are generated correctly", %{
      tmp_dir: tmp_dir
    } do
      rpc_path = Path.join(tmp_dir, "rpc/gift_cards/v1")
      File.mkdir_p!(rpc_path)

      service_proto = """
      syntax = "proto3";

      package rpc.gift_cards.v1;

      import "rpc/gift_cards/v1/initialise_gift_card.proto";

      service RPCService {
        rpc InitialiseGiftCard(rpc.gift_cards.v1.InitialiseGiftCardRequest) returns (rpc.gift_cards.v1.InitialiseGiftCardResponse);
      }
      """

      rpc_proto = """
      syntax = "proto3";

      package rpc.gift_cards.v1;

      message InitialiseGiftCardRequest {}

      message InitialiseGiftCardResponse {
        int32 id = 1;
      }
      """

      File.write!(Path.join(rpc_path, "gift_cards_service.proto"), service_proto)
      File.write!(Path.join(rpc_path, "initialise_gift_card.proto"), rpc_proto)

      exec_buf!(tmp_dir)

      expected_impl = ~S"""
      defmodule Rpc.GiftCards.Client do
        @moduledoc "Autogenerated by `elixir-rpc-proto-gen-helpers`"

        @behaviour Rpc.GiftCards.ClientBehaviour
        use RpcClient.Client, service: GiftCards, stub: Rpc.GiftCards.V1.RPCService.Stub

        @impl true
        def initialise_gift_card(request, opts \\ []) do
          call(request, :initialise_gift_card, opts)
        end

        @impl true
        def initialise_gift_card!(request, opts \\ []) do
          call!(request, :initialise_gift_card, opts)
        end
      end
      """

      assert_content_matches_file(
        expected_impl,
        "#{tmp_dir}/generated/rpc/gift_cards/v1/gift_cards_client_impl.ex"
      )

      expected_behaviour = ~S"""
      defmodule Rpc.GiftCards.ClientBehaviour do
        @moduledoc "Autogenerated by `elixir-rpc-proto-gen-helpers`"

        alias RpcClient.AdapterBehaviour

        @callback initialise_gift_card(Rpc.GiftCards.V1.InitialiseGiftCardRequest.t(), AdapterBehaviour.opts()) ::
                          {:ok, Rpc.GiftCards.V1.InitialiseGiftCardResponse.t()}
                          | {:error, atom() | list()}
                          | {:error, atom() | list(), list() | nil}

        @callback initialise_gift_card!(Rpc.GiftCards.V1.InitialiseGiftCardRequest.t(), AdapterBehaviour.opts()) ::
                          Rpc.GiftCards.V1.InitialiseGiftCardResponse.t() | no_return()

        @callback initialise_gift_card(Rpc.GiftCards.V1.InitialiseGiftCardRequest.t()) ::
                          {:ok, Rpc.GiftCards.V1.InitialiseGiftCardResponse.t()}
                          | {:error, atom() | list()}
                          | {:error, atom() | list(), list() | nil}

        @callback initialise_gift_card!(Rpc.GiftCards.V1.InitialiseGiftCardRequest.t()) ::
                          Rpc.GiftCards.V1.InitialiseGiftCardResponse.t() | no_return()
      end
      """

      assert_content_matches_file(
        expected_behaviour,
        "#{tmp_dir}/generated/rpc/gift_cards/v1/gift_cards_client_behaviour.ex"
      )
    end

    test "injects single-line comments into docs", %{tmp_dir: tmp_dir} do
      rpc_path = Path.join(tmp_dir, "rpc/gift_cards/v1")
      File.mkdir_p!(rpc_path)

      service_proto = """
      syntax = "proto3";

      package rpc.gift_cards.v1;

      import "rpc/gift_cards/v1/initialise_gift_card.proto";

      service RPCService {
        // this is a comment
        // and
        //
        // this is another
        rpc InitialiseGiftCard(rpc.gift_cards.v1.InitialiseGiftCardRequest) returns (rpc.gift_cards.v1.InitialiseGiftCardResponse);
      }
      """

      rpc_proto = """
      syntax = "proto3";

      package rpc.gift_cards.v1;

      message InitialiseGiftCardRequest {}

      message InitialiseGiftCardResponse {
        int32 id = 1;
      }
      """

      File.write!(Path.join(rpc_path, "gift_cards_service.proto"), service_proto)
      File.write!(Path.join(rpc_path, "initialise_gift_card.proto"), rpc_proto)

      exec_buf!(tmp_dir)

      # The extra space is an artifact of the template and will be removed after
      #  formatting
      expected_impl = ~s"""
      defmodule Rpc.GiftCards.Client do
        @moduledoc "Autogenerated by `elixir-rpc-proto-gen-helpers`"

        @behaviour Rpc.GiftCards.ClientBehaviour
        use RpcClient.Client, service: GiftCards, stub: Rpc.GiftCards.V1.RPCService.Stub

        @impl true
        @doc \"\"\"
        this is a comment
        and

        this is another
        \"\"\"#{" "}
        def initialise_gift_card(request, opts \\\\ []) do
          call(request, :initialise_gift_card, opts)
        end

        @impl true
        @doc \"\"\"
        this is a comment
        and

        this is another
        \"\"\"#{" "}
        def initialise_gift_card!(request, opts \\\\ []) do
          call!(request, :initialise_gift_card, opts)
        end
      end
      """

      assert_content_matches_file(
        expected_impl,
        "#{tmp_dir}/generated/rpc/gift_cards/v1/gift_cards_client_impl.ex"
      )

      expected_behaviour = ~S"""
      defmodule Rpc.GiftCards.ClientBehaviour do
        @moduledoc "Autogenerated by `elixir-rpc-proto-gen-helpers`"

        alias RpcClient.AdapterBehaviour

        @callback initialise_gift_card(Rpc.GiftCards.V1.InitialiseGiftCardRequest.t(), AdapterBehaviour.opts()) ::
                          {:ok, Rpc.GiftCards.V1.InitialiseGiftCardResponse.t()}
                          | {:error, atom() | list()}
                          | {:error, atom() | list(), list() | nil}

        @callback initialise_gift_card!(Rpc.GiftCards.V1.InitialiseGiftCardRequest.t(), AdapterBehaviour.opts()) ::
                          Rpc.GiftCards.V1.InitialiseGiftCardResponse.t() | no_return()

        @callback initialise_gift_card(Rpc.GiftCards.V1.InitialiseGiftCardRequest.t()) ::
                          {:ok, Rpc.GiftCards.V1.InitialiseGiftCardResponse.t()}
                          | {:error, atom() | list()}
                          | {:error, atom() | list(), list() | nil}

        @callback initialise_gift_card!(Rpc.GiftCards.V1.InitialiseGiftCardRequest.t()) ::
                          Rpc.GiftCards.V1.InitialiseGiftCardResponse.t() | no_return()
      end
      """

      assert_content_matches_file(
        expected_behaviour,
        "#{tmp_dir}/generated/rpc/gift_cards/v1/gift_cards_client_behaviour.ex"
      )
    end

    test "injects multi-line comments into docs", %{tmp_dir: tmp_dir} do
      rpc_path = Path.join(tmp_dir, "rpc/gift_cards/v1")
      File.mkdir_p!(rpc_path)

      service_proto = """
      syntax = "proto3";

      package rpc.gift_cards.v1;

      import "rpc/gift_cards/v1/initialise_gift_card.proto";

      service RPCService {
        /*
        * I am a
        * multi-line
        *
        * comment
        */
        rpc InitialiseGiftCard(rpc.gift_cards.v1.InitialiseGiftCardRequest) returns (rpc.gift_cards.v1.InitialiseGiftCardResponse);
      }
      """

      rpc_proto = """
      syntax = "proto3";

      package rpc.gift_cards.v1;

      message InitialiseGiftCardRequest {}

      message InitialiseGiftCardResponse {
        int32 id = 1;
      }
      """

      File.write!(Path.join(rpc_path, "gift_cards_service.proto"), service_proto)
      File.write!(Path.join(rpc_path, "initialise_gift_card.proto"), rpc_proto)

      exec_buf!(tmp_dir)

      # The extra space is an artifact of the template and will be removed after
      #  formatting
      expected_impl = ~s"""
      defmodule Rpc.GiftCards.Client do
        @moduledoc "Autogenerated by `elixir-rpc-proto-gen-helpers`"

        @behaviour Rpc.GiftCards.ClientBehaviour
        use RpcClient.Client, service: GiftCards, stub: Rpc.GiftCards.V1.RPCService.Stub

        @impl true
        @doc \"\"\"
        I am a
        multi-line

        comment
        \"\"\"#{" "}
        def initialise_gift_card(request, opts \\\\ []) do
          call(request, :initialise_gift_card, opts)
        end

        @impl true
        @doc \"\"\"
        I am a
        multi-line

        comment
        \"\"\"#{" "}
        def initialise_gift_card!(request, opts \\\\ []) do
          call!(request, :initialise_gift_card, opts)
        end
      end
      """

      assert_content_matches_file(
        expected_impl,
        "#{tmp_dir}/generated/rpc/gift_cards/v1/gift_cards_client_impl.ex"
      )

      expected_behaviour = ~S"""
      defmodule Rpc.GiftCards.ClientBehaviour do
        @moduledoc "Autogenerated by `elixir-rpc-proto-gen-helpers`"

        alias RpcClient.AdapterBehaviour

        @callback initialise_gift_card(Rpc.GiftCards.V1.InitialiseGiftCardRequest.t(), AdapterBehaviour.opts()) ::
                          {:ok, Rpc.GiftCards.V1.InitialiseGiftCardResponse.t()}
                          | {:error, atom() | list()}
                          | {:error, atom() | list(), list() | nil}

        @callback initialise_gift_card!(Rpc.GiftCards.V1.InitialiseGiftCardRequest.t(), AdapterBehaviour.opts()) ::
                          Rpc.GiftCards.V1.InitialiseGiftCardResponse.t() | no_return()

        @callback initialise_gift_card(Rpc.GiftCards.V1.InitialiseGiftCardRequest.t()) ::
                          {:ok, Rpc.GiftCards.V1.InitialiseGiftCardResponse.t()}
                          | {:error, atom() | list()}
                          | {:error, atom() | list(), list() | nil}

        @callback initialise_gift_card!(Rpc.GiftCards.V1.InitialiseGiftCardRequest.t()) ::
                          Rpc.GiftCards.V1.InitialiseGiftCardResponse.t() | no_return()
      end
      """

      assert_content_matches_file(
        expected_behaviour,
        "#{tmp_dir}/generated/rpc/gift_cards/v1/gift_cards_client_behaviour.ex"
      )
    end

    test "generates modules for services with packages starting with fresha", %{tmp_dir: tmp_dir} do
      rpc_path = Path.join(tmp_dir, "fresha/auth/protobuf/rpc/partners/v1")
      File.mkdir_p!(rpc_path)

      service_proto = """
      syntax = "proto3";

      package fresha.auth.protobuf.rpc.partners.v1;

      import "fresha/auth/protobuf/rpc/partners/v1/delete_session_hook.proto";

      service PartnersAuthService {
        rpc DeleteSessionHook(DeleteSessionHookRequest) returns (DeleteSessionHookResponse);
      }
      """

      rpc_proto = """
      syntax = "proto3";

      package fresha.auth.protobuf.rpc.partners.v1;

      message DeleteSessionHookRequest {}

      message DeleteSessionHookResponse {
        bool did_remove_session = 1;
      }
      """

      File.write!(Path.join(rpc_path, "partners_auth_service.proto"), service_proto)
      File.write!(Path.join(rpc_path, "delete_session_hook.proto"), rpc_proto)

      exec_buf!(tmp_dir)

      expected_impl = ~S"""
      defmodule Rpc.PartnersAuth.Client do
        @moduledoc "Autogenerated by `elixir-rpc-proto-gen-helpers`"

        @behaviour Rpc.PartnersAuth.ClientBehaviour
        use RpcClient.Client, service: PartnersAuth, stub: Fresha.Auth.Protobuf.Rpc.Partners.V1.PartnersAuthService.Stub

        @impl true
        def delete_session_hook(request, opts \\ []) do
          call(request, :delete_session_hook, opts)
        end

        @impl true
        def delete_session_hook!(request, opts \\ []) do
          call!(request, :delete_session_hook, opts)
        end
      end
      """

      assert_content_matches_file(
        expected_impl,
        "#{tmp_dir}/generated/fresha/auth/protobuf/rpc/partners/v1/partners_auth_client_impl.ex"
      )

      expected_behaviour = ~S"""
      defmodule Rpc.PartnersAuth.ClientBehaviour do
        @moduledoc "Autogenerated by `elixir-rpc-proto-gen-helpers`"

        alias RpcClient.AdapterBehaviour

        @callback delete_session_hook(Fresha.Auth.Protobuf.Rpc.Partners.V1.DeleteSessionHookRequest.t(), AdapterBehaviour.opts()) ::
                          {:ok, Fresha.Auth.Protobuf.Rpc.Partners.V1.DeleteSessionHookResponse.t()}
                          | {:error, atom() | list()}
                          | {:error, atom() | list(), list() | nil}

        @callback delete_session_hook!(Fresha.Auth.Protobuf.Rpc.Partners.V1.DeleteSessionHookRequest.t(), AdapterBehaviour.opts()) ::
                          Fresha.Auth.Protobuf.Rpc.Partners.V1.DeleteSessionHookResponse.t() | no_return()

        @callback delete_session_hook(Fresha.Auth.Protobuf.Rpc.Partners.V1.DeleteSessionHookRequest.t()) ::
                          {:ok, Fresha.Auth.Protobuf.Rpc.Partners.V1.DeleteSessionHookResponse.t()}
                          | {:error, atom() | list()}
                          | {:error, atom() | list(), list() | nil}

        @callback delete_session_hook!(Fresha.Auth.Protobuf.Rpc.Partners.V1.DeleteSessionHookRequest.t()) ::
                          Fresha.Auth.Protobuf.Rpc.Partners.V1.DeleteSessionHookResponse.t() | no_return()
      end
      """

      assert_content_matches_file(
        expected_behaviour,
        "#{tmp_dir}/generated/fresha/auth/protobuf/rpc/partners/v1/partners_auth_client_behaviour.ex"
      )
    end
  end

  defp tmp_dir(context) do
    dir_name =
      "#{inspect(context[:case])}#{context[:describe]}#{context[:test]}"
      |> String.downcase()
      |> String.replace(["-", " ", ".", "_"], "_")

    tmp_dir_name = Path.join(System.tmp_dir!(), dir_name)

    File.rm_rf!(tmp_dir_name)
    File.mkdir_p!(tmp_dir_name)

    Map.put(context, :tmp_dir, tmp_dir_name)
  end

  defp assert_content_matches_file(content, file) do
    file_content = file |> File.read!() |> String.trim_trailing("\n")
    assert String.trim_trailing(content, "\n") == file_content
  end

  defp exec_buf!(tmp_dir) do
    cwd = File.cwd!()
    buf_gen = Path.join([cwd, "test", "buf.gen.yaml"])
    File.cp!(buf_gen, Path.join(tmp_dir, "buf.gen.yaml"))
    File.cd!(tmp_dir)
    assert {_, 0} = System.cmd("buf", ["generate", tmp_dir], stderr_to_stdout: true)
    File.cd!(cwd)
  end
end
