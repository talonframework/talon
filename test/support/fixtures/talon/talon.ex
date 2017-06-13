defmodule TestTalon.Talon do

  Application.put_env(:talon, :dashboard, TestTalon.Talon.Dashboard) # TODO: allow easier injection (DJS)

  use Talon, otp_app: :talon
end
