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
dirOutRoot = function(...) ffROUT.DIR(...)

#' Processed Data Dir (old way)
#' Helper wrapper to get data for this project.
#' @export
dirData = function(...) {
	warning("dirData is deprecated; please use dirProc")
	dirProc(...)
}

#' Processed Data Dir
#' Helper wrapper to get data for this project.
#' @export
dirProc = function(...) ffPROCESSED.PROJECT(...)

#' Raw Data Dir
#' Helper wrapper to get data for this project.
#' @export
dirRaw = function(...) ffRAW.PROJECT(...)

#' Resource Dir
#' Helper wrapper to get data for this project.
#' @export
dirRes = function(...) ffRESOURCES(...)

#' Web Dir
#' Helper wrapper to get data for this project.
#' @export
dirWeb = function(...) ffWEB(...)

