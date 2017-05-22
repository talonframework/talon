defmodule Mix.Tasks.Compile.ExAdmin do
  use Mix.Task
  @recursive true

  def run(_args) do
    # {:ok, _} = Application.ensure_all_started(:new_admin)

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
          IO.puts "......... compiling #{resource_name} #{action}"
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
    template = "web/templates/admin/#{theme}/#{resource_name}/generators/#{action}.html.eex"
    if File.exists? template do
      IO.puts "+++++++ compiling #{resource_name} #{action}"
      templ = EEx.eval_file(template, assigns: [resource_module: resource_module])
      # IO.puts templ
      File.mkdir_p("web/templates/admin/#{theme}/#{resource_name}")
      path = "web/templates/admin/#{theme}/#{resource_name}/#{action}.html.slim"
      IO.inspect path, label: "templ path"
      File.write!(path, templ)
      true
    else
      false
    end
  end

end


