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
#' @param codeDir
#' @export
projectInit = function(codeDir = NULL, 
	dataDir = NULL, RESOURCES = Sys.getenv("RESOURCES")) {
	if (identical("", RESOURCES) | is.null(RESOURCES)) {
		stop(strwrap("Supply RESOURCES argument to project.init() or set 
			global environmental variable RESOURCES before calling."))
	}

	if (is.null(data_dir)) {
		# Assume that a null data directory means to use the code_dir variable.
		# This was previously accomplished with project.init2, but that is
		# not actually necessary with this update.
		data_dir = code_dir

	}

	PROJECT.DIR = MakePath(codeDir, envVar = "CODE", whenNull = getwd)
	PROCESSED.PROJECT = MakePath(dataDir, 
		envVar = "PROCESSED", whenNull = function() { PROJECT.DIR })

	# Finalize the options.
	options(PROJECT.DIR = PROJECT.DIR)
	options(PROCESSED.PROJECT = PROCESSED.PROJECT)
	setwd(getOption("PROJECT.DIR"))
	message("PROJECT.DIR: ", getOption("PROJECT.DIR"))
	message("PROCESSED.PROJECT: ", getOption("PROCESSED.PROJECT"))

	initDirs()
	initOptions()
	initUtilities()

	# Finalize the initialization by sourcing the project-specific
	# initialization script
	initScriptPath = file.path(getOption("PROJECT.DIR"), "src", "00-init.R")
	projectScripts = c(initScriptPath, 
		file.path(getOption("PROJECT.DIR"), "projectInit.R"))
	initialized = FALSE;
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
go = project.init

#' Helper alias to re-run init script, using your current dir settings.
project.refresh = function() { 
	project.init(codeDir = getOption("PROJECT.DIR"), 
		dataDir = getOption("PROCESSED.PROJECT"), 
		RESOURCES = Sys.getenv("RESOURCES"))
}

#' @export
rp = function() {
	if (is.null(getOption("PROJECT.DIR"))) {
		stop("No loaded project.")
	}
	project.init(getOption("PROJECT.DIR"), getOption("PROCESSED.PROJECT"))
}

