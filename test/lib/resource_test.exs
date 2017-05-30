defmodule TestTalon.Resource do
  use ExUnit.Case
  doctest Talon.Resource
  alias Talon.Resource

  test "name_field" do
    assert Resource.name_field(TestTalon.User) == :name
    assert Resource.name_field(TestTalon.Product) == :title
  end
end
