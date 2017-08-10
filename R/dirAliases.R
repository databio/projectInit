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
		return(dirWrapOpt("ROUT.DIR", sub="ROUT.SUBDIR", ...))
	}
}

#' Data Dir
#' Helper wrapper to get data for this project.
#' @export
dirData = function(...) {
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
	if (is.null(sub)) {
		outputPath = file.path(Sys.getenv(var), paste0(...))
	} else {
		outputPath = file.path(Sys.getenv(var), sub, paste0(...))
	}
	return(outputPath)
}

# TODO: Standardize to options or envvars?
# Uses options instead of envs.
dirWrapOpt = function(var, ..., sub=NULL) {
	if (is.null(sub)) {
		outputPath = file.path(getOption(var), paste0(...))
	} else {
		outputPath = file.path(getOption(var), sub, paste0(...))
	}
	return(outputPath)
}




#' Helper function to silently create a subdirectory in the project
#' output directory.
#'
#' @export
createOutputSubdir = function(...) {
	dir.create(dirOut(...), showWarnings=FALSE, recursive=TRUE)
}

#' Creates and sets outputSubdir
#' @export
setOutputSubdir = function(...) {
	dir.create(dirOut(...), showWarnings=FALSE, recursive=TRUE)
	.setOption("ROUT.SUBDIR", ...)
}
#' Helper function to silently create a subdirectory in the parent project
#' directory (the processed data directory).
#'
#' @export
createRootSubdir = function(...) {
	dir.create(dirData(...), showWarnings=FALSE, recursive=TRUE)

}

