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


#' This is Nathan's custom utility loading function.
#' It goes with my R utility package, and is used to load up utilities from
#' that package. It was originally in funcCommon.R, but I moved it here
#' because that's actually a utility, which uses this function to load it,
#' so it's more natural if this loading function is here.
#'
#' It will search first any passed dir, then the working dir, and finally
#' the global RGENOMEUTILS for the script to load.
#'
#'
#' @param utility The name of the R script in the util directory to load.
#' @param utilityDir Directory to search (custom)
#' @export
utility = function(utilities, utilityDir="") {
  
  # Build a list of ordered directories to search for the utility.
  utilityDirs = c(utilityDir, getOption("PROJECT.DIR"), file.path(getOption("RGENOMEUTILS"), "R"));
  
  for (u in utilities) {
    foundUtility = FALSE;
    
    # Look for a directory with the utilities, and load it in priority order.
    for (d in utilityDirs) {
      
      # DEALING WITH SLASHES
      #if (substr(d, nchar(d), nchar(d)) != "/") {
        #d = paste(d, "/"); 
      #}
      
      utilitySource = file.path(d, u);
      if (file.exists(utilitySource)) { foundUtility = TRUE; break; }
    }
    
    if (!foundUtility) {
      message("No utility found in dirs:", paste(utilityDirs, collapse = ";"));
      return(NULL);
    }
    
    message("Loading utility: ", utilitySource);
    source(utilitySource);
    
    # Keep this in options for renewProject();
    options(LOADED.UTILITIES = unique(append(getOption("LOADED.UTILITIES"), u)))
  }
}


loadAllUtilities = function(utilityDir = getOption("RGENOMEUTILS")) {
  utilities = list.files(utilityDir, pattern = ".R$")
  utility(utilities, utilityDir);
}


# Quick helper function to run a grep on the shared utility directory to 
# locate a function if you don't know where the utility is. Should also 
# test getOption("WORKING.DIR") ??
findUtility = function(string) {
  cmd = sprintf("grep %s %s", string, file.path(getOption("RGENOMEUTILS"), "R", "*.R"))
  message(cmd);
  res = system(cmd, intern = TRUE);
  res;
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
