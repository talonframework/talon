defmodule Mix.Tasks.Compile.ExAdmin do
  @moduledoc """
  ExAdmin compiler to create slime templates for the provided generator templates.

  This compiler evaluates the .eex files in the `generators` folders and creates
  the slim templates for each of the configured resource modules.

  This is an interum design with the following behaviour:

  - Compiles the .eex templates on every compile, not just when when the .eex template is dirty
  - Does not work with live reload. You need to manually compile the project and live reload will pickup the changes.
  """
  use Mix.Task
  @recursive true

  def run(_args) do
    case touch() do
      [] -> :noop
      _ -> :ok
    end
  end

  def touch() do
    Mix.ExAdmin.themes()
    |> compile_templates
    :ok
  end

  def compile_templates(theme) do
    base = Application.get_env :ex_admin, :module
    unless base, do: Mix.raise(":module configuration required")

    mod = Module.concat base, Admin
    Code.ensure_compiled mod
    # TODO: need to replace Admin namespace here
    for {resource_name, resource_module} <- mod.resource_map() do
      resource_name = mod.template_path_name resource_name

      for action <- [:index, :edit, :form, :new, :show] do
        unless compile_custom_template(action, resource_name, resource_module, theme) do
          if Application.get_env :ex_admin, :verbose_compile do
            IO.puts "compiling global template for #{resource_name} #{action}"
          end
          templ = EEx.eval_file("web/templates/admin/#{theme}/generators/#{action}.html.eex", assigns: [resource_module: resource_module])
          File.mkdir_p("web/templates/admin/#{theme}/#{resource_name}")
          File.write("web/templates/admin/#{theme}/#{resource_name}/#{action}.html.slim", templ)
        end
      end
      view_name = "#{resource_name}_view.ex"
      File.touch! "web/views/admin/#{theme}/#{view_name}"
    end
  end

  def compile_custom_template(action, resource_name, resource_module, theme) do
    path = "web/templates/admin/#{theme}/#{resource_name}/generators"
    File.mkdir_p path
    template = Path.join path, "#{action}.html.eex"
    if File.exists? template do
      if Application.get_env :ex_admin, :verbose_compile do
        IO.puts "compiling override template for #{resource_name} #{action}"
      end
      templ = EEx.eval_file(template, assigns: [resource_module: resource_module])
      File.mkdir_p("web/templates/admin/#{theme}/#{resource_name}")
      path = "web/templates/admin/#{theme}/#{resource_name}/#{action}.html.slim"
      File.write!(path, templ)
      true
    else
      false
    end
  end

end


