defmodule Talon.Router do
  @moduledoc """
  Router macro for Talon sites.

  Provides a helper macro for adding up Talon routes to your application.

  ## Examples:

      defmodule MyProject.Router do
        use MyProject.Web, :router
        use Talon.Router
        ...
        scope "/", MyProject do
          ...
        end

        # setup the Talon routes on /talon
        scope "/talon", Talon do
          pipe_through :browser
          talon_routes
        end
      end

  """
  use Phoenix.Router

  defmacro __using__(_opts \\ []) do
    quote do
      import unquote(__MODULE__)
    end
  end

  @doc """
  Add Talon Routes to your project's router

  Adds the routes required for Talon
  """
  defmacro talon_routes(context) do

    quote do
      context =
        unquote(context)
        |> Module.split()
        |> List.last
        |> Module.concat(nil)

      resource_controller = Talon.Utils.module_join(context, ResourceController)
      controller = Talon.Utils.module_join(context, Controller)

      get "/", TalonPageController, :page
      get "/pages/:page", TalonPageController, :page
      get "/select_theme/:id", controller, :select_theme
      if Application.get_env :talon, :login_user do
        get "/switch_user/:id", controller, :switch_user
      end
      get "/:resource/search/:search_terms", resource_controller, :search
      get "/:resource/search/", resource_controller, :search
      get "/:resource", resource_controller, :index
      # get "/:resource/search/:search_terms", TalonResourceController, :search
      get "/:resource/new", resource_controller, :new
      get "/:resource/csv", resource_controller, :csv
      get "/:resource/:id", resource_controller, :show
      get "/:resource/:id/edit", resource_controller, :edit
      post "/:resource/", resource_controller, :create
      patch "/:resource/:id", resource_controller, :update
      put "/:resource/:id", resource_controller, :update
      # put "/:resource/:id/toggle_attr", TalonResourceController, :toggle_attr
      delete "/:resource/:id", resource_controller, :delete
      # post "/:resource/batch_action", TalonResourceController, :batch_action
      # put   "/:resource/:id/member/:action", TalonResourceController, :member
      # patch "/:resource/:id/member/:action", TalonResourceController, :member
      # get "/:resource/collection/:action", TalonResourceController, :collection
      # post "/:resource/:id/:association_name/update_positions", TalonAssociationController, :update_positions, as: :talon_association
      # post "/:resource/:id/:association_name", TalonAssociationController, :add, as: :talon_association
      # get "/:resource/:id/:association_name", TalonAssociationController, :index, as: :talon_association
    end
  end
end
