  # Beam files compiled on demand
  path = Path.expand("../_build/dev/lib/experimental_elixir/ebin", __DIR__)
  IO.puts path
  Code.prepend_path(path)

defmodule Experimental.KernelGuard do
  require Logger

  @doc false
  # Catch function call with one or more when clauses, and a do block
  defmacro do_guard_when(_call = {:when, context, clauses}, [do: do_block] = _expr, type) do
    [fun_clause, when_clauses] = clauses
    
    # deal with literals: true, false, nil
    do_block = cond do
      is_boolean(do_block) ->
        {:not, context, [
          {:not, context, [do_block]}
        ]}
      
      is_nil(do_block) ->
        {:is_nil, context, do_block}
      
      true ->
        do_block
    end
    {_, context_do_block, _} = do_block
    {_, context_when, _} = when_clauses

    and_clauses = Macro.postwalk(when_clauses, &replace_when/1)

    when_clauses =
      {:and, context_when, [
        #{:and, context_when, [and_clauses]},
        and_clauses,
        {:not, context_do_block, [do_block]}
      ]}
    
    call_new = 
      {:when, context, [
        fun_clause,
        when_clauses
      ]}

    case type do
      :public ->
        quote do
          def unquote(call_new) do
            raise FunctionClauseGuardError
          end
        end

      :private ->
        quote do
          defp unquote(call_new) do
            raise FunctionClauseGuardError
          end
        end
    end
  end

  @doc false
  # Catch function call with no when clause, and a do block
  defmacro do_guard_do(call, [do: do_block] = _expr, type) do
    {_, context, _} = call

    call_new = 
      {:when, context, [
        call,
        {:not, context, [
          do_block
        ]}
      ]}

    case type do
      :public ->
        quote do
          def unquote(call_new) do
            raise FunctionClauseGuardError
          end
        end

      :private ->
        quote do
          def unquote(call_new) do
            raise FunctionClauseGuardError
          end
        end
    end
  end

  @doc false
  # Defines head function with default values
  defmacro do_guard_head(_call = {:when, _context, [function_clause, _when_clauses]}, type) do
    quote do
      do_guard_head(unquote(function_clause), unquote(type))
    end
  end

  # no when clause
  defmacro do_guard_head(function_clause, type) do
    {_fun_name, _fun_context, fun_params} = function_clause
    cond do
      List.keyfind(fun_params, :\\, 0) ->
        case type do
          :public ->
            quote do
              def unquote(function_clause)
            end

          :private ->
            quote do
              defp unquote(function_clause)
            end
        end

      true ->
        quote do end
    end
  end

  @doc """
  Defines a function that will raise `FunctionClauseGuardError`
  when any of the conditions in the when clauses or the do block
  does not evaluate to true.

  Conditions can be defined in either when clauses or in the do
  block. The do block can only contain valid guard expressions, 
  same as if they were defined in a when clause.

      guard example(k, v)
        when is_integer(k) and is_bitstring(v)
        do k > 0
      end

  will be converted into:

      def example(k, v)
        when not( is_integer(k) and is_bitstring(v) )
        when not( k > 0 )
        do raise FunctionClauseGuardError
      end

  ## Usage
    
      @spec fun(pos_integer, neg_integer) :: {pos_integer, neg_integer}
      guard fun(a, b) when is_integer(a) and is_integer(b) do
        a > 0 and b < 0      
      end
      def fun(a, b), do: {a, b}

    The following expressions are equivalent

      guard fun(a, b), do: a > 1 and b < 0

      guard fun(a, b) when a > 1 and b < 0

      guard fun(a, b) when a > 0, do: b < 0

  ## Multiple guard declarations

    If more than one groups of expressions want to be
    used the cannot.
    Multiple declarations result in them being ANDed and not ORed as when
    defining mutiples clauses with `Kernel.def/2`.

      @spec atom_xor_bitstring(atom | String.t, atom | String.t) :: {:atom, String.t} | {String.t, :atom}
      guard atom_xor_bitstring(a, b) do
        (is_atom(a) and is_bitstring(b) and a == :atom and b == "bitstring") or
        (is_bitstring(a) and is_atom(b) and a == "bitstring" and b == :atom)
      end
      def atom_xor_bitstring(a, b), do: {a, b}

      atom_xor_bitstring(:atom, "bitstring")
      # => {:atom, "bitstring"}
      atom_xor_bitstring("bitstring", :atom)
      # => {"bitstring", :atom}
      atom_xor_bitstring(:foo, "bar")
      # => ** (FunctionClauseGuardError) no function clause matches

  """
  @spec guard(Macro.t, [Macro.t] | nil) :: Macro.t
  defmacro guard(call, expr \\ nil)

  # Catch function call with one or more when clauses, and optionally a do block
  defmacro guard(call = {:when, _context, _clauses}, expr) do
    call_no_default = Macro.postwalk(call, &remove_default/1)
    quote do
      do_guard_head(unquote(call), :public)
      do_guard_when(unquote(call_no_default), unquote(expr), :public)
    end
  end

  # Catch function call with no when clause, and a do block
  defmacro guard(call, [do: _do_block] = expr) do
    call_no_default = Macro.postwalk(call, &remove_default/1)
    quote do
      do_guard_head(unquote(call), :public)
      #do_guard_do(unquote(call_no_default), [do: unquote(do_block)], :public)
      do_guard_do(unquote(call_no_default), unquote(expr), :public)
    end
  end

  defmacro guard(_, _) do
    raise CompileError, message: "guard/2 cannot be defined without a 'do' block"
  end

  @doc """
  Defines a private function that will raise `FunctionClauseGuardError`
  when any of the conditions in the when clauses or the do block
  does not evaluate to true.

  Please read `guard/2` for more information.
  """
  @spec guardp(Macro.t, [Macro.t] | nil) :: Macro.t
  defmacro guardp(call, expr \\ nil)

  defmacro guardp(call = {:when, _context, _clauses}, expr) do
    call_no_default = Macro.postwalk(call, &remove_default/1)
    quote do
      do_guard_head(unquote(call), :private)
      do_guard_when(unquote(call_no_default), unquote(expr), :private)
    end
  end

  defmacro guardp(call, [do: _do_block] = expr) do
    call_no_default = Macro.postwalk(call, &remove_default/1)
    quote do
      do_guard_head(unquote(call), :private)
      #do_guard_do(unquote(call_no_default), [do: unquote(do_block)], :private)
      do_guard_do(unquote(call_no_default), unquote(expr), :private)
    end
  end

  defmacro guardp(_, _) do
    raise CompileError, message: "guardp/2 cannot be defined without a 'do' block"
  end

  #########################
  # Guard Private funtions

  # Replace :when clauses with :and
  defp replace_when({:when, context, params}) do
    {:and, context, params}
  end

  defp replace_when(ast) do
    ast
  end

  # Removes default values in variables
  defp remove_default(_ast={:\\, _context, [param_variable, _param_value] = _params}) do
    param_variable
  end

  defp remove_default(ast) do
    ast
  end

