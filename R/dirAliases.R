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
			"consider invoking 'projectInit()' to establish that and other options.")
	}
	if (is.null(getOption("ROUT.SUBDIR"))) {
		return(dirOutRoot(...))
	} else {
		return(dirWrap("ROUT.DIR", sub=getOption("ROUT.SUBDIR"), ...))
	}
}

# output dir without any subdir.
dirOutRoot = function(...) inff("ROUT.DIR", ...)

#' Processed Data Dir (old way)
#' Helper wrapper to get data for this project.
#' @export
dirData = function(...) inff("PROCESSED.PROJECT", ...)

#' Processed Data Dir
#' Helper wrapper to get data for this project.
#' @export
dirProc = function(...) inff("PROCESSED.PROJECT", ...)

#' Raw Data Dir
#' Helper wrapper to get data for this project.
#' @export
dirRaw = function(...) inff("RAW.PROJECT", ...)

#' Resource Dir
#' Helper wrapper to get data for this project.
#' @export
dirRes = function(...) inff("RESOURCES", ...)

#' Web Dir
#' Helper wrapper to get data for this project.
#' @export
dirWeb = function(...) inff("WEB", ...)

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
	setff("ROUT.SUBDIR", ...)
}
#' Helper function to silently create a subdirectory in the parent project
#' directory (the processed data directory).
#'
#' @export
createRootSubdir = function(...) {
	dir.create(dirData(...), showWarnings=FALSE, recursive=TRUE)

}

