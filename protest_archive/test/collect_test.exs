defmodule CollectTest do
  use ExUnit.Case
  alias ProtestArchive.Collect
  doctest Collect

  test "poolboy acts as a supervisor, restarting crashed workers" do
    number_processes = :erlang.system_info(:process_count)
    pid = :poolboy.checkout(Collect)
    Process.exit(pid, :kill)
    assert number_processes == :erlang.system_info(:process_count)
  end
end
