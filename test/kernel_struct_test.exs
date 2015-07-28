defmodule Experimental.KernelStructTest do
  use ExUnit.Case, async: true
  doctest Experimental.KernelStruct, import: true
  
  import Experimental.KernelStruct

  defmodule Potion do
    defstruct [name: nil, function: nil]
  end

  test "struct?/1" do
    assert struct?(1..3)
    assert struct?(%Range{})
    
    assert struct?(%Potion{})
    assert struct?(%Potion{name: "Elixir", function: "Cure-all"})
    
    refute struct?(%{})
    refute struct?(%{:this_is => :a_map})
    refute struct?([a: 1, b: 2])
  end

  test "struct?/2" do
    assert struct?(1..3, Range)
    assert struct?(%Range{}, Range)
    refute struct?(%Range{}, Foo)

    assert struct?(%Potion{}, Potion)
    assert struct?(%Potion{name: "Elixir", function: "Cure-all"}, Potion)
    refute struct?(%Potion{}, Foo)

    refute struct?(%{}, Map)
    refute struct?(%{:this_is => :a_map}, Map)
    refute struct?([a: 1, b: 2], KeywordList)
  end

end