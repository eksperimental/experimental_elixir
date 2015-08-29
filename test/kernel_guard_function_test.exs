defmodule Experimental.KernelGuardFunctionTest do
  use ExUnit.Case, async: true
  doctest Experimental.KernelGuardFunction, import: true
  
  import Experimental.KernelGuardFunction

  test "is_neg_integer/1" do
    assert is_neg_integer(-1) == true
    refute is_neg_integer(0)  == true
    refute is_neg_integer(1)  == true
  end

  test "is_pos_integer/1" do
    refute is_pos_integer(-1) == true
    refute is_pos_integer(0)  == true
    assert is_pos_integer(1)  == true
  end

  test "is_non_neg_integer/1" do
    refute is_non_neg_integer(-1) == true
    assert is_non_neg_integer(0)  == true
    assert is_non_neg_integer(1)  == true
  end

  test "is_non_pos_integer/1" do
    assert is_non_pos_integer(-1) == true
    assert is_non_pos_integer(0)  == true
    refute is_non_pos_integer(1)  == true
  end


  def fun_is_neg_integer(term) when is_neg_integer(term),         do: :neg_integer
  def fun_is_neg_integer(_term),                                  do: :error

  def fun_is_pos_integer(term) when is_pos_integer(term),         do: :pos_integer
  def fun_is_pos_integer(_term),                                  do: :error

  def fun_is_non_neg_integer(term) when is_non_neg_integer(term), do: :non_neg_integer
  def fun_is_non_neg_integer(_term),                              do: :error

  def fun_is_non_pos_integer(term) when is_non_pos_integer(term), do: :non_pos_integer
  def fun_is_non_pos_integer(_term),                              do: :error

  test "integer guard functions" do
    assert fun_is_neg_integer(-1) == :neg_integer
    assert fun_is_neg_integer(0)  == :error
    assert fun_is_neg_integer(1)  == :error

    assert fun_is_pos_integer(-1) == :error
    assert fun_is_pos_integer(0)  == :error
    assert fun_is_pos_integer(1)  == :pos_integer

    assert fun_is_non_neg_integer(-1) == :error
    assert fun_is_non_neg_integer(0)  == :non_neg_integer
    assert fun_is_non_neg_integer(1)  == :non_neg_integer

    assert fun_is_non_pos_integer(-1) == :non_pos_integer
    assert fun_is_non_pos_integer(0)  == :non_pos_integer
    assert fun_is_non_pos_integer(1)  == :error
  end


  def fun_is_byte(term) when is_byte(term), do: :ok
  def fun_is_byte(_term),                   do: :error

  test "is_byte/1" do
    list_ok    = [0, 1, 255]
    list_error = [-1, 256, 1000]

    for x <- list_ok do
      assert is_byte(x)     == true
      assert fun_is_byte(x) == :ok
    end

    for x <- list_error do
      refute is_byte(x)     == true
      refute fun_is_byte(x) == :ok
    end
  end


  def fun_is_char(term) when is_char(term), do: :ok
  def fun_is_char(_term),                   do: :error

  test "is_char/1" do
    list_ok    = [0, 1, 255, 0x10ffff, 1114111]
    list_error = [-100, -1, 0x110000, 1114112, 1_000_000_000]

    for x <- list_ok do
      assert is_char(x)     == true
      assert fun_is_char(x) == :ok
    end

    for x <- list_error do
      refute is_char(x)     == true
      refute fun_is_char(x) == :ok
    end
  end

end
