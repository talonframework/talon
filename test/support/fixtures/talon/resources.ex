
defmodule TestTalon.Admin.Simple do
  use TestTalon.Talon.Web, which: :resource
  use Talon.Resource, schema: TestTalon.Simple, concern: TestTalon.Admin
end

defmodule TestTalon.Admin.Product do
  use TestTalon.Talon.Web, which: :resource
  use Talon.Resource, schema: TestTalon.Product, concern: TestTalon.Admin
end

defmodule TestTalon.Admin.Noid do
  use TestTalon.Talon.Web, which: :resource
  use Talon.Resource, schema: TestTalon.Noid, concern: TestTalon.Admin

  def name_field, do: :company
end
