

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
#' Creates and sets outputSubdir
#' @export
setOutputSubdir = function(...) {
	dir.create(dirout(...), showWarnings = FALSE, recursive = TRUE)
	setOption("ROUT.SUBDIR", ...);
}

#' as dirout() but uses a subdir set by setOutputSubdir().
#' @export
diroutsub = function(...) {
	subdir = paste0(getOption("ROUT.DIR"), getOption("ROUT.SUBDIR"))
	message("Subdir: ", subdir)
	paste0(subdir, ...);
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
	paste0(getOption("PROCESSED.PROJECT"), ...);
}

#' Raw Data Dir
#' Helper wrapper to get data for this project.
#' @export
dirraw = function(...) {
	paste0(Sys.getenv("RAWDATA"), ...);
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

