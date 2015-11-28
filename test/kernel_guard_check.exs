defmodule Experimental.KernelGuardCheck do
  use ExUnit.Case, async: true
  import Kernel, except: [guard: 1, guard: 2, guardp: 1, guardp: 2, ]
  import Experimental.KernelGuard

  require Logger

  # Default value
  @spec check_default_1(pos_integer, neg_integer) :: :ok
  guard check_default_1(a, b \\ -1) when 1 == 1 do
    is_integer(a) and a > 0 and is_integer(b) and b < 0
  end
  def check_default_1(a, b) when is_integer(a) and is_integer(b), do: :ok
  #check_default_1(:foo, :bar)
  
  test "xx" do
    check_default_1(3, -1)
  end
end