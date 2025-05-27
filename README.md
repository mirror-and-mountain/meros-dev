<a href="https://mirrorandmountain.com" target="_blank"><img src="https://github.com/mirror-and-mountain/assets/raw/main/logos/png/mm-logo-slate-transparent-512.png" width="100" alt="MIRROR AND MOUNTAIN Logo"></a>

## MEROS DEV

### About
This package provides a containerised development environment for working on Meros themes, plugins and packages. It utilises a php-apache image and installs Wordpress using wp-cli. The environment will automatically clone various meros repositories into the correct locations for development and is compatible with Docker Desktop for local development as well as Github Codespaces.

The purpose of this environment is for working on mirror-and-mountain's source Meros projects. It is not an environment for working on your own themes that utilise the [Meros Framework](https://github.com/mirror-and-mountain/meros-framework). For that, we recommend using the [wp-env](https://developer.wordpress.org/block-editor/reference-guides/packages/packages-env/) package from Wordpress. 

>**Important Note:** The container built by this package is **not** intended for use in production environments.

### Getting Started
#### Fork Meros Repositories
Most of the Meros repositories have protected branches. If you want to contribute changes, please be sure to fork the repositories you want to work on and create pull requests to have your changes reviewed. 

There are four types of project you can choose to work on: themes, frameworks, plugins and extensions. Review the devcontainer.json file in this package to see the environment variables used to clone the various repositories of these types. Note that only one Meros theme may be installed in a dev environment and this is defined by the MEROS_THEME variable. The [Meros Framework](https://github.com/mirror-and-mountain/meros-framework) is always installed. You can select which plugins and extensions to clone by adding comma separated values matching each project's name in the MEROS_PLUGINS and MEROS_EXTENSIONS variables.

#### Github Codespaces
To use this environment in Github Codespaces, you can either fork this repository and launch a Codespace from your fork, or use composer to create a project like so:

```console
composer create-project mirror-and-mountain/meros-dev meros-dev
```

You can then initialise Git on your meros-dev project and publish it to your own Github account. From there, you can launch a Codespace. The environment will automatically use your Github username to clone your forked versions of the repositories you want to work on. The environment will fallback to mirror-and-mountain's origin repos, but you won't be able to push your changes.


#### Local Development
To use this environment locally, make sure you have [Docker Desktop](https://www.docker.com/products/docker-desktop/) installed and running. We also recommend using [VS Code](https://code.visualstudio.com/) with the relevant 'devcontainer' extensions installed. You can either fork this repository and clone it to your local machine, or create a new meros-dev project using Composer. Once your meros-dev project is open in VS Code, you should be prompted to reopen it inside a Dev Container. 

>**Important:** To utilise your forked meros project repositories, you must set the FORK_OWNER environment variable in .devcontainer.json. Set this to your Github username to have the environment clone your forked repositories rather than mirror-and-mountain's origin repos.

#### Additional Notes
- In Github Codespaces, the live Wordpress site can be found at url following this convention: "https://your-codespace-name-80.app.github.dev/wp." See the 'ports' panel in VS Code to find the link (add '/wp' to the end of it for Wordpress and '/wp/wp-admin' for the dashboard).
- In local environments, Wordpress will be available at http://localhost:8000/wp.

### License 
This package and the Meros Framework are open-sourced software licensed under the MIT license. Our Wordpress themes and plugins follow the [Wordpress GPL](https://make.wordpress.org/themes/handbook/review/required/) licensing guidelines.
