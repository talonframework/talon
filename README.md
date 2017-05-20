# ExAdmin

This is a new ExAdmin project, located under the new Github Group [ex-admin](https://github.com/ex-admin). This is a complete redesign of ExAdmin. See the justification and goals below.

> <b><span style="color: #FA366A;">IMPORTANT NOTE</span></b>
>
> This project is still is a work in progress and it not ready for public use yet. Please use this project if you would to contribute to the new archecture.
>
> We are considering renaming the ExAdmin project. Personally I, and I suspect others, use ExAdmin for more than backend Administrative projects. I use it as the front end on a number of internal IT systems. I find the the 'admin` name gives the perception that its only for admin interfaces. The new archecture is much more decomposible and customizable. So it lends itself more for a generic sie builder than the previous version.
>
> The project is still in the exploritory stage. Much of the API has not been documented yet, nor any real test coverage added. When we finalized on the overall archtecture, we will go back and complete the docs and tests.
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
  - avoid the sensitivity of direct generators when updating ExAdmin
  - might making theming much easier
- componentize each concern (views/templates, controllers, schema)
- buffer the dependency on Ecto to support other approaches to describe and reflect the schema of resources

> <b><span style="color: #FA366A;">NOTE:</span></b>
>
> **This will be a break point release. No backwards compatibility!!**

See [this issue](https://github.com/smpallen99/ex_admin/issues/367) for more details.

## TODO
- [X] Prototype a theme based template generator for master site
- [X] Index page using datatables
- [X] Sample Edit/New pages
- [X] New pluggable controller architecture
- [X] Default admin-lte template
- [X] Sidenav bar
- [X] Gettext archecture similar to Coherence
- [ ] Move the project over to phx-1.3 architecture
- [ ] Prototype resource based template overlays
- [ ] Move the theme based layout templates to a generator
- [ ] Change the auto generate slime templates to a generator and move the .eex templates to /priv
- [ ] Create a generator for generating the default template .eex files
- [ ] Implement the create/update/delete actions in the controller
- [ ] Move the admin template to ExAdmin
- [ ] Fix the brunch problem pulling the the skins
- [ ] Add database backended support for the index page datatables
- [ ] Add a show template
- [ ] Add links to the index page actions
- [ ] Index page filters (new design required). With live searching on the index page datatables, not sure if the existing ExAdmin design even makes sense anymore.
- [ ] User new/edit state select should only show options based on the selected country.
- [ ] Implenent boolean on/off toggle
- [ ] Implement date/time selection
- [ ] Implement remaining data types
- [ ] Add many-to-many support (Group and Tag schema already done)
- [ ] Multi-language support
- [ ] Much more

## Contributing

The new ExAdmin architecture is under very active development. So, expect significant changes as we explore architectural and feature ideas.

Before starting to work on anything, please have a quick conversation with @smpallen99 on the relevant issue on [ex-admin/ex_admin](https://github.com/ex-admin/ex_admin/issues). If an issues does not exist, please create one. For realtime discussions, @smpallen99 can be reached on:

* #exadmin channel in https://chat.spallen.com (preferred - my own Phoenix chat app)
* #exadmin channel in Elixir's slack team
* skype `wedge99` (one-on-one voice/video)

Please review [CONTRIUBITING](CONTRIBUTING.md) and [CODE OF CONDUCT](CODE_OF_CONDUCT.md) for additional information.
## License

`ex_admin` is Copyright (c) 2015-2017 E-MetroTel

The source code is released under the MIT License.

Check [LICENSE](LICENSE) for more information.

