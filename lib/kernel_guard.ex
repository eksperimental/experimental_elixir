defmodule FunctionClauseGuardError do
  defexception [
    module: nil, function: nil, arity: nil, file: "nofile", line: nil,
    description: "function clause guard error", message: nil,
  ]

  def message(exception) do
    cond do
      exception.file && exception.file != "nofile" ->
        formatted_file = exception.file |> Path.relative_to_cwd |> Exception.format_file_line(exception.line)
        if exception.function do
          formatted_mfa = Exception.format_mfa(exception.module, exception.function, exception.arity)
          formatted_file <> " no function clause matching the guard in " <> formatted_mfa
        else
          formatted_file <> " no function clause matching the guard"
        end

      exception.function ->
        formatted_mfa = Exception.format_mfa(exception.module, exception.function, exception.arity)
        "no function clause matching in #{formatted_mfa}"

      true ->
        "no function clause matches the guard"
    end
  end
end

defmodule CompileError do
  defexception [
    file: "nofile", line: nil,
    description: "compile error", message: nil,
  ]

  def message(exception) do
    output = Exception.format_file_line(Path.relative_to_cwd(exception.file), exception.line) <>
      " " <> exception.description

    cond do
      exception.message ->
        output <> " - " <> exception.message

      true ->
        output
    end
  end
end

defmodule Experimental.KernelGuard do
  require Logger

  @doc ~S"""
  Guarantees that any further pattern matched bellow meets the
  criteria defined by guard in a public function.

  Defines a function that will raise `FunctionClauseGuardError`
  when the guard defined in the `do` block does not evaluate to `true`.

  Additionally, conditions can be defined with `when` clauses.

  The `do` block can only contain valid guard expressions,
  same as if they were defined in a `when` clause.

  ## Examples

      guard example(k, v) do
        is_integer(k) and k > 0 and
        is_bitstring(v)
      end

  will be translated into:

      def example(k, v)
      when not( is_integer(k) and k > 0 and is_bitstring(v) ) do
        raise FunctionClauseGuardError
      end

  Default values can be defined:

      guard example(k, v \\ "") do
        is_integer(k) and k > 0 and
        is_bitstring(v)
      end

  will be translated into a head function and a guard function:

      def example(k, v \\ 1)
      def example(k, v)
        when not( is_integer(k) and k > 0 and is_bitstring(v) )
        do raise FunctionClauseGuardError
      end

  ## Usage

      @spec number_or_length(pos_integer | atom) :: pos_integer
      guard number_or_length(term) do
        is_integer(term) and term > 0
        or is_atom(term)
      end
      def number_or_length(number) when is_integer(number),
        do: number
      def number_or_length(atom),
        do: String.length("\#{atom}")

      # as you can see in the first `def`, we don't check for `number` being
      # positive, as it is guaranteed by `guard/2`,
      # and in the second `dev` we don't check for

      @spec fun(pos_integer, neg_integer) :: {pos_integer, neg_integer}
      guard fun(a, b) when is_integer(a) and is_integer(b) do
        a > 0 and b < 0
      end
      def fun(a, b) do
        {a, b}
      end

    The following expressions are equivalent

      guard fun(a, b), do: a > 1 and b < 0

      guard fun(a, b) when a > 0, do: b < 0

      guard fun(a, b) when a > 1 and b < 0

  ## Multiple guard declarations

    More than one guard can be defined:

      guard example(k, v \\ "") do
        (is_integer(k) or is_atom(k)) and
        is_bitstring(v) and v != ""
      end

      guard example(k, _v) when is_integer(k) do
        k > 0
      end

      guard example(k, _v) when is_atom(k) do
        :k in [:ok, :error]
      end

  """
  @spec guard(Macro.t, [Macro.t] | nil) :: Macro.t
  defmacro guard(call, expr \\ nil)

  # Catch function call with one or more when clauses, and optionally a do block
  defmacro guard(call = {:when, _context, _clauses}, [do: _do_block] = expr) do
    call_with_no_default = Macro.postwalk(call, &remove_default/1)
    quote do
      do_guard_head(unquote(call), :public)
      do_guard_when(unquote(call_with_no_default), unquote(expr), :public)
    end
  end

  # Catch function call with no when clause, and a do block
  defmacro guard(call, [do: _do_block] = expr) do
    call_with_no_default = Macro.postwalk(call, &remove_default/1)
    quote do
      do_guard_head(unquote(call), :public)
      do_guard_do(unquote(call_with_no_default), unquote(expr), :public)
    end
  end

  defmacro guard(_, _) do
    raise CompileError, message: "guard/2 cannot be defined without a 'do' block"
  end

  @doc ~S"""
  Guarantees that any further pattern matched bellow meets the
  criteria defined by guard in a private function.

  Defines a private function that will raise `FunctionClauseGuardError`
  when the guard defined in the `do` block does not evaluate to `true`.

  For more information, see `guard/2`.
  """
  @spec guardp(Macro.t, [Macro.t] | nil) :: Macro.t
  defmacro guardp(call, expr \\ nil)

  defmacro guardp(call = {:when, _context, _clauses}, [do: _do_block] = expr) do
    call_with_no_default = Macro.postwalk(call, &remove_default/1)
    quote do
      do_guard_head(unquote(call), :private)
      do_guard_when(unquote(call_with_no_default), unquote(expr), :private)
    end
  end

  defmacro guardp(call, [do: _do_block] = expr) do
    call_with_no_default = Macro.postwalk(call, &remove_default/1)
    quote do
      do_guard_head(unquote(call), :private)
      do_guard_do(unquote(call_with_no_default), unquote(expr), :private)
    end
  end

  defmacro guardp(_, _) do
    raise CompileError, message: "guard/2 cannot be defined without a 'do' block"
  end


  #########################
  # Helpers

  # Replace :when clauses with :and
  defp replace_when({:when, context, params}),
    do: {:and, context, params}
  defp replace_when(ast),
    do: ast

  # Removes default values in variables
  defp remove_default(_ast={:\\, _context, [param_variable, _param_value] = _params}),
    do: param_variable
  defp remove_default(ast),
    do: ast

  @doc false
  # Defines functions for guard/2 and guardp/2
  defmacro do_guard_def(call, type, file) do
    {_, context, _} = call
    line = Keyword.get(context, :line)

    case type do
      :public ->
        quote do
          def unquote(call) do
            raise FunctionClauseGuardError,
              module:   __MODULE__,
              function: :guard,
              arity:    2,
              file:     unquote(file),
              line:     unquote(line)
          end
        end

      :private ->
        quote do
          defp unquote(call) do
            raise FunctionClauseGuardError,
              module:   __MODULE__,
              function: :guardp,
              arity:    2,
              file:     unquote(file),
              line:     unquote(line)
          end
        end
    end
  end

  @doc false
  # Catch function call with a do block and one or more when clauses
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
        and_clauses,
        {:not, context_do_block, [do_block]}
      ]}

    call_new = {:when, context, [fun_clause, when_clauses]}

    quote do: do_guard_def(unquote(call_new), unquote(type), __ENV__.file)
  end

  @doc false
  # Catch function call with no when clause, and a do block
  defmacro do_guard_do(call, [do: do_block] = _expr, type) do
    {_, context, _} = call

    call_new =
      {:when, context, [
        call,
        {:not, context, [do_block]}
      ]}

    quote do: do_guard_def(unquote(call_new), unquote(type), __ENV__.file)
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
end
