ExUnit.start [trace: "--trace" in System.argv]
#ExUnit.start

Code.compiler_options debug_info: true

defmodule CompileAssertion do
  import ExUnit.Assertions

  def assert_compile_fail(given_exception, string) do
    case format_rescue(string) do
      {^given_exception, _} -> :ok
      {exception, _} ->
        raise ExUnit.AssertionError,
          left: inspect(exception),
          right: inspect(given_exception),
          message: "Expected match"
    end
  end

  def assert_compile_fail(given_exception, given_message, string) do
    {exception, message} = format_rescue(string)

    unless exception == given_exception and message =~ given_message do
      raise ExUnit.AssertionError,
        left: "#{inspect exception}[message: #{inspect message}]",
        right: "#{inspect given_exception}[message: #{inspect given_message}]",
        message: "Expected match"
    end
  end

  defp format_rescue(expr) do
    result = try do
      :elixir.eval(to_char_list(expr), [])
      nil
    rescue
      error -> {error.__struct__, Exception.message(error)}
    end

    result || flunk("Expected expression to fail")
  end
end