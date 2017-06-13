# Filesystem utilities

#' Determine whether a path is absolute.
#'
#' @param path The path to check for seeming absolute-ness.
#' @return Flag indicating whether the \code{path} appears to be absolute.
#' @family path operations
#' @export
IsAbsolute = function(path) {
  firstChar = substr(path, 1, 1)
  return(identical("/", firstChar) | identical("~", firstChar))
}


MakeAbsPath = function(perhapsRelative, parent) {
    # Create an absolute path from a primary target and a parent candidate.
    #
    # Args:
    #   perhapsRelative: Path to primary target directory.
    #   parent: Path to parent folder to use if target isn't absolute.
    #
    # Returns:
    #   Target itself if already absolute, else target nested within parent.
    if (IsAbsolute(perhapsRelative)) {
        abspath = perhapsRelative
    } else {
        abspath = file.path(parent, perhapsRelative)
    }
    if (!IsAbsolute(abspath)) {
        errmsg = sprintf("Relative path '%s' and parent '%s' failed to create
            absolute path: '%s'", perhapsRelative, parent, abspath)
        stop(errmsg)
    }
    return(abspath)
}


#' Determine whether a path is absolute.
#'
#' @param target The path to check for seeming absolute-ness.
#' @param env_var Name of the environment variable with parent folder candidate.
#' @param when_null Strategy for deriving target if its argument is null.
#' @return \code{target} if it's already absolute, result of \code{when_null()} 
#'   if \code{target} is null, or joined version of parent candidate stored in 
#'   \code{env_var} and (relative) \code{target}.
#' @family path operations
#' @export
MakePath = function(target, envVar, whenNull) {
  
    if (is.null(target)) {
        fullpath = whenNull()
        warning ("Using alternative for null target: ", fullpath);
    } else {
        parent = Sys.getenv(envVar)
        if (identical("", parent)) { stop(Hint(envVar)) }

        if (IsAbsolute(target)) {
            fullpath = target
        } else {
            fullpath = file.path(parent, target)
        }

    }

    if (!IsAbsolute(fullpath)) {
        stop(sprintf("Could not make absolute path from primary
                target %s and parent candidate %s (from %s)",
                target, parent, envVar))
    }
    return(fullpath)
}
