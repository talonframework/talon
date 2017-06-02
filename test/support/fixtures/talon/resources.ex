
defmodule TestTalon.Talon.Simple do
  use Talon.Resource, schema: TestTalon.Simple, concern: TestTalon.Talon
end

defmodule TestTalon.Talon.Product do
  use Talon.Resource, schema: TestTalon.Product, concern: TestTalon.Talon
end

defmodule TestTalon.Talon.Noid do
  use Talon.Resource, schema: TestTalon.Noid, concern: TestTalon.Talon

  def name_field, do: :company
end
