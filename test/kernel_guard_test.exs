defmodule Experimental.KernelGuardTest do
  import Kernel, except: [guard: 1, guard: 2, guardp: 1, guardp: 2, ]
  import Experimental.KernelGuard

  require Logger

  use ExUnit.Case, async: true
  #doctest Experimental.KernelGuard, import: true

  @type element :: any
  @type t :: Enumerable.t

  #guard check_nothing_defined(a, b)

  # Default value
  @spec check_default_1(pos_integer, neg_integer) :: :ok
  guard check_default_1(a, b \\ -1) when 1 == 1 do
    is_integer(a) and a > 0 and is_integer(b) and b < 0
  end
  def check_default_1(a, b) when is_integer(a) and is_integer(b), do: :ok
  #check_default_1(:foo, :bar)

  test "xx" do
    check_default_1(3, -1)
  end

#  I cannot manage to create a test for this one
#  @spec check_default_2(pos_integer, neg_integer) :: :ok
#  def check_default_2(a, b \\ -1)
#  guard check_default_2(a, b \\ -1) when 1 == 1 do
#   is_integer(a) and a > 0 and is_integer(b) and b < 0
#  end
#  def check_default_2(a, b) when is_integer(a) and is_integer(b), do: :ok

  @spec check_default_2B(pos_integer, neg_integer) :: :ok
