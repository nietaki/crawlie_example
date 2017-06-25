defmodule NosyStage do
  use GenStage

  def init(creator_pid) do
    {:consumer, creator_pid}
  end

  def handle_events(events, from, creator_pid) do
    IO.puts "Nosy handles incoming events: #{inspect(events)} from #{inspect(from)}"
    {:noreply, [], creator_pid}
  end

  def handle_subscribe(:producer, _options, from, creator_pid) do
    IO.puts "Nosy subscribed to #{inspect(from)}"
    # {:manual, creator_pid}
    {:automatic, creator_pid}
  end

  def handle_info({from, {:producer, :done}}, creator_pid) do
    IO.puts "Nosy got {:producer, :done} info from #{inspect(from)}"
    send creator_pid, :nosy_stage_done
    {:stop, :normal, creator_pid}
  end
end
