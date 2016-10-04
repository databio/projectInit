#' Package docs
#' @docType package
#' @name project.init
#' @author Nathan Sheffield
#'
#' @references \url{http://github.com/sheffien}
NULL


#' Define project init function
#' All this does is source the 00-init.R script for the project,
#' you pass a complete folder or a relative path.
#' @export
project.init = function(codeDir=NULL, dataDir=NULL, RESOURCES=Sys.getenv("RESOURCES")) {
	if (is.null(Sys.getenv("RESOURCES"))) {
		stop ("you must set global environmental variable $RESOURCES before calling project.init().");
	}

	# Set PROJECT.DIR
	if (is.null(codeDir)) { # null working dir.
		warning ("PROJECT.DIR set to current dir: ", getwd());
		PROJECT.DIR=paste0(getwd(), "/");
	} else if (substr(codeDir,1,1) != "/" & substr(codeDir,1,1) != "~") {
		# It is a relative path
		if (is.null(Sys.getenv("CODEBASE"))) {
			# relative path requires global base directory
			stop("You should set an environment variable CODEBASE in your .bashrc to use the shared R utils most effectively. Then you can refer to R projects with relative paths, making the code portable and sharable.");
		}
		PROJECT.DIR = paste0(Sys.getenv("CODEBASE"), codeDir, "/")
	} else {
		#It's a global path
		PROJECT.DIR = codeDir
	}

	# Set PROCESSED.PROJECT
	if (is.null(dataDir)) { 
		warning ("PROCESSED.PROJECT set to current PROJECT.DIR: ", PROJECT.DIR);
		PROCESSED.PROJECT=PROJECT.DIR
	} else if (substr(dataDir,1,1) != "/" & substr(dataDir,1,1) != "~") {
		# It is a relative path
		if (is.null(Sys.getenv("PROCESSED"))) {
			# relative path requires global base directory
			stop("You should set an environment variable PROCESSED in your .bashrc to use the shared R utils most effectively. Then you can refer to R projects with relative paths, making the code portable and sharable.");
		}
		PROCESSED.PROJECT = paste0(Sys.getenv("PROCESSED"), dataDir, "/")
	} else {
		#It's a global path
		PROCESSED.PROJECT = dataDir
	}

	# Finalize the options.
	options(PROJECT.DIR=PROJECT.DIR)
	options(PROCESSED.PROJECT=PROCESSED.PROJECT)
	setwd(getOption("PROJECT.DIR"));
	message("PROJECT.DIR:", getOption("PROJECT.DIR"));
	message("PROCESSED.PROJECT:", getOption("PROCESSED.PROJECT"));
	# Set PROCESSED.PROJECT

	init.dirs();
	init.options();
	init.packages();
	init.utilities();

	# Finalize the initialization by sourcing the project-specific
	# initialization script
	project.scripts = c(paste0(getOption("PROJECT.DIR"), "src/00-init.R"), paste0(getOption("PROJECT.DIR"), "projectInit.R"))
	initialized=FALSE;
	for (project.script in project.scripts) {
		if (file.exists(project.script)) {
			message("Initializing ", project.script, "...")
			source(project.script)
			options(PROJECT.INIT=project.script);
			initialized=TRUE;
			break;
		}
	}
	if (!initialized) {
		message("Found no project init script.")
	}
}

#' Make a secret alias function so I don't have to type so much
#' @export
go = project.init

#' Helper alias to re-run init script, using your current dir settings.
project.refresh = function() { 
	project.init(codeDir=getOption("PROJECT.DIR"), dataDir=getOption("PROCESSED.PROJECT"), RESOURCES=Sys.getenv("RESOURCES"))
}

#' Helper alias for the common case where the data and code dirs share
#' a name.
#' @export
project.init2 = function(codeDir) {
	project.init(codeDir=codeDir, dataDir=codeDir, RESOURCES=Sys.getenv("RESOURCES"))
}


#If you make changes to a utility script and want to reload it, this will reset all the utilities, and reset you to the CWD.
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
#rp = renewProject;

