defmodule Experimental.KernelModulo do
  @doc """
  Modulo operation.

  Returns the remainder after division of `number` by `modulus`.
  Unlike `Kernel.rem/2`, `Kernel.mod/2` will always return `0` or a positive integer.

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
    ** (FunctionClauseError) no function clause matching in Experimental.KernelModulo.mod/2

  """
  @spec mod(integer, integer) :: non_neg_integer
  def mod(number, modulus) when is_integer(number) and is_integer(modulus) do
    rem(number, modulus) |> normalize_mod(modulus)
  end

  defp normalize_mod(remainder, modulus) when remainder < 0 and modulus < 0,
    do: abs(remainder)
  defp normalize_mod(remainder, modulus) when remainder < 0,
    do: remainder + modulus
  defp normalize_mod(remainder, _modulus),
    do: remainder
end