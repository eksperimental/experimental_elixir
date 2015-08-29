defmodule Experimental.StringAffixTest do
  alias Experimental.StringAffix, as: String

  use ExUnit.Case, async: true

  doctest Experimental.StringAffix

  test "String.prefix" do
    actual = "Armstrong" |> Experimental.StringAffix.prefix("Mr. ")
    assert actual == "Mr. Armstrong"
  end
end
