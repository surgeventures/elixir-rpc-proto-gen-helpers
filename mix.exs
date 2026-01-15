defmodule RPCProtoGenHelpers.MixProject do
  use Mix.Project

  def project do
    [
      app: :rpc_proto_gen_helpers,
      version: "0.1.1",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      escript: escript()
    ]
  end

  # This `escript` should be available in `PATH`, so that `protoc` can find it.
  defp escript do
    [
      main_module: RPCProtoGenHelpers.CLI,
      name: "protoc-gen-elixir-rpc",
      emu_args: emu_args()
    ]
  end

  # OTP 26+ changed how stdin encoding works, requiring this kernel parameter
  # to properly read raw binary data from stdin without unicode translation errors.
  # See: https://github.com/elixir-protobuf/protobuf/blob/main/mix.exs
  defp emu_args do
    if System.otp_release() in ["26", "27"] do
      "-kernel standard_io_encoding latin1"
    else
      ""
    end
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :eex]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:recase, "~> 0.7.0"},
      {:protobuf, "~> 0.14.0"}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end
