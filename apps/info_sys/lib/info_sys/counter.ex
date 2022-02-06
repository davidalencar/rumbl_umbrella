defmodule InfoSys.Counter do


  def start_link (initial_val) do
    {:ok, spawn_link(fn -> 
      listen(initial_val)
    end)}
  end

  def inc(pid), do: send(pid, :inc)
  def dec(pid), do: send(pid, :dec)


  def listen(val) do
    receive do
      :inc ->
        listen(val + 1)
      :dec -> 
        listen(val - 1)
      {:val, sender, ref} ->
        send(sender, {ref, val})
    end
  end
    

  def val(pid, timeout \\ 5000) do
    ref = make_ref()
    send(pid, {:val, self(), ref})

    receive do
      {^ref, val} ->
        val
      after timeout ->
          exit(:timeout)
    end
  end
end
