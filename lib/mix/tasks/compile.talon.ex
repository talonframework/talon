defmodule Mix.Tasks.Compile.Talon do
  @moduledoc """
  Talon compiler to create slime templates for the provided generator templates.

  This compiler evaluates the .eex files in the `generators` folders and creates
  the slim templates for each of the configured resource modules.

  This is an interum design with the following behaviour:

  - Compiles the .eex templates on every compile, not just when when the .eex template is dirty
  - Does not work with live reload. You need to manually compile the project and live reload will pickup the changes.
  """
  use Mix.Task
  @recursive true

  def run(_args) do
    {:ok, _} = Application.ensure_all_started(:talon)
    if Mix.Talon.compiler_opts()[:verbose_compile] do
      IO.puts "Compiling Talon generators"
    end
    case touch() do
      [] -> :noop
      _ -> :ok
    end
  end

  def touch() do
    Mix.Talon.themes()
    |> Enum.reduce(:ok, fn theme, acc ->
      Enum.reduce Mix.Talon.concerns(), acc, fn concern, _acc ->
        compile_templates concern, theme
      end
    end)
    |> case do
      [] -> :noop
      _ -> :ok
    end
  end

  defp templates_path(concern, theme) do
    concern_path = Mix.Talon.concern_path(concern)
    {root_path, path_prefix} = Mix.Talon.root_and_prefix_path(concern)
    Path.join([root_path, "templates", path_prefix, concern_path, theme])
  end

  defp views_path(concern, theme) do
    concern_path = Mix.Talon.concern_path(concern)
    {root_path, path_prefix} = Mix.Talon.root_and_prefix_path(concern)
    Path.join([root_path, "views", path_prefix, concern_path, theme])
  end

  defp compile_templates(concern, theme) do
    try do
      base = Mix.Phoenix.base()
      base_path = templates_path(concern, theme)
      views_path = views_path(concern, theme)

      unless base, do: Mix.raise(":module configuration required")

      Code.ensure_compiled concern

      for {resource_name, talon_resource} <- concern.resource_map() do
        resource_name = concern.template_path_name resource_name

        for action <- [:index, :edit, :form, :new, :show] do
          unless compile_custom_template(action, resource_name, talon_resource, concern, theme) do
            if Mix.Talon.compiler_opts()[:verbose_compile] do
              IO.puts "compiling global template for #{resource_name} #{action}"
            end
            templ = EEx.eval_file(Path.join([base_path, "generators", "#{action}.html.eex"]),
              assigns: [talon_resource: talon_resource])
            File.mkdir_p(Path.join(base_path, resource_name))
            Path.join([base_path, resource_name, "#{action}.html.slim"])
            |> File.write(templ)
          end
        end
        File.touch! Path.join(views_path, "#{resource_name}_view.ex")
      end
    rescue
      # TODO: Dont' swallow exceptions. What's the best approach here? Anything like IO.puts(e.message) halts execution and don't really want that.
      # In Elixir 1.6, Mix compilers adhere to the Mix.Task.Compiler behaviour and return error and warning diagnostics in a standardized way => Use That.

      # _ -> []
      e -> IO.inspect e # Works but not overly informative
    end
  end

  defp compile_custom_template(action, resource_name, talon_resource, concern, theme) do
    try do
      base_path = templates_path(concern, theme)
      path = Path.join([base_path, resource_name, "generators"])
      template = Path.join path, "#{action}.html.eex"
      if File.exists? template do
        if Mix.Talon.compiler_opts()[:verbose_compile] do
          IO.puts "compiling override template for #{resource_name} #{action}"
        end
        templ = EEx.eval_file(template, assigns: [talon_resource: talon_resource])
        File.mkdir_p(Path.join(base_path, resource_name))
        path = Path.join [base_path, resource_name, "#{action}.html.slim"]
        File.write!(path, templ)
        true
      else
        false
      end
    rescue
      _ -> false
    end
  end

end
