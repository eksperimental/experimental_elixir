defmodule Experimental.KernelModulo do
  @doc """
  Modulo operation.

  Returns the remainder after division of `number` by `modulus`.
  The sign of the result will always be the same sign as the `modulus`.

  More information: [Modulo operation](https://en.wikipedia.org/wiki/Modulo_operation) on Wikipedia.

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
    -9
    iex> mod(-17, -13)
    -4

    iex> mod(17, 26)
    17
    iex> mod(-17, 26)
    9
    iex> mod(17, -26)
    -9
    iex> mod(-17, -26)
    -17

    iex> mod(17, 0)
    ** (ArithmeticError) bad argument in arithmetic expression

    iex> mod(1.5, 2)
    ** (FunctionClauseError) no function clause matching in Experimental.KernelModulo.mod/2

  """
  @spec mod(integer, integer) :: non_neg_integer
  def mod(number, modulus) when is_integer(number) and is_integer(modulus) do
    case rem(number, modulus) do
      remainder when remainder > 0 and modulus < 0 or remainder < 0 and modulus > 0 ->
        remainder + modulus
      remainder ->
        remainder
    end
  end
end