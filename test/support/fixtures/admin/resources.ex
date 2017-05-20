
defmodule TestExAdmin.ExAdmin.Simple do
  use ExAdmin.Resource, schema: TestExAdmin.Simple
  use ExAdmin.Controller, :resource 
end
