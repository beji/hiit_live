defmodule HiitLiveWeb.HiitLive do
  use Phoenix.LiveView

  require Logger

  @tick 100

  def render(%{running: false} = assigns) do
    HiitLiveWeb.PageView.render("hiit_start.html", assigns)
  end

  def render(%{running: true} = assigns) do
    HiitLiveWeb.PageView.render("hiit_running.html", assigns)
  end

  def mount(_session, socket) do
    {:ok,
     assign(socket,
       running: false,
       tick: @tick,
       timers: [{50, 50, "Burpees"}, {10, 10, "Pause"}],
       lasttick: nil,
       activetimer: 0,
       done: false
     )}
  end

  def handle_info(
        :tick,
        %{assigns: %{running: true, timers: timers, activetimer: activetimer, lasttick: lasttick}} =
          socket
      ) do
    now = timestamp()

    case Enum.fetch(timers, activetimer) do
      {:ok, {togo, original, name}} ->
        if togo <= 0 do
          newtimers = List.replace_at(timers, activetimer, {0, original, name})
          socket = assign(socket, timers: newtimers, activetimer: activetimer + 1, lasttick: now)
          {:noreply, socket |> schedule_tick()}
        else
          diff = now - lasttick
          newtimers = List.replace_at(timers, activetimer, {togo - diff, original, name})
          socket = assign(socket, timers: newtimers, activetimer: activetimer, lasttick: now)
          {:noreply, socket |> schedule_tick()}
        end

      _ ->
        Logger.info(
          "trying to access idx #{activetimer} but that doesn't exist, we are done here"
        )

        {:noreply, assign(socket, done: true)}
    end
  end

  def handle_info(:tick, socket) do
    {:noreply, socket}
  end

  def handle_event("hiit-form-update", formdata, socket) do
    timers =
      formdata
      |> Enum.filter(fn {key, _value} -> String.starts_with?(key, "time-") end)
      |> Enum.with_index()
      |> Enum.map(fn {{_k, v}, i} ->
        name = Map.get(formdata, "name-time-#{i}", "tbd")
        {v, _} = Integer.parse(v)
        {v * 1000, v, name}
      end)

    {:noreply,
     assign(socket, timers: timers, running: true, lasttick: timestamp())
     |> schedule_tick()}
  end

  def handle_event("hiit-form-running", _formdata, socket) do
    {:noreply, assign(socket, running: false, activetimer: 0)}
  end

  def handle_event("add-timer", _, %{assigns: %{timers: timers}} = socket) do
    {:noreply, assign(socket, timers: timers ++ [{1, 1, "tbd"}])}
  end

  defp schedule_tick(socket) do
    Process.send_after(self(), :tick, socket.assigns.tick)
    socket
  end

  defp timestamp() do
    :os.system_time(:milli_seconds)
  end
end
