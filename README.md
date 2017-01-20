# project.init

`project.init` is an R package that helps you create self-contained project repositories. It's like an R project manager. It just sets up your R environment, connects you to data and code by providing easy-to-use shortcut functions.

## Environment

`project.init` uses environment variables to enable portablility across systems and users. You should set up 3 environment variables to use `project.init` most effectively: `CODEBASE`, `RESOURCES`, and `PROCESSED`.

For example, in my environment, I use this to my `.bashrc`:

```
# Pointer to the collection of git repos
export CODEBASE="$HOME/code/"

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
