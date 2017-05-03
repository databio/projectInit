# Package handling functions

#' Detach a custom packages, re-document, re-install, and re-load.
#' Useful if I'm debugging packages and want to try the new version.
#' Expects it to be in the ~/rpack/ package folder. by default
#' @param pkg Package name
#' @param roxygenize	Should I roxygen2::roxygenize it to refresh documentation before installing?
#' @param compileAttributes	Should I Rcpp:compileAttributes to refresh Rcpp code before installing?
#' @export
refreshPackage = function(pkg, path = Sys.getenv("CODE"), compileAttributes = TRUE, roxygenize = TRUE) {
	packageDir = paste0(path, pkg);
	if (!file.exists(packageDir)) { 
		stop("Package does not exist: ", packageDir)
	}
	if (compileAttributes) {
		requireNamespace("Rcpp")
		Rcpp::compileAttributes(packageDir);
	}
	if (roxygenize) {
		requireNamespace("roxygen2")
		roxygen2::roxygenize(packageDir);
	}
#	tryCatch({ unloadNamespace(pkg) }, error = function(e) { message(e) })
	# devtools::unload is superior because it also unloads dlls, so this
	# function could work with packages containing c++ code.
	tryCatch({ devtools::unload(packageDir) }, error = function(e) { message(e) })
	install.packages(packageDir, repos=NULL);
	library(pkg, character.only=TRUE);
}

