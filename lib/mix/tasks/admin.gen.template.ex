defmodule Mix.Tasks.Admin.Gen.Template do
  @moduledoc """
  Create a resource level template.

  Use this task to override the global template for a specific resource and
  controller action. The global generator will copied to
  `templates/admin/theme/resource/generators` folder.

  ## Usage

      # Create a index.html.eex generator for the User resource default theme
      mix admin.gen.template index User

      # Create a form.html.eex generator for the Contact resource my_custom_theme theme
      mix admin.gen.template form Contact --theme=my_custom_theme

      # Create all the xxx.html.eex generators for the User resource for all configured themes
      mix admin.gen.template User --all --all-themes

      # Create show.html.eex generator for all resources
      mix admin.gen.template show --all-resources

      # Create all generators for all resources and all themes
      mix admin.gen.template --everything


  ## Options

  * --verbose -- Extra logging
  * --dry-run -- Show the files to be copied, but do not copy them
  * --all -- All actions
  * --all-themes -- All themes
  * --all-resources -- All resources
  * --everything -- All actions, themes, and resources
  """
  use Mix.Task

  import Mix.ExAdmin

  @default_theme "admin_lte"
  @valid_actions ~w(form index show new edit)

  # list all supported boolean options
  @boolean_options ~w(all all_themes all_resources dry_run verbose)a

  # complete list of supported options
  @switches [
    theme: :string
  ] ++ Enum.map(@boolean_options, &({&1, :boolean}))


  @doc """
  The entry point of the mix task.
  """
  @spec run(List.t) :: any
  def run(args) do
    {opts, parsed, _unknown} = OptionParser.parse(args, switches: @switches)
    # IO.inspect all, label: "all"

    # verify_args!(parsed, unknown)
    opts
    |> parse_options(parsed)
    |> do_config
    |> do_run
  end

  defp do_run(config) do
    # IO.inspect config, label: "... config"
    log config, inspect(config), label: "config"
    for theme <- config.themes do
      source_theme_path = "web/templates/admin/#{theme}/generators/"
      target_theme_path = "web/templates/admin/#{theme}/"
      for resource <- config.resources do
        target_resource_path = target_theme_path <> "#{resource}/generators/"
        File.mkdir target_resource_path
        for action <- config.actions do
          fname = action <> ".html.eex"
          source_action_path = source_theme_path <> fname
          target_action_path = target_resource_path <> fname
          info = "copying #{source_action_path} to #{target_action_path}"
          if config.dry_run do
            log %{verbose: true}, info
          else
            if File.exists? target_action_path do
              if Mix.shell.yes?("#{target_action_path} already exists. Overwrite it?") do
                log %{verbose: true}, info
                File.copy! source_action_path, target_action_path
              end
            else
              log %{verbose: true}, info
              File.copy! source_action_path, target_action_path
            end
          end
        end
      end
    end
  end

  defp do_config({bin_opts, _opts, _parsed} = args) do
    # IO.inspect {opts, bin_opts, parsed}, label: "...{opts, bin_opts, parsed}"
    %{
      themes: get_themes(args),
      resources: get_resources(args),
      actions: get_actions(args),
      dry_run: bin_opts[:dry_run],
      verbose: bin_opts[:verbose]
    }
  end

  defp get_themes({opts, bin_opts, _parsed}) do
    cond do
      bin_opts[:all_themes] -> all_themes()
      opts[:theme] -> [opts[:theme]]
      all = all_themes() -> Enum.take(all, 1)
    end
  end

  defp get_resources({opts, _bin_opts, parsed}) do
    if opts[:all_resources] do
      if length(parsed) == 2, do: Mix.raise("do not specify a resource with the --all-resources option")
      all_resources()
    else
      if length(parsed) == 0, do: Mix.raise("must specify a resource")
      [List.last(parsed) |> String.downcase]
    end
  end

  defp get_actions({opts, _bin_opts, parsed}) do
    if opts[:all] do
      if length(parsed) == 2, do: Mix.raise("do not specify an action with the --all option")
      @valid_actions
    else
      [List.first(parsed) |> String.downcase]
    end
    |> validate_actions!
  end

  defp all_themes do
    Application.get_env :ex_admin, :themes, [@default_theme]
  end

  defp all_resources do
    Application.get_env(:ex_admin, :resources, [])
    |> Enum.map(fn resource ->
      resource
      |> Module.split
      |> List.last
      |> String.downcase
    end)
  end

  defp parse_options([], parsed) do
    # IO.inspect [], label: "parse_options opts"
    {[], [], parsed}
  end
  defp parse_options(opts, parsed) do
    # IO.inspect opts, label: "parse_options opts"
    bin_opts = Enum.filter(opts, fn {k,_v} -> k in @boolean_options end)
    bin_opts =
      if bin_opts[:everything] do
        Keyword.merge bin_opts, [all: true, all_resources: true, all_themes: true]
      else
        bin_opts
      end

    {bin_opts, opts -- bin_opts, parsed}
  end

  def validate_actions!(actions) do
    actions
    |> Enum.reject(&(&1 in @valid_actions))
    |> Enum.join(" ")
    |> case do
      "" ->
        actions
      actions ->
        Mix.raise ~s[Invalid action(s) #{actions}. Allow actions are #{Enum.join(@valid_actions, " ")}]
    end
  end
end
