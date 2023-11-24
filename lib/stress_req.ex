defmodule StressReq do
  use GenServer

  def request(pid) do
    Process.send_after(pid, {:request}, 0)

    pid
  end

  def restart(pid, %{requests: requests, url: url}) do
    Process.send_after(pid, {:restart, %{requests: requests, url: url}}, 0)

    pid
  end

  def start_link(_) do
    GenServer.start_link(
      __MODULE__,
      %{current_requests: 0, requests: 0, url: ""}
    )
  end

  @impl true
  def init(state) do
    {:ok, state}
  end

  @impl true
  def handle_info(
        {:request},
        %{requests: requests, current_requests: current_requests, url: url} = state
      ) do
    if current_requests < requests do
      {time, result} = :timer.tc(fn -> Req.get!(url) end)
      StressStats.request(%{result: result, time: time})

      request(self())

      {:noreply, %{state | current_requests: current_requests + 1}}
    else
      {:noreply, state}
    end
  end

  @impl true
  def handle_info({:restart, %{requests: requests, url: url}}, state) do
    {:noreply, %{state | requests: requests, url: url, current_requests: 0}}
  end
end
