
defmodule TestExAdmin.ExAdmin.Simple do
  use ExAdmin.Resource, schema: TestExAdmin.Simple, context: TestExAdmin.Admin
end

defmodule TestExAdmin.ExAdmin.Product do
  use ExAdmin.Resource, schema: TestExAdmin.Product, context: TestExAdmin.Admin
end
