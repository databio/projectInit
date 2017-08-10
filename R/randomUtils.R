

.isDefined = function(var) { ! (is.na(var) | is.null(var)) }


#' Sets an option value if it's not already set.
#'
#' @param option Name of option
#' @param value Value to set it to
#' @param force overwrite if already set.
.setOption = function(option, value, force = TRUE) {
	if(is.null(getOption(option)) || force) {
		optionsToSet = list(value)
		names(optionsToSet) = option
		options(optionsToSet)
	}
}

# Populate default local directories
# These need not change, unless you want to adjust
# the default relative folder directory structure.
.initDirs = function() {
		# Set defaults:
	.setOption("ROUT.DIR", file.path(getOption("PROCESSED.PROJECT"), "analysis"))

	# Global RData cache
	.setOption("RESOURCES.RCACHE", file.path(Sys.getenv("RESOURCES"), "cache", "RCache"))

	# Project RData cache
	.setOption("RCACHE.DIR", file.path(getOption("PROCESSED.PROJECT"), "RCache")) 

	# Should deprecate these ones:
	.setOption("RBUILD.DIR", file.path(getOption("PROJECT.DIR"), "RBuild"))
}

# Load basic options (non-project-specific).
.initOptions = function() {
	# It drives me nuts when strings get processed as factors.
	options(stringsAsFactors=FALSE)    # treat strings as strings
	options(echo=TRUE)                 # show commands (?)
	options(menu.graphics=FALSE)       # suppress gui selection
	options(width=130)                 # optimized for full screen width
	options(scipen=15)                 # turn off scientific notation
}

.initUtilities = function() {
	if (! is.null(getOption("RGENOMEUTILS")) ) {
		devtools::load_all(getOption("RGENOMEUTILS"))
	} else {
		message("You can connect the RGenomeUtils if you set an option named 
			RGENOMEUTILS pointing to the RGenomeUtils repo; I usually set this in my .Rprofile")
	} 
}


.nicetxt = function(...) {
	paste(strwrap(paste(..., collapse=" ")), collapse="\n")
}

.nicewrn = function(...) {
	warning(.nicetxt(...))
}

.nicemsg = function(...) { 
	message(.nicetxt(...))
}