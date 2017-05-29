[![Stories in Ready](https://badge.waffle.io/ex-admin/ex_admin.png?label=ready&title=Ready)](https://waffle.io/ex-admin/ex_admin?utm_source=badge)
# Talon

This is the new ExAdmin project, located under the new Github Group [talonframework](https://github.com/talonframework). This is a complete redesign of ExAdmin, renamed Talon. See the justification and goals below.

> <b><span style="color: #FA366A;">IMPORTANT NOTE</span></b>
>
> This project is still is a work in progress and it not ready for public use yet. Please use this project if you would to contribute to the new archecture.
>
> The project is still in the exploratory stage. Much of the API has not been documented yet, nor any real test coverage added. When we finalized on the overall architecture, we will go back and complete the docs and tests.
>
> Contributors are very welcome. We can use your help!

## Project Overview

### Justification

ExAdmin was developed for my first Phoenix Application. The approach I took, although functional, does not align very well with the Phoenix way. Furthermore, I feel that we can do better without the heavy use of DSLs. Finally, I've never been happy with the theme support implementation.

### Design Goals

- break the package apart into a series of composable components
- make it simple to customize every part of the package
- remove the dependency on Ecto Schema. .i.e json objects, etc.
- easy to drop in new themes
- easy to update with extensive customization
- still works out of the box, without the need to configure anything
- intelligent defaults
- optimize the architecture to support large data (no association drop-downs with thousands of entries)
- support multiple themes/layouts in a single application (front facing layout and a back office "admin" interface)

### Ideas being kicked around

- Use JS data tables for the index page
  - live search/filtering
- Revamped sidebar filter
  - live updates
  - more inline with product filters on an eCommerce site
- Resource modules based on behaviours instead of config
- Perhaps more of a plug architecture (not sure what that looks like yet
- Remove the html DSL and replace it with `Slim` templates
  - Could use eex, but I much prefer indentation based templates
  - Could use both if we get pushback on Slim
- Customization with generators that create templates of templates
  - prototyping this now
  - avoid the sensitivity of direct generators when updating Talon
  - might making theming much easier
- componentize each concern (views/templates, controllers, schema)
- buffer the dependency on Ecto to support other approaches to describe and reflect the schema of resources

> <b><span style="color: #FA366A;">NOTE:</span></b>
>
> **This is a break point release. No backwards compatibility with ExAdmin!!**

See [this issue](https://github.com/talonframework/talon/issues/367) for more details.

## Customize the View Template for a Resource

All the view templates can be customized for any resource by creating a resource level .eex generator template using the `talon.gen.template` mix task.

### Examples

```bash
# Create a index.html.eex generator for the User resource default theme
mix talon.gen.template index User

# Create a form.html.eex generator for the Contact resource my_custom_theme theme
mix talon.gen.template form Contact --theme=my_custom_theme

# Create all the xxx.html.eex generators for the User resource for all configured themes
mix talon.gen.template User --all --all-themes

# Create show.html.eex generator for all resources
mix talon.gen.template show --all-resources

# Create all generators for all resources and all themes
mix talon.gen.template --everything
```

Run `mix help gen.talon.template` for more options.

Once the override template generator is created, simply edit the .eex template and customize it as designed.

When you compile the project, the new slim template generated. The talon comiler first checks to see if a template is defined in the `templates/admin_lte/theme/resource/generators` path. It will be compiled instead of the global template if it exists.

## TODO
- [X] Prototype a theme based template generator for master site
- [X] Index page using datatables
- [X] Sample Edit/New pages
- [X] New pluggable controller architecture
- [X] Default talon-lte template
- [X] Sidenav bar
- [X] Gettext archecture similar to Coherence
- [X] Move the project over to phx-1.3 architecture
- [X] Prototype resource based template overlays
- [X] Move the theme based layout templates to a generator
- [ ] --Change the auto generate slime templates to a generator and move the .eex templates to /priv--
- [X] Create a generator for generating the default template .eex files
- [X] Implement the create/update/delete actions in the controller
- [X] Fix the brunch problem pulling the the skins
- [X] Add database backended support for the index page datatables
- [X] Add a show template
- [X] Add links to the index page actions
- [ ] Index page filters (new design required). With live searching on the index page datatables, not sure if the existing Talon design even makes sense anymore.
- [ ] User new/edit state select should only show options based on the selected country.
- [X] Implenent boolean checkbox
- [ ] Implement date/time selection
- [ ] Implement remaining data types
- [ ] Add many-to-many support (Group and Tag schema already done)
- [ ] Multi-language support
- [ ] Much more

## Contributing

The new Talon architecture is under very active development. So, expect significant changes as we explore architectural and feature ideas.

Before starting to work on anything, please have a quick conversation with @smpallen99 on the relevant issue on [talonframework/talon](https://github.com/talonframework/talon/issues). If an issues does not exist, please create one. For realtime discussions, @smpallen99 can be reached on:

* #talon channel in https://chat.spallen.com (preferred - my own Phoenix chat app)
* #exadmin channel in Elixir's slack team
* skype `wedge99` (one-on-one voice/video)

Please review [CONTRIUBITING](CONTRIBUTING.md) and [CODE OF CONDUCT](CODE_OF_CONDUCT.md) for additional information.
## License

`talon` is Copyright (c) 2017 E-MetroTel

The source code is released under the MIT License.

Check [LICENSE](LICENSE) for more information.

