defmodule Experimental.KernelStruct do

  @doc """
  Returns `true` if the given argument is a struct.

  ## Examples

      iex> struct?(1..3)
      true

      iex> struct?([msg: "keyword lists are not structs"])
      false

  """
  @spec struct?(term) :: boolean
  def struct?(term) when not is_map(term), do: false
  def struct?(%{__struct__: _}), do: true
  def struct?(_term), do: false

  @doc """
  Returns `true` if the given argument is a struct and it belongs to
  `kind`.

  ## Examples

      iex> struct?(1..3, Range)
      true

      iex> struct?(%{:msg => "maps are structs"}, Map)
      false

      iex> struct?([msg: "keyword lists are not structs"])
      false

  """
  @spec struct?(term, atom) :: boolean
  def struct?(term, kind) when not (is_map(term) and is_atom(kind)), do: false
  def struct?(%{__struct__: k}, kind) when k == kind, do: true
  def struct?(_term, _kind), do: false
end