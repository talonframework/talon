defmodule TestTalon.Resource do
  use ExUnit.Case
  doctest Talon.Resource
  alias Talon.Resource

  test "default_name_field" do
    assert Resource.default_name_field(TestTalon.User) == :name
    assert Resource.default_name_field(TestTalon.Product) == :title
  end
end