#  defp check_default_2B(a, b)
  guardp check_default_2B(a, b \\ -1) when 1 == 1 do
    is_integer(a) and a > 0 and is_integer(b) and b < 0
  end
  defp check_default_2B(a, b) when is_integer(a) and is_integer(b), do: :ok

  @spec check_default_3(pos_integer, neg_integer) :: :ok
  guard check_default_3(a, b \\ -1) when 1 == 1 do
    is_integer(a) and a > 0 and is_integer(b) and b < 0
  end
  def check_default_3(a, b) when is_integer(a) and is_integer(b), do: :ok

  @spec check_default_4(pos_integer, neg_integer) :: :ok
  guardp check_default_4(a, b \\ -1) do
    is_integer(a) and a > 0 and is_integer(b) and b < 0
  end
  defp check_default_4(a, b) when is_integer(a) and is_integer(b), do: :ok

  @spec check_default_5(pos_integer, neg_integer) :: :ok
  # def check_default_5(a, b)
  guard check_default_5(a, b \\ -1) do
    a > 0 and b < 0
  end
  guard check_default_5(a, b) do
    is_integer(a) and is_integer(b)
  end
  def check_default_5(a, b) when is_integer(a) and is_integer(b), do: :ok

  @spec all?(t) :: boolean
  @spec all?(t, (element -> as_boolean(term))) :: boolean
  guard all?(_collection, fun \\ fn(x) -> x end), do: is_function(fun)

  def all?(collection, fun) when is_list(collection) do
    do_all?(collection, fun)
  end

  def all?(collection, fun) do
    Enumerable.reduce(collection, {:cont, true}, fn(entry, _) ->
      if fun.(entry), do: {:cont, true}, else: {:halt, false}
    end) |> elem(1)
  end

  defp do_all?([h|t], fun) do
    if fun.(h) do
      do_all?(t, fun)
    else
      false
    end
  end

  defp do_all?([], _) do
    true
  end


  ########################
  # TEST check_default_*

  test "check_default_1" do
    assert check_default_1(3) == :ok
    assert check_default_1(3, -1) == :ok
    assert_raise FunctionClauseGuardError,
      ~r{no function clause matching the guard in},
      fn -> check_default_1(3, 1) end
  end

  test "check_default_2B" do
    assert check_default_2B(3) == :ok
    assert check_default_2B(3, -1) == :ok
    assert_raise FunctionClauseGuardError,
      ~r{no function clause matching the guard in},
      fn -> check_default_2B(3, 1) end
  end

  test "check_default_3" do
    assert check_default_3(3) == :ok
    assert check_default_3(3, -1) == :ok
    assert_raise FunctionClauseGuardError,
      ~r{no function clause matching the guard in},
      fn -> check_default_3(3, 1) end
  end

  test "check_default_4" do
    assert check_default_4(3) == :ok
    assert check_default_4(3, -1) == :ok
    assert_raise FunctionClauseGuardError,
      ~r{no function clause matching the guard in},
      fn -> check_default_4(3, 1) end
  end

  test "check_default_5" do
    assert check_default_5(3) == :ok
    assert check_default_5(3, -1) == :ok
    assert_raise FunctionClauseGuardError,
      ~r{no function clause matching the guard in},
      fn -> check_default_5(3, 1) end
  end

  test :all? do
    assert Enum.all?([2, 4, 6], fn(x) -> rem(x, 2) == 0 end)
    refute Enum.all?([2, 3, 4], fn(x) -> rem(x, 2) == 0 end)

    assert Enum.all?([2, 4, 6])
    refute Enum.all?([2, nil, 4])

    assert Enum.all?([])

    assert_raise FunctionClauseGuardError,
      fn -> all?([1, 2, 3], "bitstring") end

  end

  #########################
  # PASSING TEST FUCNTIONS

  # Single when clause + do block
  @spec check_1(pos_integer, neg_integer) :: :ok
  guard check_1(a, b) when is_integer(a) do
     a > 0 and is_integer(b) and b < 0
  end
  def check_1(a, b) when is_integer(a) and is_integer(b), do: :ok

  @spec check_2(pos_integer, neg_integer) :: :ok
  guardp check_2(a, b) when is_integer(a) and is_integer(b) do
     a > 0 and b < 0
  end
  defp check_2(a, b) when is_integer(a) and is_integer(b), do: :ok

  # Multiple when clause + do block
  @spec check_3(pos_integer, neg_integer) :: :ok
  guard check_3(a, b) when (is_integer(a) and a > 0) when is_integer(b)  do
     b < 0
  end
  def check_3(a, b) when is_integer(a) and is_integer(b), do: :ok

  @spec check_4(pos_integer, neg_integer) :: :ok
  guardp check_4(a, b) do
    (is_integer(a)) and (is_integer(b)) and (a > 0) and (b < 0) and
    a > b
  end
  defp check_4(a, b) when is_integer(a) and is_integer(b), do: :ok

  @spec check_5(pos_integer, neg_integer) :: :ok
  guard check_5(a, b) when ({:foo, [line: 0], [a, 2]} == {:foo, [line: 0], [a, 2]}) when (2 == 2) when (3 == 3) when (4 == 4) do
    is_integer(a) and a > 0 and is_integer(b) and b < 0
  end
  def check_5(a, b) when is_integer(a) and is_integer(b), do: :ok

  @spec check_6(pos_integer, neg_integer) :: :ok
  guardp check_6(a, b) do
    is_integer(a) and a > 0 and is_integer(b) and b < 0
  end
  defp check_6(a, b) when is_integer(a) and is_integer(b), do: :ok

  @spec check_7(pos_integer, neg_integer) :: :ok
  guard check_7(a, b) when ("a" == "a") do
    is_integer(a) and a > 0 and is_integer(b) and b < 0
  end
  def check_7(a, b) when is_integer(a) and is_integer(b), do: :ok

  # no when clause
  @spec check_10(pos_integer, neg_integer) :: :ok
  guardp check_10(a, b), do: is_integer(a) and (a > 0) and is_integer(b) and (b < 0)
  defp check_10(_a, _b), do: :ok

  @spec sum_positives(pos_integer, pos_integer) :: pos_integer
  guard sum_positives(a, b), do: is_integer(a) and is_integer(b)
  guard sum_positives(a, b), do: a > 0 and b > 0
  def sum_positives(a, b), do: a + b

  # multiple guard declarations
