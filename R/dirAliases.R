#' Direct a path into the project output directory
#'
#' Pass a relative file path, and this will prepend the global project results
#' directory to it. Use it to stick output easily directly into the results
#' directory, instead of relative to the local directory.
#' This allows you to keep a working directory that's relative to your code,
#' but put the results somewhere else (such as a shared results space).
#' @export
dirOut = function(...) {
	if (is.null(getOption("ROUT.SUBDIR"))) {
		return(file.path(getOption("ROUT.DIR"), ...))
	} else {
		return(file.path(getOption("ROUT.DIR"), getOption("ROUT.SUBDIR"), ...))
	}
}

#' Data Dir
#' Helper wrapper to get data for this project.
#' @export
dirData = function(...) {
	file.path(getOption("PROCESSED.PROJECT"), ...)
}

#' Raw Data Dir
#' Helper wrapper to get data for this project.
#' @export
dirRaw = function(...) {
	file.path(Sys.getenv("RAWDATA"), ...)
}

#' Resource Dir
#' Helper wrapper to get data for this project.
#' @export
dirRes = function(...) {
	file.path(Sys.getenv("RESOURCES"), ...)
}

#' Web Dir
#' Helper wrapper to get data for this project.
#' @export
dirWeb = function(...) {
	dirWrap("WEB", ...)
}

#' Generic function to prepend an environment variable directory
#' to your relative filepath.
dirWrap = function(var, sub=NULL, ...) {
	if (is.null(sub)) {
		outputPath = file.path(Sys.getenv(var), ...)
	} else {
		outputPath = file.path(Sys.getenv(var), sub, ...)
	}
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

