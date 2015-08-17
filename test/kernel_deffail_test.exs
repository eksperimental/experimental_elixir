defmodule Experimental.KernelDeffailTest do
  use ExUnit.Case, async: true
  doctest Experimental.KernelDeffail, import: true

  import Experimental.KernelDeffail
  import Experimental.KernelGuard


  defmodule Foo do
    deffail sum_positives(a, b)
      when not (is_non_neg_integer(a) and is_non_neg_integer(b)) do
      raise ArgumentError
    end

    defensure sum_positives(a, b) when
      (is_non_neg_integer(a) and is_non_neg_integer(b)) do
      raise ArgumentError
    end

    defensure sum_positives(a, b) do
      is_non_neg_integer(a) and is_non_neg_integer(b)
    else
      raise ""
    end

    deffail sum_positives(a, b)
      when not is_non_neg_integer(a)
      when not is_non_neg_integer(b) do
      raise ArgumentError
    end

    def sum_positives(a, b), do: a + b 

    # greater than
    deffail gt(a, b) when not is_non_neg_integer(a)
                     or not is_non_neg_integer(b)
    def gt(a, b), do: max(a, b)

    # check/2
    # raises FunctionClauseError
    deffail check(a, b) when is_bitstring(a) or is_bitstring(b) do
      raise FunctionClauseError
    end
    
    def check(_a, _b) do
      :ok
    end

    # check/1
    def check(a) when is_non_neg_integer(a) do
      :ok
    end

    deffail check(a) when is_bitstring(a) do
      #no raise
      :error
    end

    deffail check(_) when true
  end

  test "deffail/2 with no guards" do
    assert Foo.sum_positives(2, 3) == 5
    assert Foo.sum_positives(0, 0) == 0

    assert_raise ArgumentError, "cannot use `deffail/2` without a `when` clause", fn ->
      deffail foo(a), do: raise ArgumentError, message: "this will not raise"
    end
  end

  test "deffail/2 with guards" do
    assert Foo.gt(0, 0) == 0

    assert_raise ArgumentError, "argument error", fn ->
      Foo.gt(0, -1)
    end

    # Foo.check/2
    assert Foo.check(:a, :b) == :ok
    
    assert_raise FunctionClauseError, fn ->
      Foo.check("a", :b)
    end
    
    assert_raise FunctionClauseError, fn ->
      Foo.check(:a, "b")
    end
    
    assert_raise FunctionClauseError, fn ->
      Foo.check("a", "b")
    end

    # Foo.check/1
    assert Foo.check(10)   == :ok
    assert Foo.check("10") == :error
    
    assert_raise ArgumentError, "argument error", fn ->
      Foo.check(:ten)
    end

    assert_raise ArgumentError, "cannot use `deffail/2` without a `when` clause", fn ->
      deffail check(a), do: :error
    end
  end

end