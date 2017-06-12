# Filesystem utilities

#' Determine whether a path is absolute.
#'
#' @param path The path to check for seeming absolute-ness.
#' @return Flag indicating whether the \code{path} appears to be absolute.
#' @family path operations
#' @export
IsAbsolute = function(path) {
  first_char = substr(path, 1, 1)
  return(identical("/", first_char) | identical("~", first_char))
}


MakeAbsPath = function(perhaps_relative, parent) {
    # Create an absolute path from a primary target and a parent candidate.
    #
    # Args:
    #   perhaps_relative: Path to primary target directory.
    #   parent: Path to parent folder to use if target isn't absolute.
    #
    # Returns:
    #   Target itself if already absolute, else target nested within parent.
    if (IsAbsolute(perhaps_relative)) {
        abspath = perhaps_relative
    } else {
        abspath = file.path(parent, perhaps_relative)
    }
    if (!IsAbsolute(abspath)) {
        errmsg = sprintf("Relative path '%s' and parent '%s' failed to create
            absolute path: '%s'", perhaps_relative, parent, abspath)
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
MakePath = function(target, env_var, when_null) {
  
    if (is.null(target)) {
        fullpath = when_null()
        warning ("Using alternative for null target: ", fullpath);
    } else {
        parent = Sys.getenv(env_var)
        if (identical("", parent)) { stop(Hint(env_var)) }

        if (IsAbsolute(target)) {
            fullpath = target
        } else {
            fullpath = file.path(parent, target)
        }

    }

    if (!IsAbsolute(fullpath)) {
        stop(sprintf("Could not make absolute path from primary
                target %s and parent candidate %s (from %s)",
                target, parent, env_var))
    }
    return(fullpath)
}
