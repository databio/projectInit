#' Package docs
#' @docType package
#' @name project.init
#' @author Nathan Sheffield
#'
#' @references \url{http://github.com/nsheff}
NULL


#' Define project init function
#' All this does is source the 00-init.R script for the project,
#' you pass a complete folder or a relative path.
#' @param code_dir
#' @export
project.init = function(code_dir = NULL, 
	data_dir = NULL, RESOURCES = Sys.getenv("RESOURCES")) {
	
	if (identical("", RESOURCES) | is.null(RESOURCES)) {
		stop ("Supply RESOURCES argument to project.init() or set 
			global environmental variable RESOURCES before calling.")
	}

	PROJECT.DIR = MakePath(code_dir, envVar = "CODE", whenNull = getwd)
	PROCESSED.PROJECT = MakePath(data_dir, 
		envVar = "PROCESSED", whenNull = function() { PROJECT.DIR })

	# Finalize the options.
	options(PROJECT.DIR = PROJECT.DIR)
	options(PROCESSED.PROJECT = PROCESSED.PROJECT)
	setwd(getOption("PROJECT.DIR"))
	message("PROJECT.DIR: ", getOption("PROJECT.DIR"))
	message("PROCESSED.PROJECT: ", getOption("PROCESSED.PROJECT"))

	init.dirs()
	init.options()
	init.utilities()

	# Finalize the initialization by sourcing the project-specific
	# initialization script
	init_script_path = file.path(getOption("PROJECT.DIR"), "src", "00-init.R")
	project.scripts = c(init_script_path, 
		file.path(getOption("PROJECT.DIR"), "projectInit.R"))
	initialized = FALSE;
	for (project.script in project.scripts) {
		if (file_test("-f", project.script)) {
			message(sprintf("Initializing: '%s'...", project.script))
			source(project.script)
			options(PROJECT.INIT = project.script);
			initialized = TRUE;
			break;
		}
	}
	if (!initialized) {
		message("Found no project init script. If you place a file in ", init_script_path,
			", it will be loaded automatically when you initialize this project.")
	}
}

#' Make a secret alias function so I don't have to type so much
#' @export
go = project.init

#' Helper alias to re-run init script, using your current dir settings.
project.refresh = function() { 
	project.init(code_dir = getOption("PROJECT.DIR"), 
		data_dir = getOption("PROCESSED.PROJECT"), 
		RESOURCES = Sys.getenv("RESOURCES"))
}

#' Helper alias for the common case where the data and code dirs share
#' a name.
#' @export
project.init2 = function(code_dir) {
	project.init(code_dir = code_dir, data_dir = code_dir, 
		RESOURCES = Sys.getenv("RESOURCES"))
}


# If you make changes to a utility script and want to reload it, this will reset all the utilities, and reset you to the CWD.
renewProject = function() {
	clearLoadFunctions("PROJECT.VARS");
	clearLoadFunctions("SHARE.VARS");
	loadedUtilities = unique(getOption("LOADED.UTILITIES"))
	options(LOADED.UTILITIES=NULL)
	saveWorkingDir = getwd();
	tryCatch( { source(getOption("PROJECT.INIT")); }, 
		error = function (e) { 
			message("Sourcing project.init failed:", e) 
		} )
	utToLoad = setdiff(loadedUtilities, unique(getOption("LOADED.UTILITIES")))
	lapply(utToLoad, utility); #reload previously loaded utilities
	setwd(saveWorkingDir);
	message(saveWorkingDir);
}


#' @export
rp = function() {
	if (is.null(getOption("PROJECT.DIR"))) {
		stop("No loaded project.")
	}
	project.init(getOption("PROJECT.DIR"), getOption("PROCESSED.PROJECT"))
}


#######################################################################
# Populate default local directories
#######################################################################
#these should not need to change, unless
#you want to adjust the default relative folder directory structure

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
	SetOption("ROUT.DIR", paste0(getOption("PROCESSED.PROJECT"), "analysis/"))
	# Global RData cache
	SetOption("RESOURCES.RCACHE", paste0(Sys.getenv("RESOURCES"), "cache/RCache/"))

	# Project RData cache
	# Now put it in the data folder
	SetOption("RCACHE.DIR", paste0(getOption("PROCESSED.PROJECT"), "RCache/")); 		

	# Should deprecate these ones:
	SetOption("RBUILD.DIR", paste0(getOption("PROJECT.DIR"), "RBuild/"));

}


# Load basic options (non-project-specific).

init.options = function() {
	# It drives me nuts when strings get processed as factors.
	options(stringsAsFactors=FALSE);			# treat strings as strings
	options(echo=TRUE);							# show commands (?)
	options(menu.graphics=FALSE);				# suppress gui selection
	options(width=130);							# Optimized for full screen width
	options(scipen=15); 						# turn off scientific notation
}

init.utilities = function() {
	if (! is.null(getOption("RGENOMEUTILS")) ) {
		devtools::load_all(getOption("RGENOMEUTILS"))
	} else {
		message("You can connect the RGenomeUtils if you set an option named 
			RGENOMEUTILS pointing to the RGenomeUtils repo; I usually set this in my .Rprofile")
	} 
}
