defmodule Experimental.EnumPad do
  require Logger
  
  @type t :: Enumerable.t

  @doc """
  Pads `collection` with `padding` until it reaches `size`.

  If `size` is smaller or equal than the length of `collection`, then
  `collection` is return unchanged.

  If `padding` is a function, it will take the last evaluated element
  in then collection as the only one argument. 

  ## Examples
    iex> Enum.pad([1, 2, 3], 5)
    [1, 2, 3, nil, nil]
    
    iex> Enum.pad([:a, :b, :c], 5, :z)
    [:a, :b, :c, :z, :z]
    
    iex> Enum.pad([1, 2, 3], 5, &(&1+10))
    [1, 2, 3, 13, 23]
    
    iex> Enum.pad([1, 2, 3], 2)
    [1, 2, 3]

  """
  @spec pad(t, pos_integer, any) :: [any]
  def pad(collection, size,  padding \\ nil)

  def pad([], size, _padding) when is_integer(size),
    do: []

  def pad(col, size, _padding) when is_list(col) and is_integer(size) and size <= length(col),
    do: col

  def pad(col, size, fun) when is_function(fun) and is_list(col)
    and is_integer(size) and size > length(col)
    do
      start = length(col) + 1
      [last_elem] = Enum.take(col, -1)
      Enum.reduce(start..size, {last_elem, Enum.reverse(col)}, fn(_n, {prev, acc}) ->
        cur = fun.(prev)
        {cur, [cur | acc]}
      end)
      |> elem(1)
      |> Enum.reverse
  end

  def pad(col, size, padding) when is_list(col) and is_integer(size) and size > length(col) do
    Stream.cycle([padding])
    |> Enum.take(size - length(col))
    |> Enum.into(col)
  end

end