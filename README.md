# RPCProtoGenHelpers

This library defines a `buf` [custom plugin](https://buf.build/docs/bsr/remote-plugins/custom-plugins).

This plugin reads in a bunch of proto files, and for the RPC services generates some helpers: behaviour modules and "impl" modules to make calling and testing gRPC methods easier.

This repo is not intended to be used directly, but rather includes an [`escript`](https://hexdocs.pm/mix/1.12/Mix.Tasks.Escript.html). This can be used as part of a shell script:

```bash
which protoc-gen-elixir-rpc || PATH="~/.mix/escripts:$PATH" && mix escript.install --force github surgeventures/elixir-rpc-proto-gen-helpers
```

Then you can use the plugin for [`buf generate`](https://buf.build/docs/reference/cli/buf/generate). An example `buf` config file might be:

```yaml
version: v1
plugins:
  - name: elixir
    strategy: all
    out: ./lib/generated
    opt: plugins=grpc
  - name: elixir-rpc
    strategy: all
    out: ./lib/generated
    opt: plugins=grpc
```

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

