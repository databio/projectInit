Hint = function(varname) {
  # Make suggestion about configuring an environment variable.
  # 
  # Args:
  #   varname: Name of environment variable to suggest setting.
  # 
  # Returns:
  #   Message about benefit of setting the given environment variable.
  return(sprintf("You should set environment variable %s to use the 
    shared R utils most effectively. Then you can refer to R projects 
    with relative paths, making the code portable and sharable.", varname))
}


IsDefined = function(var) { ! (is.na(var) | is.null(var)) }


#' Sets an option value if it's not already set.
#'
#' @param option Name of option
#' @param value Value to set it to
#' @param force overwrite if already set.
#' @export
SetOption = function(option, value, force = TRUE) {
  if(is.null(getOption(option)) || force) {
    optionsToSet = list(value)
    names(optionsToSet) = option
    options(optionsToSet)
  }
}

#######################################################################
# Populate default local directories
#######################################################################
# These need not change, unless you want to adjust
# the default relative folder directory structure.

#'@export
nenv = function() {
  # env variables
  envVars = c("RAWDATA", "PROCESSED", "RESOURCES", "WEB", "CODE")
  envVarsValues = sapply(envVars, Sys.getenv)
  
  nShareOptionsList = c("PROJECT.DIR", "PROJECT.INIT", 
    "PROCESSED.PROJECT",
    "RESOURCES.RCACHE",
    "RCACHE.DIR",
    "RBUILD.DIR",
    "ROUT.DIR",
    "RGENOMEUTILS")
  value = sapply(nShareOptionsList, getOption)
  rbind(cbind(envVarsValues), cbind(value))
}


init.dirs = function() {
    # Set defaults:
  SetOption("ROUT.DIR", file.path(getOption("PROCESSED.PROJECT"), "analysis"))

  # Global RData cache
  SetOption("RESOURCES.RCACHE", file.path(Sys.getenv("RESOURCES"), "cache", "RCache"))

  # Project RData cache
  SetOption("RCACHE.DIR", file.path(getOption("PROCESSED.PROJECT"), "RCache"));     

  # Should deprecate these ones:
  SetOption("RBUILD.DIR", file.path(getOption("PROJECT.DIR"), "RBuild"));

}

# Load basic options (non-project-specific).
init.options = function() {
  # It drives me nuts when strings get processed as factors.
  options(stringsAsFactors = FALSE);    # treat strings as strings
  options(echo = TRUE);                 # show commands (?)
  options(menu.graphics = FALSE);       # suppress gui selection
  options(width = 130);                 # optimized for full screen width
  options(scipen = 15);                 # turn off scientific notation
}

init.utilities = function() {
  if (! is.null(getOption("RGENOMEUTILS")) ) {
    devtools::load_all(getOption("RGENOMEUTILS"))
  } else {
    message("You can connect the RGenomeUtils if you set an option named 
      RGENOMEUTILS pointing to the RGenomeUtils repo; I usually set this in my .Rprofile")
  } 
}