#  @spec atom_xor_bitstring(atom | String.t, atom | String.t) :: {:atom, String.t} | {String.t, :atom}
#  guard atom_xor_bitstring(a, b) when is_atom(a) and is_bitstring(b), do: a == :atom and b == "bitstring"
#  guard atom_xor_bitstring(a, b) when is_bitstring(a) and is_atom(b), do: a == "bitstring" and b == :atom
#  def atom_xor_bitstring(a, b), do: {a, b}

  @spec atom_xor_bitstring(atom | String.t, atom | String.t) :: {:atom, String.t} | {String.t, :atom}
  guardp atom_xor_bitstring(a, b) do
    (is_atom(a) and is_bitstring(b) and a == :atom and b == "bitstring") or
    (is_bitstring(a) and is_atom(b) and a == "bitstring" and b == :atom)
  end
  defp atom_xor_bitstring(a, b), do: {a, b}

  ###################
  # guards that will always fail

  @spec check_101(pos_integer, neg_integer) :: :ok
  guard check_101(a, b) when is_integer(a) do
    1 == 2 and
    is_integer(a) and a > 0 and is_integer(b) and b < 0
  end
  def check_101(a, b) when is_integer(a) and is_integer(b) do
    :ok
  end

  @spec check_102(pos_integer, neg_integer) :: :ok
  guardp check_102(a, _b) when not (1 == 2) when not(3 == 4) when is_integer(a)  do
    1 == 2
  end
  defp check_102(a, b) when is_integer(a) and is_integer(b), do: :ok

  @spec check_103(pos_integer, neg_integer) :: :ok
  guard check_103(a, b) do
    not( is_integer(a) and a > 0 and is_integer(b) and b < 0 )
  end
  def check_103(a, b) when is_integer(a) and is_integer(b), do: :ok

  @spec check_104(pos_integer, neg_integer) :: :ok
  guardp check_104(a, b)
  when (1 == 1 and 2 == 2 and "a" == "a")
  when (3 == 3)
  when (is_integer(a) and a > 0 and is_integer(b) and b < 0) do
    is_integer(a) and a > 0 and is_integer(b) and b < 0 and false == true
  end
  defp check_104(a, b) when is_integer(a) and is_integer(b), do: :ok

  @spec check_105(pos_integer, neg_integer) :: :ok
  guardp check_105(a, b) when (1 == 1) do
    is_integer(a) and a > 0 and is_integer(b) and b < 0 and
    nil == false
  end
  defp check_105(a, b) when is_integer(a) and is_integer(b), do: :ok

  @spec check_106(neg_integer, neg_integer) :: :ok
  guardp check_106(a, b) when (1 == 1) do
    is_integer(a) and a < 0 and is_integer(b) and b < 0
  end
  defp check_106(_, _), do: :error


  ################
  # TESTS

  test "assert number 1" do
    assert check_1(3, -1) == :ok
    assert_raise FunctionClauseGuardError,
      ~r{no function clause matching the guard in},
      fn -> check_1(3, 1) end
  end

  test "assert number 2" do
    assert check_2(3, -1) == :ok
    assert_raise FunctionClauseGuardError,
      ~r{no function clause matching the guard in},
      fn -> check_2(3, 1) end
  end

  test "assert number 3" do
    assert check_3(3, -1) == :ok
    assert_raise FunctionClauseGuardError,
      ~r{no function clause matching the guard in},
      fn -> check_3(3, 1) end
  end

  test "assert number 4" do
    assert check_4(3, -1) == :ok
    assert_raise FunctionClauseGuardError,
      ~r{no function clause matching the guard in},
      fn -> check_4(3, 1) end
  end

  test "assert number 5" do
    assert check_5(3, -1) == :ok
    assert_raise FunctionClauseGuardError,
      ~r{no function clause matching the guard in},
      fn -> check_5(3, 1) end
  end

  test "assert number 6" do
    assert check_6(3, -1) == :ok
    assert_raise FunctionClauseGuardError,
      ~r{no function clause matching the guard in},
      fn -> check_6(3, 1) end
  end

  test "assert number 7" do
    assert check_7(3, -1) == :ok
    assert_raise FunctionClauseGuardError,
      ~r{no function clause matching the guard in},
      fn -> check_7(3, 1) end
  end

  test "assert number 10" do
    assert check_10(3, -1) == :ok
    assert_raise FunctionClauseGuardError,
      ~r{no function clause matching the guard in},
      fn -> check_10(3, 1) end
  end


  test "assert number 101" do
    assert_raise FunctionClauseGuardError,
      ~r{no function clause matching the guard in},
      fn -> check_101(3, -1) end
  end

  test "assert number 102" do
    assert_raise FunctionClauseGuardError,
      ~r{no function clause matching the guard in},
      fn -> check_102(3, -1) end
  end

  test "assert number 103" do
    assert_raise FunctionClauseGuardError,
      ~r{no function clause matching the guard in},
      fn -> check_103(3, -1) end
  end

  test "assert number 104" do
    assert_raise FunctionClauseGuardError,
      ~r{no function clause matching the guard in},
      fn -> check_104(3, -1) end
  end

  test "assert number 105" do
    assert_raise FunctionClauseGuardError,
      ~r{no function clause matching the guard in},
      fn -> check_105(3, -1) end
  end


  test "assert_raise number 1" do
    assert_raise FunctionClauseGuardError,
      ~r{no function clause matching the guard in},
      fn -> check_1(3, 1) end
  end

  test "assert_raise number 2" do
    assert_raise FunctionClauseGuardError,
      ~r{no function clause matching the guard in},
      fn -> check_2(3, 1) end
  end

  test "assert_raise number 3" do
    assert_raise FunctionClauseGuardError,
      ~r{no function clause matching the guard in},
      fn -> check_3(3, 1) end
  end

  test "assert_raise number 4" do
    assert_raise FunctionClauseGuardError,
      ~r{no function clause matching the guard in},
      fn -> check_4(3, 1) end
  end

  test "assert_raise number 5" do
    assert_raise FunctionClauseGuardError,
      ~r{no function clause matching the guard in},
      fn -> check_5(3, 1) end
  end

  test "assert_raise number 6" do
    assert_raise FunctionClauseGuardError,
      ~r{no function clause matching the guard in},
      fn -> check_6(3, 1) end
  end

  test "assert_raise number 7" do
    assert_raise FunctionClauseGuardError,
      ~r{no function clause matching the guard in},
      fn -> check_7(3, 1) end
  end

  test "assert_raise number 106" do
    assert check_106(-3, -1) == :error
  end

  test "atom_xor_bitstring" do
    assert atom_xor_bitstring(:atom, "bitstring") == {:atom, "bitstring"}
    assert atom_xor_bitstring("bitstring", :atom) == {"bitstring", :atom}
    assert_raise FunctionClauseGuardError,
      ~r{no function clause matching the guard in},
      fn -> atom_xor_bitstring(:foo, "bar")
    end
  end

  test "Access public and private guards" do
    import CompileAssertion
    assert_compile_fail CompileError,
      "undefined function check_2/2",
      """
      defmodule AccessPublicAndPrivateGuards do
        import Experimental.KernelGuardTest

        # this one won't fail since it's public
        check_1(3, -1)

        # but this one will fail
        check_2(3, -1)
      end
      """
  end


  test "raise when no when clause and no do block were given" do
    import CompileAssertion
    assert_compile_fail CompileError,
      "nofile: compile error - guard/2 cannot be defined without a 'do' block",
      """
      defmodule NoWhenClauseAndNoDoBlock do
        import Experimental.KernelGuard

        # no when clause and no do block should fail
        guard check_107(a, b)
      end
      """
  end


  test "nothing defined" do
    import CompileAssertion
    assert_compile_fail CompileError,
      "nofile: compile error - guard/2 cannot be defined without a 'do' block",
      """
      defmodule NothingDefined do
        import Experimental.KernelGuard
        guard check_nothing_defined(a, b)
      end
      """
  end

  test "no do block 108" do
    import CompileAssertion

    # this one checks that a == a and b == b
    assert_compile_fail CompileError,
      "nofile: compile error - guard/2 cannot be defined without a 'do' block",
      """
      defmodule NoDoBlock108 do
        import Experimental.KernelGuard

        @spec check_108(pos_integer, neg_integer) :: :ok
        guardp check_108(a, b) when (b < 0)
      end
      """
  end

  test "no do block 109" do
    import CompileAssertion

    # this one checks that a == a and b == b
    assert_compile_fail CompileError,
      "nofile: compile error - guard/2 cannot be defined without a 'do' block",
      """
      defmodule NoDoBlock109 do
        import Experimental.KernelGuard

        @spec check_109(pos_integer, neg_integer) :: :ok
        guard check_109(a, b) when is_integer(a)
      end
      """
  end


  ########################
  # Multiple clauses

  #@spec multiple_clauses(pos_integer, neg_integer) :: :ok
  guardp multiple_clauses(a, _b) when is_integer(a), do: a > 0
  guardp multiple_clauses(_a, b) when is_integer(b), do: b > 0
  defp multiple_clauses(_a, _b), do: :ok

  test "multiple_clauses" do
    assert multiple_clauses(3, 1) == :ok
    assert_raise FunctionClauseGuardError,
      ~r{no function clause matching the guard in},
      fn -> multiple_clauses(3, 0) end
    assert_raise FunctionClauseGuardError,
      ~r{no function clause matching the guard in},
      fn -> multiple_clauses(-1, 1) end
  end

  ##########################
  # Other cases

  require Integer

  @spec both_even_or_odd(number, number) :: :ok
  guard both_even_or_odd(a, b) when is_integer(a) and is_integer(b) do
    Integer.is_even(a) and Integer.is_even(b) or Integer.is_odd(a) and Integer.is_odd(b)
  end

  guard both_even_or_odd(a, b) when is_float(a) and is_float(b) do
    (a / 2) - trunc(a / 2) == 0.0 and (b / 2) - trunc(b / 2) == 0.0
    or
    (a / 2) - trunc(a / 2) != 0.0 and (b / 2) - trunc(b / 2) != 0.0
  end

  def both_even_or_odd(a, b) when is_number(a) and is_number(b) do
    :ok
  end

  test "both_even_or_odd/2" do
    assert both_even_or_odd(3, -1) == :ok
    assert both_even_or_odd(3, 1) == :ok
    assert_raise FunctionClauseGuardError,
      ~R{no function clause matching the guard in Experimental.KernelGuardTest.guard/2},
      fn ->
        both_even_or_odd(3, 0)
      end

    assert_raise FunctionClauseGuardError,
      ~R{no function clause matching the guard in Experimental.KernelGuardTest.guard/2},
      fn ->
        both_even_or_odd(3.0, 0.0)
      end

    assert_raise FunctionClauseError,
      ~R{no function clause matching in Experimental.KernelGuardTest.both_even_or_odd/2},
      fn ->
        both_even_or_odd("3", "1")
      end
  end

  # Default value
  @spec check_default(pos_integer, neg_integer) :: :ok
  guard check_default(a, b \\ -1) when 1 == 1 when 2 == 2 do
    is_integer(a) and a > 0 and is_integer(b) and b < 0
  end
  def check_default(a, b) when is_integer(a) and is_integer(b) do
    b
  end

  test "check_default/2" do
    assert check_default(3) == -1
    assert check_default(3, -1) == -1
    assert check_default(3, -2) == -2
  end


  # Pattern matching
  @spec pattern_matching(list) :: tuple
  guard pattern_matching(list = [h|t]) do
    is_integer(h) and is_list(t) and length(list) == 3
  end
  def pattern_matching(list = [h|t]) do
    {h, t, list}
  end

  test "pattern_matching/2" do
    assert pattern_matching([1, 2, 3]) == {1, [2, 3], [1, 2, 3]}

    assert_raise FunctionClauseGuardError,
      ~R{no function clause matching the guard in Experimental.KernelGuardTest.guard/2},
      fn ->
        pattern_matching([1, 2, 3, 4])
      end

    assert_raise FunctionClauseError,
      fn ->
        pattern_matching({1, 2, 3, 4})
      end
  end

end
