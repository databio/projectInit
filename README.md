# project.init

`project.init` is an R package that helps you create self-contained project repositories. It's like an R project manager. It just sets up your R environment, connects you to data and code by providing easy-to-use shortcut functions.

# Environment

`project.init` uses environment variables to enable portablility across systems and users.

Add this to your `.bashrc`:

# Pointer to the collection of git repos
export CODEBASE="$HOME/code/"

# Legacy variable: just points to RGenomeUtils repo
export SHARE_DIR="~/code/RGenomeUtils/"

# Pointer to the common shared resources directory
export RESOURCES="/data/groups/lab_bock/shared/resources/"

# Install

It's just on github. Use devtools:

```
devtools::install_github("nsheff/project.init")
```

