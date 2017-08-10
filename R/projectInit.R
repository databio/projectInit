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
		project.init::setOutputSubdir(subDir)
	}

	PROJECT.DIR = .getPath(codeDir, parentEnvVar="CODE", default=getwd())
	PROCESSED.PROJECT = .getPath(dataDir, 
		parentEnvVar="PROCESSED", default=PROJECT.DIR)

	# Finalize the options.
	options(PROJECT.DIR=PROJECT.DIR)
	options(PROCESSED.PROJECT=PROCESSED.PROJECT)
	setwd(getOption("PROJECT.DIR"))
	message("PROJECT.DIR: ", getOption("PROJECT.DIR"))
	message("PROCESSED.PROJECT: ", getOption("PROCESSED.PROJECT"))

	.initDirs()
	.initOptions()
	.initUtilities()

	# Finalize the initialization by sourcing the project-specific
	# initialization script
	initScriptPath = file.path(getOption("PROJECT.DIR"), "src", "00-init.R")
	projectScripts = c(initScriptPath, 
		file.path(getOption("PROJECT.DIR"), "projectInit.R"))
	initialized = FALSE
	for (projectScript in projectScripts) {
		if (file_test("-f", projectScript)) {
			message(sprintf("Initializing: '%s'...", projectScript))
			source(projectScript)
			options(PROJECT.INIT = projectScript)
			initialized = TRUE
			break
		}
	}
	if (!initialized) {
		message(strwrap("Found no project init script. If you place a file in ",
		initScriptPath, ", it will be loaded automatically when you initialize
		this project."))
	}
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
		requireNamespace("roxygen2")
		roxygen2::roxygenize(packageDir)
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
		"RGENOMEUTILS")
	value = sapply(nShareOptionsList, getOption)
	rbind(cbind(envVarsValues), cbind(value))
}
