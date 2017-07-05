defmodule Talon.Page do
  @moduledoc """
  Define an Talon managed page

  """

  @type module_or_struct :: atom | struct

  defmacro __using__(opts) do

    concern = opts[:concern]

    quote do
      @__concern__ unquote(concern) || (Module.split(__MODULE__) |> hd |> Module.concat(nil))

      # TODO: too specific to template. Move to view. (DJS)
      @spec index_card_title() :: String.t
      def index_card_title, do: title()

      @doc """
      Return the Talon concern.
      """
      @spec concern() :: atom
      def concern, do: @__concern__

      @spec title() :: String.t
      def title, do: name() |> Talon.Utils.titleize

      # TODO: perhaps resource_name, module_name (DJS)
      @spec name() :: String.t
      def name, do: __MODULE__ |> Module.split |> List.last() |> to_string |> Inflex.underscore

      @spec route_name() :: String.t
      def route_name, do: name()

      defoverridable [
        concern: 0, index_card_title: 0, title: 0, name: 0
      ]
    end
  end
end
