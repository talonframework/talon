defmodule Talon.Page do
  @moduledoc """
  Mix-in for Talon managed page.
  """

  @type module_or_struct :: atom | struct

  defmacro __using__(opts) do

    quote do
      opts = unquote(opts)

      @__concern__  opts[:concern]
      @__domain__   opts[:domain] || "talon"

      @spec header_title(String.t, String.t) :: String.t
      def header_title(action, resource \\ nil), do: display_name()

      @doc """
      Return the Talon concern.
      """
      @spec concern() :: atom
      def concern, do: @__concern__

      # TODO: perhaps resource_name, module_name (DJS)
      @spec name() :: String.t
      def name, do: __MODULE__ |> Module.split |> List.last() |> to_string |> Inflex.underscore

      def display_name do
        dgettext @__domain__, "%{name}", name: Module.split(__MODULE__) |> List.last |> Talon.Utils.titleize
      end

      @spec route_name() :: String.t
      def route_name, do: name()

      def scope_queries(), do: []

      defoverridable [
        concern: 0, header_title: 2, name: 0, display_name: 0
      ]
    end
  end
end
