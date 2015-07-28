defmodule Experimental.KernelDeffailTest do
  use ExUnit.Case, async: true
  doctest Experimental.KernelDeffail, import: Experimental.KernelDeffail
  import Experimental.KernelDeffail

  defmodule Foo do
    deffail sum_positives(a, b) when not is_non_negative_integer(a)
                                when not is_non_negative_integer(b)
    def sum_positives(a, b), do: a + b 

    # greater than
    deffail gt(a, b) when not is_integer(a)
                     or not is_non_negative_integer(b)
    def gt(a, b), do: max(a, b)


    deffail check(a, b) when is_bitstring(a) or is_bitstring(b) do
      raise FunctionClauseError, "something bad happened"
    end
    
    def check(a, b) do
      :ok
    end

    # check/1
    def check(a) when is_integer(a) do
      :ok
    end

    deffail check(a) do
      :error
    end
  end

  test "deffail/2 with no guards" do
    assert Foo.sum_positives(2, 3) == 5
    assert Foo.sum_positives(0, 0) == 0
  end

  test "deffail/2 with guards" do
    assert Foo.gt(0, 0) == 0 
    assert_raise FunctionClauseError, "something bad happened in Experimental.KernelDeffail.deffail/2", fn ->
      Foo.gt(0, -1)
    end

    assert Foo.check(:a, :b) == :ok
    assert_raise FunctionClauseError, "something bad happened in Experimental.KernelDeffail.deffail/2", fn ->
      Foo.check("a", :b)
    end
    assert_raise FunctionClauseError, "something bad happened in Experimental.KernelDeffail.deffail/2", fn ->
      Foo.check(:a, "b")
    end
    assert_raise FunctionClauseError, "something bad happened in Experimental.KernelDeffail.deffail/2", fn ->
      Foo.check("a", "b")
    end

    assert Foo.check(10) == :ok
    assert_raise FunctionClauseError, "something bad happened in Experimental.KernelDeffail.deffail/2", fn ->
      Foo.check("10")
    end
  end
  

end