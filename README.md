# project.init

`project.init` is an R package that helps you load a project-specific R workspace. It reads environment variables to coordinate your working directory, code location, raw data folders, and output folders. It then provides universal function so you don't have to worry about keeping track of annoying file path bookkeeping, but can concentrate on your R code instead. This lets you easily work in different environments and share inputs and outputs across sessions and across users.

## Environment

`project.init` uses environment variables to enable portablility across systems and users. You should set up 3 environment variables to use `project.init` most effectively: `CODE`, `RESOURCES`, and `PROCESSED`.

For example, in my environment, I use this to my `.bashrc`:

```
# Pointer to the collection of git repos
export CODE="$HOME/code/"

# Pointer to the common shared resources directory
export RESOURCES="/scratch/ns5bc/resources/"

# Pointer to the 'processed data' filesystem
export PROCESSED="/scratch/ns5bc/processed/"
```

## Install

It's just on github. Use devtools:

```
devtools::install_github("nsheff/project.init")
```

## Setting up .Rprofile

Add this to your .Rprofile:
```
options(RGENOMEUTILS="~/code/RGenomeUtils/")
tryCatch( {
	library(project.init)
}, error = function(e) {
	message(e)
})
```
