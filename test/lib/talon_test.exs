defmodule TestTalon do
  use ExUnit.Case
  doctest Talon

  setup do
    # Application.put_env :talon, TestTalon.Talon,
    #   resources: [

    #   ]
    # Application.put_env :talon, TestTalon.FrontEnd,
    #   resources: [
    #     TestTalon.FrontEnd.Sample
    #   ],
    #   schema_adapter: Talon.Schema.Adapters.Ecto,
    #   module: TestTalon,
    #   theme: "theme2"
    :ok
  end

  test "backend" do
    list = TestTalon.Admin.resource_names()
    assert "products" in list
    assert "simples" in list
  end

  test "front_end" do
    list = TestTalon.FrontEnd.resource_names()
    assert "noids" in list
  end
end