end

defmodule FunctionClauseGuardError do
  defexception [module: nil, function: nil, arity: nil, message: nil]

  def message(exception) do
    if exception.function do
      formatted = Exception.format_mfa exception.module, exception.function, exception.arity
      "no function clause matching the guard in #{formatted}"
    else
      "no function clause matches the guard"
    end
  end
end

defmodule Experimental.KernelGuardTest do

  import Kernel, except: [
    guard: 1, guard: 2, guardp: 1, guardp: 2, 
    do_guard_when: 3, do_guard_do: 3, do_guard_head: 2, 
    negate_when: 1, remove_default: 1,
  ]
  import Experimental.KernelGuard

  #Code.compiler_options debug_info: true
  require Logger

#  @spec check(pos_integer, neg_integer) :: :ok
#  guard check(a, b \\ -1)  when 1 == 1 do
#    is_integer(a) and a > 0 and is_integer(b) and b < 0
#  end
#  def check(a, b) when is_integer(a) and is_integer(b), do: :ok
#
#
#  # Default value
#  @spec check_default(pos_integer, neg_integer) :: :ok
#  #def check_default(a, b \\ -1)
#  #guard check_default(a, b \\ -1) when 1 == 1 do
#  guard check_default(a, b) do
#    is_integer(a) and a > 0 and is_integer(b) and b < 0
#  end
#  #IO.inspect Macro.expand(quote do check_default(3, -1) end, __ENV__)
#  def check_default(a, b) when is_integer(a) and is_integer(b), do: :ok

  @spec check_2(pos_integer, neg_integer) :: :ok
  #guard check_2(a, b) when is_integer(a) and a > 0 and is_integer(b) and b < 0 do
  guard check_2(a, _b) when is_integer(a)  do
    true 
  end

  def check_2(a, b) when is_integer(a) and is_integer(b), do: :ok

end

#IO.inspect Experimental.KernelGuardTest.check(3, -1)
IO.inspect Experimental.KernelGuardTest.check_2(3, -1)
#IO.inspect Experimental.KernelGuardTest.check(3, 1)