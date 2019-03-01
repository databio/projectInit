# Filesystem utils

#' Determine whether a path is absolute.
#'
#' @param path The path to check for seeming absolute-ness.
#' @return Flag indicating whether the \code{path} appears to be absolute.
#' @family path operations
.isAbsolute = function(path) {
    firstChar = substr(path, 1, 1)
    return(identical("/", firstChar) | identical("~", firstChar))
}


#' Create an absolute path from a primary target and a parent candidate.
#
#' @param perhapsRelative: Path to primary target directory.
#' @param  parent: Path to parent folder to use if target isn't absolute.
#
#' @return Target itself if already absolute, else target nested within parent.
.makeAbsPath = function(perhapsRelative, parent) {
    if (.isAbsolute(perhapsRelative)) {
        abspath = perhapsRelative
    } else {
        abspath = file.path(parent, perhapsRelative)
    }
    if (!.isAbsolute(abspath)) {
        errmsg = sprintf("Relative path '%s' and parent '%s' failed to create
            absolute path: '%s'", perhapsRelative, parent, abspath)
        stop(errmsg)
    }
    return(abspath)
}


#' Make suggestion about configuring an environment variable.
#'
#' @param varname   Name of environment variable to suggest setting.
#' @return  Message about benefit of setting the given environment variable.
.niceGetEnv = function(varname) {
    value = Sys.getenv(varname)
    if (identical("", value)) {
        warning(.tidytxt(sprintf("You should set environment variable %s to use the 
        shared R utils most effectively. Then you can refer to R projects 
        with relative paths, making the code portable and sharable.", varname)))
    }
    return(value)
}






#' Returns an absolute path
#'
#' @param target The path to check if absolute.
#' @param parent Name of the environment variable with parent folder candidate.
#' @param default Default to use if target is null.
#' @return \code{target} if it's already absolute, result of \code{when_null()} 
#'   if \code{target} is null, or joined version of parent candidate stored in 
#'   \code{env_var} and (relative) \code{target}.
#' @family path operations
.selectPath = function(target, parent, default) {
    if (is.null(target)) {
        fullpath = default
        warning("Using alternative for null target: ", fullpath)
    } else {
        if (.isAbsolute(target)) {
            fullpath = target
        } else {
            fullpath = file.path(parent, target)
        }
    }

    if (!.isAbsolute(fullpath)) {
        stop(sprintf("Could not make absolute path from primary
                target %s and parent candidate %s (from %s)",
                target, parent, parentEnvVar))
    }
    return(fullpath)
}


.isDefined = function(var) { ! (is.na(var) | is.null(var)) }


.tidytxt = function(...) {
    paste(strwrap(paste(..., collapse=" ")), collapse="\n")
}

.tidywrn = function(...) {
    warning(.tidytxt(...))
}

.tidymsg = function(...) { 
    message(.tidytxt(...))
}