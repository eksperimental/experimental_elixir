defmodule Experimental.EnumPad do
  @type t :: Enumerable.t

  @doc ~S"""
  Pads `enumerable` with the elements from `padding` until it
  reaches `size`.

  If `size` is smaller or equal than the length of `enumerable`, then
  `enumerable` is return unchanged.

  If `padding` is a function, it will take the last evaluated element
  in the enumerable as the argument.

  The zipping finishes as soon as there are no more padding elements
  to be used.

  If no `padding` is provided, it will fill the enumerable with `nil`.

  ## Examples
    iex> pad([1, 2, 3], 5)
    [1, 2, 3, nil, nil]
    
    iex> pad([:a, :b, :c], 5, Stream.cycle([:z]))
    [:a, :b, :c, :z, :z]
    
    iex> pad([1, 2, 3], 5, &(&1+10))
    [1, 2, 3, 13, 23]
    
    iex> pad([1, 2, 3], 2)
    [1, 2, 3]

    iex> pad([1, 2, 3], 6, 50..100)
    [1, 2, 3, 50, 51, 52]

    iex> pad([1, 2, 3], 10, Stream.cycle([0, 1]))
    [1, 2, 3, 0, 1, 0, 1, 0, 1, 0]

    iex> pad([:a, :aN], 4, &("#{&1}" |> String.reverse
    ...> |> String.duplicate(2) |> String.to_atom ))
    [:a, :aN, :NaNa, :aNaNaNaN]

  """
  @spec pad(t, pos_integer, t | (any -> any)) :: [any]
  def pad(enumerable, size,  padding \\ Stream.cycle([nil])) do
    count = Enum.count(enumerable)

    cond do
      size <= count ->
        Enum.to_list(enumerable)

      # streams are caught as functions by the guard,
      # and are also enumerables
      is_function(padding) and not enumerable?(padding) ->
        do_pad_with_function(enumerable, size, padding)

      true ->
        do_pad_with_enumerable(enumerable, size, padding)
    end
  end

  @doc """
  Returns `true` if the given `term` is an enumerable.

  ## Examples
    iex> enumerable?([1, 2, 3])
    true

    iex> enumerable?(1..3)
    true

    iex> enumerable?(Stream.cycle([:elixir]))
    true

    iex> enumerable?({:elixir})
    false

    iex> enumerable?(1)
    false

  """
  @spec enumerable?(term) :: boolean
  def enumerable?(term) do
    try do
      Enum.take(term, 1)
    rescue
      _ -> false
    else
      _ -> true
    end
  end

  defp do_pad_with_enumerable(enum, size, padding) do
    padding
    |> Enum.take(size - Enum.count(enum))
    |> Enum.into(Enum.to_list(enum))
  end

  defp do_pad_with_function(enum, size, fun) do
    count = Enum.count(enum)
    start = count + 1

    if count == 0 do
      last_elem = nil
    else
      [last_elem] = Enum.take(enum, -1)
    end

    Enum.reduce(start..size, {last_elem, Enum.reverse(enum)},
      fn(_n, {prev, acc}) ->
        cur = fun.(prev)
        {cur, [cur | acc]}
      end)
    |> elem(1)
    |> Enum.reverse
  end

  @doc """
  Shortcut for `pad_zip(enumerable1, enumerable1, padding, padding)`.

  For more information, see `pad_zip/4`.

  ## Examples
    # Stream.cycle([nil]) is used as the default padding
    iex(13)> pad_zip(1..5, [:a])
    [{1, :a}, {2, nil}, {3, nil}, {4, nil}, {5, nil}]

    # Zipping finished earlier because pading is not long enough 
    iex(12)> pad_zip(1..5, [:a], [nil])
    [{1, :a}, {2, nil}]

  """
  @spec pad_zip(t, t, t | (any -> any)) :: [{any, any}]
  def pad_zip(enumerable1, enumerable2, padding \\ Stream.cycle([nil])) do
    pad_zip(enumerable1, enumerable2, padding, padding)
  end

  @doc ~S"""
  Pads enumerables with the elements from `padding` until it
  reaches `size`.

  The paddings can be either enumerables, or a function with arity 1.
  If `padding` is a function, it will take the last evaluated element
  in then enumerable as the only one argument.

  Once enumerables have been padded, they will be zipped into one list
  of tuples.

  If one enumerable is shorther than the other, it will be filled with
  padding, provided there are enough padding elements. The zipping
  will finish as soon as there are no more padding elements to be used.

  For more information about how the padding works, see `pad/3`.

  ## Examples
    # stream as padding
    iex> pad_zip(1..5, [:a, :b, :c], Stream.cycle([0]),
    ...>   Stream.cycle([:z]))
    [{1, :a}, {2, :b}, {3, :c}, {4, :z}, {5, :z}]
  
    # function as padding
    iex> pad_zip([:a, :aN], 1..4, &("#{&1}" |> String.reverse
    ...> |> String.duplicate(2) |> String.to_atom))
    [a: 1, aN: 2, NaNa: 3, aNaNaNaN: 4]

    # Zipping finishes earlier because pading is not long enough 
    iex(12)> pad_zip(1..5, [:a], [nil], [nil])
    [{1, :a}, {2, nil}]

  """
  @spec pad_zip(t, t, t | (any -> any), t | (any -> any)) :: [{any, any}]
  def pad_zip(enumerable1, enumerable2, padding1, padding2)

  def pad_zip(enum1, enum2, pad1, pad2) do
    count1 = Enum.count(enum1)
    count2 = Enum.count(enum2)
    
    cond do
      count1 < count2 ->
        enum1 = pad(enum1, count2, pad1)
      count1 > count2 ->
        enum2 = pad(enum2, count1, pad2)
      true ->
        # counts are equal, just zip it
        true
    end

    Enum.zip(enum1, enum2)
  end
end