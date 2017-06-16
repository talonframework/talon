defmodule TestTalon.Talon do

  Application.put_env(:talon, :pages, [TestTalon.Talon.Dashboard]) # TODO: shouldn't test config have this? (DJS)

  use Talon, otp_app: :talon
end
