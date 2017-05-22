defmodule Mix.ExAdmin do

  def themes do
    Application.get_env :ex_admin, :themes, ["admin_lte"]
  end
end


