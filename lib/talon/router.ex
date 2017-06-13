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
  defmacro talon_routes(_opts \\ []) do
    quote do
      get "/", TalonPageController, :dashboard
      get "/dashboard", TalonPageController, :dashboard
      get "/pages/:page", TalonPageController, :page

      # get "/dashboard", TalonPageController, :page, page: :dashboard  # TODO: preferred way, not working
      # get "/", TalonPageController, :page, page: :dashboard,

      get "/select_theme/:id", TalonPageController, :select_theme
      if Application.get_env :talon, :login_user do
        get "/switch_user/:id", TalonPageController, :switch_user
      end
      get "/:resource/search/:search_terms", TalonResourceController, :search
      get "/:resource/", TalonResourceController, :index
      # get "/:resource/search/:search_terms", TalonResourceController, :search
      get "/:resource/new", TalonResourceController, :new
      get "/:resource/csv", TalonResourceController, :csv
      get "/:resource/:id", TalonResourceController, :show
      get "/:resource/:id/edit", TalonResourceController, :edit
      post "/:resource/", TalonResourceController, :create
      patch "/:resource/:id", TalonResourceController, :update
      put "/:resource/:id", TalonResourceController, :update
      put "/:resource/:id/toggle_attr", TalonResourceController, :toggle_attr
      delete "/:resource/:id", TalonResourceController, :delete
      post "/:resource/batch_action", TalonResourceController, :batch_action
      put   "/:resource/:id/member/:action", TalonResourceController, :member
      patch "/:resource/:id/member/:action", TalonResourceController, :member
      get "/:resource/collection/:action", TalonResourceController, :collection
      post "/:resource/:id/:association_name/update_positions", TalonAssociationController, :update_positions, as: :talon_association
      post "/:resource/:id/:association_name", TalonAssociationController, :add, as: :talon_association
      get "/:resource/:id/:association_name", TalonAssociationController, :index, as: :talon_association
    end
  end
end
