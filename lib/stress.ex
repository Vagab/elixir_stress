defmodule Stress do
  use Supervisor

  @doc """
  Starts the supervisor.
  Takes an optional :max_concurrency keyword, which is the number of concurrent requests being made.
  Defaults to 20.
  """
  @spec start_link(Keyword.t()) :: Supervisor.on_start()
  def start_link(options \\ []) do
    default = [max_concurrency: 20]
    options = Keyword.merge(default, options)

    Supervisor.start_link(
      __MODULE__,
      %{max_concurrency: options[:max_concurrency]},
      name: __MODULE__
    )
  end

  @impl true
  def init(%{max_concurrency: max_concurrency}) do
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

  @doc """
  Returns current stats
  """
  @spec stats() :: %{avg_ok: float(), error: integer(), ok: integer(), time_ok: integer()}
  def stats, do: StressStats.stats()

  @doc """
  Makes requests to the given url.
  Takes an optional :requests keyword, which is the number of requests to make per genserver. Defaults to 10.
  I.e. if :max_concurrency was set to 20, and :requests was set to 10, then 20 * 10 requests would be made.
  """
  @spec request(String.t(), Keyword.t()) :: :ok
  def request(url, options \\ []) do
    default = [requests: 10]
    options = Keyword.merge(default, options)

    Supervisor.which_children(__MODULE__)
    |> Enum.filter(fn {id, _pid, _type, _} ->
      is_binary(id) && String.starts_with?(id, "gen:")
    end)
    |> Enum.each(fn {_, pid, _, _} ->
      pid
      |> StressReq.ready(%{requests: options[:requests], url: url})
      |> StressReq.request()
    end)

    :ok
  end
end
