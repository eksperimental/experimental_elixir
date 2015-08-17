defmodule Experimental.KernelDeffail do

  @doc """
  Defines a function that will fail and raise an error if any
  of the the conditions in the guards are not met.

  If no `do` block is provided, `ArgumentError` will be `raise`d.

  ## Examples
      import Experimental.KernelDeffail

      defmodule Foo do
        deffail sum_positives(a, b) when not is_non_negative_integer(a)
                                    when not is_non_negative_integer(b)

        deffail test(a, b) when not is_integer(a)
                           or not is_non_negative_integer(b)
      end

      defmodule Bar do
        deffail check(a, b) when is_bitstring(a) do
          raise ArgumentError
        end
        
        def check(a, b) when is_integer(a) do
          :ok
        end

        def check(a) when is_integer(a) do
          :ok
        end
      end

      Bar.check("",3)

  """
  defmacro deffail(call, expr \\ nil)

  defmacro deffail(call = {clause, _line, _}, nil) when clause == :when do
    quote do
      def(unquote(call), [do: raise ArgumentError])
    end
  end

  defmacro deffail(call = {clause, _line, _}, expr) when clause == :when do
    quote do
      def(unquote(call), unquote(expr))
    end
  end

  defmacro deffail(_call, _expr) do
    quote do
      raise ArgumentError, message: "cannot use `deffail/2` without a `when` clause"
    end
  end

  @doc """
    
    ## Examples

        defensure sum_positives(a, b) do
          is_non_neg_integer(a) and is_non_neg_integer(b)
        else
          raise ""
        end

  """
  defmacro defensure(call, clauses)

  defmacro defensure(_call = {clause, _line, _}, nil) when clause == :when do
    raise ArgumentError, message: "cannot call `defensure/2` without a `when` clause"
  end

  defmacro defensure(call, clauses) do
    do_clause = Keyword.get(clauses, :do, nil)
    else_clause = Keyword.get(clauses, :else, nil)

    quote do
      # TODO: add do block as a when clause into call
      def(unquote(call), unquote(else_clause))
    end
  end

  defmacro defensure(_call, _expr) do
    quote do
      raise ArgumentError, message: "cannot use `defensure/2` without a `do` block"
    end
  end
end


defmodule ArgumentError do
  defexception [module: nil, function: nil, arity: nil, message: nil]

  def message(exception) do
    cond do
      exception.message ->
        exception.message

      exception.function ->
        formatted_mfa = Exception.format_mfa exception.module, exception.function, exception.arity
        "argument error in #{formatted_mfa}"
      
      true ->
        "argument error"
    end
  end
end
