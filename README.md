# RPCProtoGenHelpers

This library defines a `buf` [custom plugin](https://buf.build/docs/bsr/remote-plugins/custom-plugins).

This plugin reads in a bunch of proto files, and for the RPC services generates some helpers: behaviour modules and "impl" modules to make calling and testing gRPC methods easier.

This repo is not intended to be used directly, but rather includes an [`escript`](https://hexdocs.pm/mix/1.12/Mix.Tasks.Escript.html). This can be used as part of a shell script:

```bash
which protoc-gen-elixir-rpc || PATH="~/.mix/escripts:$PATH" && mix escript.install --force github surgeventures/elixir-rpc-proto-gen-helpers
```

Then you can use the plugin for [`buf generate`](https://buf.build/docs/reference/cli/buf/generate). An example `buf` config file might be:

```yaml
version: v2
plugins:
  - local: protoc-gen-elixir
    strategy: all
    out: ./lib/generated
    opt: plugins=grpc
  - local: protoc-gen-elixir-rpc
    strategy: all
    out: ./lib/generated
    opt: plugins=grpc
```

Note that `protoc-gen-elixir` is [a separate plugin](https://github.com/elixir-protobuf/protobuf?tab=readme-ov-file).

To visualise the metadata structure that is parsed, see `buf.example.json`.

To generate such a file run `buf build --output export.json`.

## Testing

This plugin is tested with integration tests which call `buf generate`.

If you want to run tests, make sure you have `buf` installed at version `1.40` or greater.

Running tests assumes that certain executables are in your `PATH`:

```bash
PATH="~/.mix/escripts:$PATH" && \
mix escript.install --force hex protobuf 0.7.1 && \
mix escript.build && mix escript.install --force protoc-gen-elixir-rpc
```

Every time you change the CLI code, you must run `mix escript.build && mix escript.install --force protoc-gen-elixir-rpc`.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `rpc_proto_gen_helpers` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:rpc_proto_gen_helpers, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/rpc_proto_gen_helpers>.
