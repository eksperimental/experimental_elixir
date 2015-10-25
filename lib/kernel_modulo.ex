defmodule Experimental.KernelModulo do
  @doc """
  Modulo operation

  Returns the remainder after division of `number` by `modulus`.
  It returns 0 or a positive integer.

  More information: https://en.wikipedia.org/wiki/Modulo_operation

  ## Examples

    iex> mod(17, 17)
    0
    iex> mod(17, 1)
    0

    iex> mod(17, 13)
    4
    iex> mod(-17, 13)
    9
    iex> mod(17, -13)
    4
    iex> mod(-17, -13)
    4

    iex> mod(17, 26)
    17
    iex> mod(-17, 26)
    9
    iex> mod(17, -26)
    17
    iex> mod(-17, -26)
    17

    iex> mod(17, 0)
    ** (ArithmeticError) bad argument in arithmetic expression

    iex> mod(1.5, 2)
    ** (FunctionClauseError) no function clause matches

  """
  @spec mod(integer, integer) :: non_neg_integer
  def mod(number, modulus)

  def mod(_number, 0), do:
    raise ArithmeticError, message: "bad argument in arithmetic expression"

  def mod(number, modulus) when not is_integer(number) or not is_integer(modulus), do:
    raise FunctionClauseError
  
  def mod(0, _modulus), do: 0
  def mod(_number, 1),  do: 0
  def mod(_number, -1), do: 0

  # Optimizations
  def mod(number, modulus) when abs(number) == abs(modulus),          do: 0
  def mod(number, modulus) when number > 0 and number < abs(modulus), do: number
  def mod(number, modulus) when number > 0 and modulus < 0 and number > abs(modulus) do
    mod(number, abs(modulus))
  end

  def mod(number, modulus) when number > 0 do
    rem(number, modulus)
  end

  def mod(number, modulus) when number < 0 and modulus > 0 do
    n = (div(abs(number), modulus) + 1) * modulus + number
    mod(n, modulus)
  end

  def mod(number, modulus) when number < 0 and modulus < 0 do
    mod(abs(number), abs(modulus))
  end

end