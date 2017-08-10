# Filesystem utilities

#' Determine whether a path is absolute.
#'
#' @param path The path to check for seeming absolute-ness.
#' @return Flag indicating whether the \code{path} appears to be absolute.
#' @family path operations
#' @export
isAbsolute = function(path) {
  firstChar = substr(path, 1, 1)
  return(identical("/", firstChar) | identical("~", firstChar))
}


# Create an absolute path from a primary target and a parent candidate.
#
#' @param perhapsRelative: Path to primary target directory.
#' @param  parent: Path to parent folder to use if target isn't absolute.
#
#' @return
# Target itself if already absolute, else target nested within parent.
makeAbsPath = function(perhapsRelative, parent) {
	if (isAbsolute(perhapsRelative)) {
		abspath = perhapsRelative
	} else {
		abspath = file.path(parent, perhapsRelative)
	}
	if (!isAbsolute(abspath)) {
		errmsg = sprintf("Relative path '%s' and parent '%s' failed to create
			absolute path: '%s'", perhapsRelative, parent, abspath)
		stop(errmsg)
	}
	return(abspath)
}


#' Returns a full path
#'
#' @param target The path to check for seeming absolute-ness.
#' @param parentEnvVar Name of the environment variable with parent folder candidate.
#' @param default Default to use if target is null.
#' @return \code{target} if it's already absolute, result of \code{when_null()} 
#'   if \code{target} is null, or joined version of parent candidate stored in 
#'   \code{env_var} and (relative) \code{target}.
#' @family path operations
.getPath = function(target, parentEnvVar, default) {
	if (is.null(target)) {
		fullpath = default
		warning ("Using alternative for null target: ", fullpath);
	} else {
		parent = Sys.getenv(parentEnvVar)
		if (identical("", parent)) { stop(.hint(parentEnvVar)) }

		if (isAbsolute(target)) {
			fullpath = target
		} else {
			fullpath = file.path(parent, target)
		}
	}

	if (!isAbsolute(fullpath)) {
		stop(sprintf("Could not make absolute path from primary
				target %s and parent candidate %s (from %s)",
				target, parent, parentEnvVar))
	}
	return(fullpath)
}
