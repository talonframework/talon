defmodule TestTalon do
  use ExUnit.Case
  doctest Talon

  setup do
    Application.put_env :talon, TestTalon.Talon,
      resources: [

      ]
    Application.put_env :talon, TestTalon.FrontEnd,
      resources: [

      ]
    :ok
  end

  test "front_end" do

  end
end
