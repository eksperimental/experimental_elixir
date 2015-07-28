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

        deffail check(a) do
          :error
        end
      end

      Bar.check("",3)

  """
  defmacro deffail(call, expr) do
    case call do
      {:when, _line, _} ->
        quote do
          def(unquote(call), unquote(expr))
        end
      
      _ ->
        quote do
          raise ArgumentError, message: "cannot use `deffail` without a `when` clause"
        end
    end
  end

  defmacro defensure(call = {clause, _line, _}, expr) when clause in [:when, :that] do
    quote do
      def(unquote(call), unquote(expr))
    end
  end

  defmacro defensure(_call, _expr) do
    quote do
      raise ArgumentError, message: "cannot use `defensure` without a `that` or a `when` clause"
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
