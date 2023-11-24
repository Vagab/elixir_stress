defmodule StressStats do
  use GenServer

  def request(data) do
    GenServer.cast(__MODULE__, {:request, data})
  end

  def stats do
    :sys.get_state(__MODULE__)
  end

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  @impl true
  def init(_) do
    {:ok, %{ok: 0, error: 0, avg_ok: 0, time_ok: 0}}
  end

  @impl true
  def handle_cast({:request, %{result: result, time: time}}, state) do
    IO.puts("Status code: #{result.status}, time: #{time}")

    state =
      case result.status do
        200 -> %{state | ok: state.ok + 1, time_ok: state.time_ok + time}
        _ -> %{state | error: state.error + 1}
      end

    {:noreply, %{state | avg_ok: state.time_ok / state.ok}}
  end
end
