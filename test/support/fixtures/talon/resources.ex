
defmodule TestTalon.Talon.Simple do
  use Talon.Resource, schema: TestTalon.Simple, context: TestTalon.Talon
end

defmodule TestTalon.Talon.Product do
  use Talon.Resource, schema: TestTalon.Product, context: TestTalon.Talon
end
