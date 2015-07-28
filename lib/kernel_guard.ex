defmodule Experimental.KernelGuard do

  @doc """
  Returns `true` if `term` is a negative integer (ie. term < 0); otherwise returns `false`.

  Allowed in guard tests. Inlined by the compiler.
  """
  @spec is_neg_integer(term) :: boolean
  #def is_neg_integer(term) do
  #  :erlang.andalso(:erlang.is_integer(term), :erlang.<(term, 0))
  #end
  defmacro is_neg_integer(term) do
    quote do: is_integer(unquote(term)) and unquote(term) < 0
  end

  @doc """
  Returns `true` if `term` is a non negative integer (ie. term >= 0); otherwise returns `false`.

  Allowed in guard tests. Inlined by the compiler.
  """
  @spec is_non_neg_integer(term) :: boolean
  #def is_non_neg_integer(term) do
  #  :erlang.andalso(:erlang.is_integer(term), :erlang.>=(term, 0))
  #end
  defmacro is_non_neg_integer(term) do
    quote do: is_integer(unquote(term)) and unquote(term) >= 0
  end

  @doc """
  Returns `true` if `term` is a non positive integer (ie. term <= 0); otherwise returns `false`.

  Allowed in guard tests. Inlined by the compiler.
  """
  @spec is_non_pos_integer(term) :: boolean
  #def is_non_pos_integer(term) do
  #  :erlang.andalso(:erlang.is_integer(term), :erlang."=<"(term, 0))
  #end
  defmacro is_non_pos_integer(term) do
    quote do: is_integer(unquote(term)) and unquote(term) <= 0
  end

  @doc """
  Returns `true` if `term` is a positive integer (ie. term > 0); otherwise returns `false`.

  Allowed in guard tests. Inlined by the compiler.
  """
  @spec is_pos_integer(term) :: boolean
  #def is_pos_integer(term) do
  #  :erlang.andalso(:erlang.is_integer(term), :erlang.>(term, 0))
  #end
  defmacro is_pos_integer(term) do
    quote do: is_integer(unquote(term)) and unquote(term) > 0
  end

  @doc """
  Returns `true` if `term` is an integer >= 0 and <= 255; otherwise returns `false`.

  Allowed in guard tests.
  """
  @spec is_byte(term) :: boolean
  defmacro is_byte(term) do
    quote do
      is_non_neg_integer(unquote(term)) and unquote(term) <= 255
    end
  end

  @doc """
  Returns `true` if `term` is a char (ie. 0..0x10ffff).

  Allowed in guard tests.
  """
  @spec is_char(term) :: boolean
  defmacro is_char(term) do
    quote do
      is_non_neg_integer(unquote(term)) and unquote(term) in 0..0x10ffff
    end
  end

end