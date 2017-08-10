#' ROUT Wrapper function
#'
#' pass a relative file path, and this will append the global results
#' directory to it. Use it to stick output easily directly into the results
#' directory, instead of relative to the local directory.
#' This allows you to keep a working directory that's relative to your code,
#' but put the results somewhere else (which is shared space).
#' @export
dirout = function(...) {
	file.path(getOption("ROUT.DIR"), ...)
}

#' Helper function to silently create a subdirectory in the project
#' output directory.
#'
#' @export
createOutputSubdir = function(...) {
	dir.create(dirout(...), showWarnings = FALSE, recursive = TRUE)
}

#' Creates and sets outputSubdir
#' @export
setOutputSubdir = function(...) {
	dir.create(dirout(...), showWarnings = FALSE, recursive = TRUE)
	SetOption("ROUT.SUBDIR", ...)
}

#' as dirout() but uses a subdir set by setOutputSubdir().
#' @export
diroutsub = function(...) {
	subdir = file.path(getOption("ROUT.DIR"), getOption("ROUT.SUBDIR"))
	message("Subdir: ", subdir)
	file.path(subdir, ...)
}

#' Helper function to silently create a subdirectory in the parent project
#' directory (the processed data directory).
#'
#' @export
createRootSubdir = function(...) {
	dir.create(dirdata(...), showWarnings = FALSE, recursive = TRUE)

}

#' Data Dir
#' Helper wrapper to get data for this project.
#' @export
dirdata = function(...) {
	file.path(getOption("PROCESSED.PROJECT"), ...)
}

#' Raw Data Dir
#' Helper wrapper to get data for this project.
#' @export
dirraw = function(...) {
	file.path(Sys.getenv("RAWDATA"), ...)
}


#' Resource Dir
#' Helper wrapper to get data for this project.
#' @export
dirres = function(...) {
	file.path(Sys.getenv("RESOURCES"), ...)
}

#' Web Dir
#' Helper wrapper to get data for this project.
#' @export
dirweb = function(...) {
	file.path(Sys.getenv("WEB"), ...)
}

