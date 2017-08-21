#' Package docs
#' @docType package
#' @name project.init
#' @author Nathan Sheffield
#' @import devtools
#'
#' @references \url{http://github.com/databio/project.init}
NULL


#' Initialize workspace for a given project
#'
#' This function will source the 00-init.R script for the project.
#' You pass a complete folder or a relative path.
#'
#' @param codeDir	
#' @export
projectInit = function(codeDir=NULL, dataDir=NULL, subDir=NULL,
						resources=Sys.getenv("RESOURCES")) {

	if (identical("", resources) | is.null(resources)) {
		stop(strwrap("Supply RESOURCES argument to project.init() or set 
			global environmental variable RESOURCES before calling."))
	}

	if (is.null(dataDir)) {
		# Assume that a null data directory means to use the codeDir variable.
		# This was previously accomplished with project.init2, but that is
		# not actually necessary with this update.
		dataDir = codeDir

	}

	if (!is.null(subDir)){
		.nicemsg("Found subdir: ", subDir)
		project.init::setOutputSubdir(subDir)
	}

	PROJECT.DIR = .selectPath(codeDir, parent=.niceGetEnv("CODE"), default=getwd())
	PROCESSED.PROJECT = .selectPath(dataDir, parent=.niceGetEnv("PROCESSED"),
		default=PROJECT.DIR)

	# Finalize the options.
	options(PROJECT.DIR=PROJECT.DIR)
	options(PROCESSED.PROJECT=PROCESSED.PROJECT)

	if (!file.exists(PROJECT.DIR)) {
		stop("Directory does not exist or is not writable: ", PROJECT.DIR)
	}

	setwd(getOption("PROJECT.DIR"))
	message("PROJECT.DIR: ", getOption("PROJECT.DIR"))
	message("PROCESSED.PROJECT: ", getOption("PROCESSED.PROJECT"))

	.initDirs()
	.initOptions()
	.initUtilities()


	# Initialize config file if we can find one
	prj = NULL  # default value in case config is not found
	cfgFile = findConfigFile(PROJECT.DIR)
	if (!is.null(cfgFile)){
		message("Found config file: ", cfgFile)
		if (requireNamespace("pepr")) {
			prj = pepr::Project(cfgFile)
		}
	}
	if (requireNamespace("RGenomeUtils")) {
		message("Loading project variables into shared variables environment...")
		RGenomeUtils::eload(nlist(prj))
	} else {
		message("No RGenomeUtils, skipping project variables' storage")
	}
	
	
	# Finalize the initialization by sourcing the project-specific
	# initialization script
	projdir = getOption("PROJECT.DIR")
	init_candidates = sapply(
		X = c("00-init.R", "projectInit.R"), 
		FUN = function(s) { file.path(projdir, s) })
	initialized = FALSE
	for (projectScript in init_candidates) {
		if (file_test("-f", projectScript)) {
			message(sprintf("Initializing: '%s'...", projectScript))
			source(projectScript)
			options(PROJECT.INIT = projectScript)
			initialized = TRUE
			break
		}
	}
	if (!initialized) {
		msg = sprintf(
			"No project init script. If you write '%s', it's loaded automatically by projectInit.", init_candidates[1])
		.nicemsg(msg)
	}
	
	return(prj)
}

#' Alias for backward compatibility
#' @export 
project.init = projectInit

#' Alias for backward compatibility
#' @export
project.init2 = projectInit

#' Make a secret alias function so I don't have to type so much
#' @export
go = projectInit

#' Helper alias to re-run init script, using your current dir settings.
#' @export
projectRefresh = function() { 
	if (is.null(getOption("PROJECT.DIR"))) {
		stop("No loaded project.")
	}
	project.init(codeDir=getOption("PROJECT.DIR"), 
		dataDir=getOption("PROCESSED.PROJECT"),
		subDir=getOption("ROUT.SUBDIR"),
		resources=Sys.getenv("RESOURCES"))
}

#' Alias
#' @export
rp = projectRefresh


#' Package handling function
#' Detach a custom packages, re-document, re-install, and re-load.
#' Useful if I'm debugging packages and want to try the new version.
#' Expects it to be in the ${CODE} folder by default
#' @param pkg Package name
#' @param roxygenize	Should I roxygen2::roxygenize it to refresh documentation before installing?
#' @param compileAttributes	Should I Rcpp:compileAttributes to refresh Rcpp code before installing?
#' @export
refreshPackage = function(pkg, path=Sys.getenv("CODE"),
						compileAttributes=TRUE, roxygenize=TRUE) {
	packageDir = file.path(path, pkg)
	if (!file.exists(packageDir)) { 
		stop("Package does not exist: ", packageDir)
	}
	if (compileAttributes) {
		requireNamespace("Rcpp")
		Rcpp::compileAttributes(packageDir)
	}
	if (roxygenize) {
		#requireNamespace("roxygen2")
		#roxygen2::roxygenize(packageDir)
		devtools::document(packageDir)
	}
	# devtools::unload is superior because it also unloads dlls, so this
	# function could work with packages containing c++ code.
	tryCatch({
		devtools::unload(packageDir)
	}, error = function(e) {
		message(e)
	} )
	install.packages(packageDir, repos=NULL)
	library(pkg, character.only=TRUE)
}


#' Show project environment variables
#'
#' Displays the environment variables that are set and used by this package.
#'@export
penv = function() {
	# env variables
	envVars = c("RAWDATA", "PROCESSED", "RESOURCES", "WEB", "CODE")
	envVarsValues = sapply(envVars, Sys.getenv)
	
	nShareOptionsList = c("PROJECT.DIR", "PROJECT.INIT", 
		"PROCESSED.PROJECT",
		"RESOURCES.RCACHE",
		"RCACHE.DIR",
		"RBUILD.DIR",
		"ROUT.DIR",
		"ROUT.SUBDIR",
		"RGENOMEUTILS")
	value = sapply(nShareOptionsList, getOption)
	rbind(cbind(envVarsValues), cbind(value))
}
