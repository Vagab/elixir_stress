# Stress

Simple usage:

```bash
iex -S mix
```

```elixir
iex> Stress.start_link
iex> Stress.requests("https://httpbin.org/get")
iex> Stress.stats
```

for additional documentation, use `h Stress.start_link`, `h Stress.requests`, and `h Stress.stats`

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `stress` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:stress, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/stress>.