#' @export
rp= function() {
	if (is.null(getOption("PROJECT.DIR"))) {
		stop("No loaded project.")
	}
	project.init(getOption("PROJECT.DIR"), getOption("PROCESSED.PROJECT"))
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
#' Should probably be renamed in the future.
#'
#' @param utility The name of the R script in the util directory to load.
#' @param utilityDir Directory to search (custom)
#' @export
utility = function(utilities, utilityDir="") {
	#build a list of ordered directories to search for the utility.
	utilityDirs = c(utilityDir, getOption("PROJECT.DIR"), paste0(getOption("RGENOMEUTILS"), "R/"));
	for (u in utilities) {
		foundUtility = FALSE;
		#looks for a directory with the utilities; loads it in priority order.
		for (d in utilityDirs) {
			if ( substr(d,nchar(d), nchar(d)) != "/") {
				d = paste(d, "/"); 
			}
			utilitySource = paste0(d, u);
			if (file.exists(utilitySource)) { foundUtility=TRUE; break; }
		}
		if (!foundUtility) {
			message("No utility found in dirs:", paste(utilityDirs, collapse=";"));
			return(NULL);
		}
		message("Loading utility: ", utilitySource);
		source(utilitySource);
		options(LOADED.UTILITIES=unique(append(getOption("LOADED.UTILITIES"), u))) #keep this in options for renewProject();
	}
}

loadAllUtilities = function(utilityDir=getOption("RGENOMEUTILS")) {
	utilities = list.files(utilityDir, pattern=".R$")
	utility(utilities, utilityDir);
}


#just a quick helper function to run a grep on the shared utility directory to locate a function if you don't know where the utility is.
#should also test getOption("WORKING.DIR") ??
findUtility = function(string) {
	cmd = paste0('grep ', string, ' ', getOption("RGENOMEUTILS"), "R/*.R")
	message(cmd);
	res = system(cmd, intern=TRUE);
	res;
}


#######################################################################
# Populate default local directories
#######################################################################
#these should not need to change, unless
#you want to adjust the default relative folder directory structure

#'@export
nenv = function() {
	# env variables
	envVars = c("RAWDATA", "PROCESSED", "RESOURCES", "WEB", "CODEBASE")
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

#Sys.getenv("PROCESSED")
#Sys.getenv("CODEBASE")
#Sys.getenv("RESOURCES")


init.dirs = function() {
# Set defaults:
setOption("ROUT.DIR", paste0(getOption("PROCESSED.PROJECT"), "analysis/"));
setOption("RESOURCES.RCACHE", paste0(Sys.getenv("RESOURCES"), "cache/RCache/"));		#Global RData cache
#Project RData cache
# Now put it in the data folder
#setOption("RCACHE.DIR", paste0(getOption("PROJECT.DIR"), "RCache/")); 		
setOption("RCACHE.DIR", paste0(getOption("PROCESSED.PROJECT"), "RCache/")); 		

# Should deprecate these ones:

setOption("RBUILD.DIR", paste0(getOption("PROJECT.DIR"), "RBuild/"));
}


#' Sets an option value if it's not already set.
#' Why only if it's not already set?
#' @param option Name of option
#' @param value Value to set it to
#' @param force overwrite if already set.
#' @export
setOption = function(option, value, force=TRUE) {
	# I can't remember why I made it default to not forcing, so I'm changing it.
	if(is.null(getOption(option)) || force) {
		optionsToSet = list(value)
		names(optionsToSet) = option
		options(optionsToSet)
	}
}


#' ROUT Wrapper function
#'
#' pass a relative file path, and this will append the global results
#' directory to it. Use it to stick output easily directly into the results
#' directory, instead of relative to the local directory.
#' This allows you to keep a working directory that's relative to your code,
#' but put the results somewhere else (which is shared space).
#' @export
dirout = function(...) {
	paste0(getOption("ROUT.DIR"), ...);
}

#' Helper function to silently create a subdirectory in the project
#' output directory.
#'
#' @export
createOutputSubdir = function(...) {
	dir.create(dirout(...), showWarnings = FALSE, recursive = TRUE)

}

#' Data Dir
#' Helper wrapper to get data for this project.
#' @export
dirdata = function(...) {
	paste0(getOption("PROCESSED.PROJECT"), ...);
}

#' Resource Dir
#' Helper wrapper to get data for this project.
#' @export
dirres = function(...) {
	paste0(Sys.getenv("RESOURCES"), ...);
}

#' Web Dir
#' Helper wrapper to get data for this project.
#' @export
dirweb = function(...) {
	paste0(Sys.getenv("WEB"), ...);
}



init.options = function() {
#######################################################################
# Load basic options (so far, these are not project-specific).
#######################################################################
options(scipen=15); 						#turn off scientific notation
options(menu.graphics=FALSE);				#suppress gui selection
options(echo=TRUE);							#show commands (?)
#It drives me nuts when strings get processed as factors.
options(stringsAsFactors=FALSE);			#treat strings as strings
#grDevices::X11.options(type = "Xlib");					#Faster plotting
options(width=154);							#optimized for full screen width.

}

init.packages = function() {
#######################################################################
# Load common packages
#######################################################################
#Used commonly and loading quickly enough to warrant loading every time
message("init.packages() ...");
library(devtools)
library(data.table, quietly=TRUE);
library(extrafont);
library(simpleCache);
library(ggplot2);
}


init.utilities = function() {
#######################################################################
	if (! is.null(getOption("RGENOMEUTILS")) ) {
		devtools::load_all(getOption("RGENOMEUTILS"))
	} else {
		message("You can connect the RGenomeUtils if you set an option named RGENOMEUTILS pointing to the RGenomeUtils repo; I usually set this in my .Rprofile")
	} 
	#utility("funcCommon.R")
	#utility("funcLoadSharedData.R")
}




