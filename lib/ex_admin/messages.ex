defmodule ExAdmin.Messages do
  @moduledoc """
  Interface for handling localization of build in ExAdmin messages.

  The following module defines the behaviour for rendering internal
  ex_admin messages.

  The ex_admin mix tasks generate a messages file in the user's app
  that uses this behaviour to ensure the user has implement all the
  required messages.
  """
  # @callback cant_be_blank() :: binary
  # @callback verify_user_token([{atom, any}]) :: binary

  @callback are_you_sure_you_want_to_delete_this?() ::binary

  @doc """
  Returns the Messages module from the users app's configuration
  """
  def backend do
    Application.get_env :ex_admin, :messages_backend
  end
end

