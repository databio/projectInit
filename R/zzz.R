.onLoad = function(libname, pkgname) {
  # Do some nasty side-effecting upon package startup.
	library("devtools")
	devtools::install_github("databio/simpleCache")
	invisible()
}