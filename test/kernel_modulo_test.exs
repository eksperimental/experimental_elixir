defmodule Experimental.KernelModuloTest do
  use ExUnit.Case, async: true
  doctest Experimental.KernelModulo, import: true
  import Experimental.KernelModulo

  test "modulo: number positive, modulus positive" do
    assert mod(13, 42)  == 13
    assert mod(13, 13)  == 0
    assert mod(13,  5)  == 3
    assert mod(13,  1)  == 0

    assert mod( 1, 13)  == 1
    assert mod( 1,  5)  == 1
    assert mod( 1,  1)  == 0
  end

  test "modulo: number negative, modulus positive" do
    assert mod(-13, 42)  == 29
    assert mod(-13, 13)  == 0
    assert mod(-13,  5)  == 2
    assert mod(-13,  1)  == 0

    assert mod(-1, 13)  == 12
    assert mod(-1,  5)  == 4
    assert mod(-1,  1)  == 0
  end

  test "modulo: number positive, modulus negative" do
    assert mod(13, -42)  == -29
    assert mod(13, -13)  == 0
    assert mod(13, -5 )  == -2
    assert mod(13, -1 )  == 0

    assert mod( 1, -13)  == -12
    assert mod( 1, -5 )  == -4
    assert mod( 1, -1 )  == 0
  end

  test "modulo: number negative, modulus negative" do
    assert mod(-13, -42) == -13
    assert mod(-13, -13) == 0
    assert mod(-13, -5 ) == -3
    assert mod(-13, -1 ) == -0

    assert mod(-1, -13)  == -1
    assert mod(-1, -5 )  == -1
    assert mod(-1, -1 )  == 0
  end

  test "modulo: modulus 0" do
    assert_raise ArithmeticError, fn ->
      mod(13, 0)
    end
    assert_raise ArithmeticError, fn ->
      mod(-13, 0)
    end
    assert_raise ArithmeticError, fn ->
      mod(1, 0)
    end
    assert_raise ArithmeticError, fn ->
      mod(-1, 0)
    end
    assert_raise ArithmeticError, fn ->
      mod(0, 0)
    end
  end

  test "modulo: number 0" do
    assert mod(0,  13)  == 0
    assert mod(0, -13)  == 0
    assert mod(0,  1)   == 0
    assert mod(0, -1)   == 0
    assert_raise ArithmeticError, fn ->
      mod(0,  0)
    end
  end

  test "modulo: number 1" do
    assert mod(1,  13)  == 1
    assert mod(1, -13)  == -12
    assert mod(1,  1)   == 0
    assert mod(1, -1)   == 0
    assert_raise ArithmeticError, fn ->
      mod(1,  0)
    end
  end

  test "modulo: number -1" do
    assert mod(-1,  13)  == 12
    assert mod(-1, -13)  == -1
    assert mod(-1,  1)   == 0
    assert mod(-1, -1)   == 0
    assert_raise ArithmeticError, fn ->
      mod(-1,  0)
    end
  end

  test "modulo: modulus odd" do
    assert mod( 42,  2)  == 0
    assert mod( 42, -2)  == 0
    assert mod(-43,  2)  == 1
    assert mod(-43, -2)  == -1

    assert mod( 42,  4)  == 2
    assert mod( 42, -4)  == -2
    assert mod(-43,  4)  == 1
    assert mod(-43, -4)  == -3

    assert mod( 42,  100)  == 42
    assert mod( 42, -100)  == -58
    assert mod(-43,  100)  == 57
    assert mod(-43, -100)  == -43
    
    assert_raise ArithmeticError, fn ->
      mod( 42,  0)
    end
    assert_raise ArithmeticError, fn ->
      mod(-42,  0)
    end

    assert_raise ArithmeticError, fn ->
      mod( 43,  0)
    end
    assert_raise ArithmeticError, fn ->
      mod(-43,  0)
    end
  end

  test "modulo: modulus even" do
    assert mod( 42,  3)  == 0
    assert mod( 42, -3)  == 0
    assert mod(-42,  3)  == 0
    assert mod(-42, -3)  == 0
    assert mod( 43,  3)  == 1
    assert mod( 43, -3)  == -2
    assert mod(-43,  3)  == 2
    assert mod(-43, -3)  == -1

    assert mod( 42,  13)  == 3
    assert mod( 42, -13)  == -10
    assert mod(-42,  13)  == 10
    assert mod(-42, -13)  == -3
    assert mod( 43,  13)  == 4
    assert mod( 43, -13)  == -9
    assert mod(-43,  13)  == 9
    assert mod(-43, -13)  == -4

    assert mod( 42,  99)  == 42
    assert mod( 42, -99)  == -57
    assert mod(-42,  99)  == 57
    assert mod(-42, -99)  == -42
    assert mod( 43,  99)  == 43
    assert mod( 43, -99)  == -56
    assert mod(-43,  99)  == 56
    assert mod(-43, -99)  == -43

    assert mod( 42,  1)  == 0
    assert mod( 42, -1)  == 0
    assert mod(-42,  1)  == 0
    assert mod(-42, -1)  == 0
    assert mod( 43,  1)  == 0
    assert mod( 43, -1)  == 0
    assert mod(-43,  1)  == 0
    assert mod(-43, -1)  == 0
  end

  test "invalid arguments" do
    assert_raise FunctionClauseError, fn ->
      mod("", "")
    end
    assert_raise FunctionClauseError, fn ->
      mod(nil, nil)
    end
    assert_raise FunctionClauseError, fn ->
      mod(:atom, 10)
    end
    assert_raise FunctionClauseError, fn ->
      mod(10, :atom)
    end
    assert_raise FunctionClauseError, fn ->
      mod(1.2, 3)
    end
    assert_raise FunctionClauseError, fn ->
      mod(1, 2.3)
    end
    assert_raise FunctionClauseError, fn ->
      mod(1.2, 2.3)
    end
  end
end
