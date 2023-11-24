defmodule Stress do
  use Supervisor

  def start_link(options \\ []) do
    default = [max_concurrency: 20]
    options = Keyword.merge(default, options)

    Supervisor.start_link(
      __MODULE__,
      %{
        max_concurrency: options[:max_concurrency]
      },
      name: __MODULE__
    )
  end

  @impl true
  def init(%{
        max_concurrency: max_concurrency
      }) do
    children =
      for i <- 1..max_concurrency do
        id = "gen:" <> "#{i}"

        %{
          id: id,
          start: {StressReq, :start_link, [nil]},
          restart: :transient
        }
      end

    children = [StressStats | children]

    Supervisor.init(children, strategy: :one_for_one)
  end

  def stats, do: Process.whereis(StressStats) |> :sys.get_state()

  def request(url, options \\ []) do
    default = [requests: 10]
    options = Keyword.merge(default, options)

    Supervisor.which_children(__MODULE__)
    |> Enum.filter(fn {id, _pid, _type, _} ->
      is_binary(id) && String.starts_with?(id, "gen:")
    end)
    |> Enum.map(fn gen -> elem(gen, 1) end)
    |> Enum.map(fn pid -> StressReq.restart(pid, %{requests: options[:requests], url: url}) end)
    |> Enum.map(&StressReq.request(&1))
  end
end
