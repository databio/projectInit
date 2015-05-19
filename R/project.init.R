#' Define project init function
#' All this does is source the 00-init.R script for the project,
#' you pass a complete folder or a relative path.
#' @export
project.init = function(codeDir=NULL, dataDir=NULL, SHARE.DIR=getOption("SHARE.DIR")) {
	if (is.null(getOption("SHARE.DIR"))) {
		stop ("you must set global option(\"SHARE.DIR\") before calling project.init().");
	}

	# Set WORKING.DIR
	if (is.null(codeDir)) { # null working dir.
		warning ("WORKING.DIR set to current dir: ", getwd());
		WORKING.DIR=paste0(getwd(), "/");
	} else if (substr(codeDir,1,1) != "/") {
		# It is a relative path
		if (is.null(getOption("PROJECT.CODE.BASE"))) {
			# relative path requires global base directory
			stop("You should set a global variable PROJECT.CODE.BASE in your .Rprofile to use Nathan's shared R utils most effectively. Then you can refer to R projects with relative paths, making the code portable and sharable.");
		}
		WORKING.DIR = paste0(getOption("PROJECT.CODE.BASE"), codeDir, "/")
	} else {
		#It's a global path
		WORKING.DIR = codeDir
	}

	# Set PROJECT.DATA.DIR
	if (is.null(dataDir)) { 
		warning ("PROJECT.DATA.DIR set to current WORKING.DIR: ", WORKING.DIR);
		PROJECT.DATA.DIR=WORKING.DIR
	} else if (substr(dataDir,1,1) != "/") {
		# It is a relative path
		if (is.null(getOption("PROJECT.DATA.BASE"))) {
			# relative path requires global base directory
			stop("You should set a global variable PROJECT.DATA.BASE in your .Rprofile to use Nathan's shared R utils most effectively. Then you can refer to R projects with relative paths, making the code portable and sharable.");
		}
		PROJECT.DATA.DIR = paste0(getOption("PROJECT.DATA.BASE"), dataDir, "/")
	} else {
		#It's a global path
		PROJECT.DATA.DIR = dataDir
	}

	# Finalize the options.
	options(WORKING.DIR=WORKING.DIR)
	options(PROJECT.DATA.DIR=PROJECT.DATA.DIR)
	setwd(getOption("WORKING.DIR"));
	message("WORKING.DIR:", getOption("WORKING.DIR"));
	message("PROJECT.DATA.DIR:", getOption("PROJECT.DATA.DIR"));
	# Set PROJECT.DATA.DIR

	init.dirs();
	init.options();
	init.packages();
	init.utilities();

	# Finalize the initialization by sourcing the project-specific
	# initialization script
	project.scripts = c(paste0(getOption("WORKING.DIR"), "src/00-init.R"), paste0(getOption("WORKING.DIR"), "projectInit.R"))
	initialized=FALSE;
	for (project.script in project.scripts) {
		if (file.exists(project.script)) {
			message("Initializing ", project.script, "...")
			source(project.script)
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
	project.init2(codeDir=getOption("WORKING.DIR"), dataDir=getOption("PROJECT.DATA.DIR"), SHARE.DIR=getOption("SHARE.DIR"))
}

#' Helper alias for the common case where the data and code dirs share
#' a name.
#' @export
project.init2 = function(codeDir) {
	project.init(codeDir=codeDir, dataDir=codeDir, SHARE.DIR=getOption("SHARE.DIR"))
}



#' This is Nathan's custom utility loading function.
#' It goes with my R utility package, and is used to load up utilities from
#' that package. It was originally in funcCommon.R, but I moved it here
#' because that's actually a utility, which uses this function to load it,
#' so it's more natural if this loading function is here.
#'
#' It will search first any passed dir, then the working dir, and finally
#' the global SHARE.RUTIL.DIR for the script to load.
#'
#' Should probably be renamed in the future.
#'
#' @param utility The name of the R script in the util directory to load.
#' @param utilityDir Directory to search (custom)
#' @export
utility = function(utilities, utilityDir="") {
	#build a list of ordered directories to search for the utility.
	utilityDirs = c(utilityDir, getOption("WORKING.DIR"), getOption("SHARE.RUTIL.DIR"));
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



#######################################################################
# Populate default local directories
#######################################################################
#these should not need to change, unless
#you want to adjust the default relative folder directory structure

init.dirs = function() {
options(SHARE.RUTIL.DIR=paste0(getOption("SHARE.DIR"), "R/"));		#Nathan's R Utilities path
options(SHARE.RCACHE.DIR=paste0(getOption("SHARE.DIR"), "RCache/"));		#Global RData cache
options(SHARE.DATA.DIR=paste0(getOption("SHARE.DIR"), "data/"));			#Global Shared Data
options(RCACHE.DIR=paste0(getOption("WORKING.DIR"), "RCache/")); 		#Project RData cache
options(RBUILD.DIR=paste0(getOption("WORKING.DIR"), "RBuild/"));			#Project build scripts
options(PROJECT.INIT=paste0(getOption("WORKING.DIR"), "src/00-init.R"));	#This script file name
setwd(getOption("WORKING.DIR"));
#dir.create(RDATA.DIR, showWarnings=FALSE);
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
library(devtools)
library(data.table, quietly=TRUE);
library(extrafont);
library(simpleCache);
library(ggplot2);
}


init.utilities = function() {
#######################################################################
utility("funcCommon.R")
utility("funcLoadSharedData.R")
}




