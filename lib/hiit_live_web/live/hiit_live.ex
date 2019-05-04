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
       timers: [{50, 50, "Burpees"}, {10, 10, "Pause"}, {50, 50, "More Burpees"}],
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

          socket =
            socket
            |> assign(timers: newtimers, activetimer: activetimer + 1, lasttick: now)
            |> get_current_and_coming()

          {:noreply, socket |> schedule_tick()}
        else
          diff = now - lasttick
          newtimers = List.replace_at(timers, activetimer, {togo - diff, original, name})

          socket =
            socket
            |> assign(timers: newtimers, activetimer: activetimer, lasttick: now)
            |> get_current()

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

  def handle_event("hiit-start", formdata, socket) do
    timers = combine_timers_and_names(formdata)

    {:noreply,
     assign(socket, timers: timers, running: true, lasttick: timestamp())
     |> get_current_and_coming()
     |> schedule_tick()}
  end

  def handle_event("hiit-update", formdata, socket) do
    timers = combine_timers_and_names(formdata)
    {:noreply, assign(socket, timers: timers)}
  end

  def handle_event("hiit-form-running", _formdata, socket) do
    {:noreply, assign(socket, running: false, activetimer: 0)}
  end

  def handle_event("add-timer", _, %{assigns: %{timers: timers}} = socket) do
    {:noreply, assign(socket, timers: timers ++ [{1, 1, "tbd"}])}
  end

  def handle_event("delete-timer", number, %{assigns: %{timers: timers}} = socket) do
    {number, _} = Integer.parse(number)
    newtimers = List.delete_at(timers, number)
    {:noreply, assign(socket, timers: newtimers)}
  end

  defp schedule_tick(socket) do
    Process.send_after(self(), :tick, socket.assigns.tick)
    socket
  end

  defp timestamp() do
    :os.system_time(:milli_seconds)
  end

  defp get_current(%{assigns: %{timers: timers, activetimer: activetimer}} = socket) do
    current = Enum.at(timers, activetimer)
    assign(socket, current: current)
  end

  defp get_current_and_coming(%{assigns: %{timers: timers, activetimer: activetimer}} = socket) do
    coming =
      timers
      |> Enum.with_index()
      |> Enum.filter(fn {_, i} -> i > activetimer end)
      |> Enum.chunk_every(2)

    socket
    |> get_current()
    |> assign(coming: coming)
  end

  defp combine_timers_and_names(formdata) do
    formdata
    |> Enum.filter(fn {key, _value} -> String.starts_with?(key, "time-") end)
    |> Enum.with_index()
    |> Enum.map(fn {{_k, v}, i} ->
      name = Map.get(formdata, "name-time-#{i}", "tbd")
      case Integer.parse(v) do
        {v, _} -> {v * 1000, v, name}
        :error -> {1 * 1000, 1, name}
      end
    end)
  end
end
