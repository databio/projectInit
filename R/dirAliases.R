#' Direct a path into the project output directory
#'
#' Pass a relative file path, and this will prepend the global project results
#' directory to it. Use it to stick output easily directly into the results
#' directory, instead of relative to the local directory.
#' This allows you to keep a working directory that's relative to your code,
#' but put the results somewhere else (such as a shared results space).
#' @export
dirOut = function(...) {
	outdir = getOption("ROUT.DIR")
	if (is.null(outdir)) {
		warning("Null output dir 'ROUT.DIR';", 
			"consider invoking 'projectInit' to establish that and other options.")
	}
	if (is.null(getOption("ROUT.SUBDIR"))) {
		return(dirWrapOpt("ROUT.DIR", ...))
	} else {
		return(dirWrapOpt("ROUT.DIR", sub=getOption("ROUT.SUBDIR"), ...))
	}
}

# output dir without any subdir.
dirOutRoot = function(...) {
	dirWrapOpt("ROUT.DIR", ...)
}

#' Data Dir
#' Helper wrapper to get data for this project.
#' @export
dirData = function(...) {
	dirWrapOpt("PROCESSED.PROJECT", ...)
}


dirProc = function(...) {
	dirWrapOpt("PROCESSED.PROJECT", ...)
}




#' Raw Data Dir
#' Helper wrapper to get data for this project.
#' @export
dirRaw = function(...) {
	dirWrap("RAWDATA", ...)
}

#' Resource Dir
#' Helper wrapper to get data for this project.
#' @export
dirRes = function(...) {
	dirWrap("RESOURCES", ...)
}

#' Web Dir
#' Helper wrapper to get data for this project.
#' @export
dirWeb = function(...) {
	dirWrap("WEB", ...)
}

#' Generic function to prepend an environment variable directory
#' to your relative filepath.
dirWrap = function(var, ..., sub=NULL) {
	userPath = .sanitizeUserPath(...)
	if (is.null(sub)) {
		outputPath = file.path(Sys.getenv(var), userPath)
	} else {
		outputPath = file.path(Sys.getenv(var), sub, userPath)
	}
	return(outputPath)
}

# TODO: Standardize to options or envvars?
# Uses options instead of envs.
dirWrapOpt = function(var, ..., sub=NULL) {
	userPath = .sanitizeUserPath(...)
	if (is.null(sub)) {
		outputPath = file.path(getOption(var), userPath)
	} else {
		outputPath = file.path(getOption(var), sub, userPath)
	}
	return(outputPath)
}

# paste0() if given no values returns character(0); this doesn't play
# nicely with file.path, which returns bad value if any of the values are
# bad, instead of ignoring them. This function changes the default output to an 
# empty string so it can be passed to file.path without problems.
.sanitizeUserPath = function(...) {
	userPath = paste0(...)
	if (identical(userPath, character(0))) {
		# for a blank function call; that's allowed, give parent dir.
		userPath = ""
	}
	return(userPath)
}



#' Helper function to silently create a subdirectory in the project
#' output directory.
#'
#' @export
createOutputSubdir = function(...) {
	dir.create(dirOutRoot(...), showWarnings=FALSE, recursive=TRUE)
}

#' Creates and sets outputSubdir
#' @export
setOutputSubdir = function(...) {
	dir.create(dirOutRoot(...), showWarnings=FALSE, recursive=TRUE)
	.setOption("ROUT.SUBDIR", ...)
}
#' Helper function to silently create a subdirectory in the parent project
#' directory (the processed data directory).
#'
#' @export
createRootSubdir = function(...) {
	dir.create(dirData(...), showWarnings=FALSE, recursive=TRUE)

}

