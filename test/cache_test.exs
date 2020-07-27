defmodule CacheTest do
  use ExUnit.Case
  alias ProtestArchive.{Cache, ProcessRegistry}
  doctest Cache

  test "Cache servers are created on start of application" do
    tags = ["black lives matter", "police brutality", "protest"]

    Enum.each(tags, fn tag ->
      assert Registry.lookup(ProcessRegistry, {:news, tag}) != []
    end)
  end

  test "cannot add to cache server that does not exist" do
    Cache.put({:news, "tag that does not exist"}, [:some_state])
    via = ProcessRegistry.via_tuple({:news, "tag that does not exist"})
    # assert that no cache was registered
    assert Registry.lookup(ProcessRegistry, via) == []
  end

  test "can put new state into cache server" do
    assert Cache.get({:news, "black lives matter"}) == []
    Cache.put({:news, "black lives matter"}, ["howdy", "world"])
    assert Cache.get({:news, "black lives matter"}) == ["howdy", "world"]
  end
end
