#' Package docs
#' @docType package
#' @name projectInit
#' @author Nathan Sheffield
#' @import devtools 
#' @import folderfun
#' 
#' @references \url{http://github.com/databio/projectInit}
NULL


#' Project workspace initializer
#'
#' \code{projectInit} sources the \code{00-init.R} or \code{projectInit.R} 
#' script for the project. You pass a complete folder or a relative path.
#'
#' @param projectName A string identifying your project.
#' @param codeDir Path to the folder of your code repository root.
#' @param procDir Path to folder containing processed project data.
#' @param rawDir Path to folder containing raw project data.
#' @param webDir Path to folder for web output.
#' @param outDir Path to a folder for output
#' @param resourcesDir Location of general-purpose resourcesRoot; default is to use 
#'                  system environment variable \code{RESOURCES}.
#' @param outputSubdir Location for project-specific output, resolved by 
#'                     \code{dirOut} and stored as option \code{ROUT.SUBDIR}.
#' @param scriptSubdir Name for the folder within \code{codeRoot} that 
#'                     stores the scripts for this project.
#' @param pepConfig Use to specify the (relative) location of your actual
#'     PEP config file.
#' @param subproject name of the subproject to be activated
#' @aliases project.init project.init2 go
#' @export
projectInit = function( projectName,
                        codeDir=NULL,
                        procDir=NULL,
                        rawDir=NULL,
                        webDir=NULL,
                        outDir=NULL,
                        resourcesDir=NULL,
                        outputSubdir=NULL, #deprecate?
                        scriptSubdir="src",
                        pepConfig=NULL,
                        subproject=NULL) {

    if (!is.null(outputSubdir)){
        .tidymsg("Found subdir: ", outputSubdir)
        projectInit::setOutputSubdir(outputSubdir)
    }

    # Keep a record of the function call so re can re-init if necessary.
    options(LOADEDPROJECT=match.call())

    # Init options
    # It drives me nuts when strings get processed as factors.
    options(stringsAsFactors=FALSE)    # treat strings as strings
    options(echo=TRUE)                 # show commands (?)
    options(menu.graphics=FALSE)       # suppress gui selection
    options(width=130)                 # optimized for full screen width
    options(scipen=15)                 # turn off scientific notation


    # 1. Set up folder functions
    # Here's a little helper function that just sets the folderfun to a specific
    # location if it was given, but otherwise sets it to the default.

    setffDefault = function(name, path, pathVar, postpend) {
        if (is.null(path)) {
            folderfun::setff(name, pathVar=pathVar, postpend=postpend)
        } else {
            folderfun::setff(name, path=path)
        }
    }

    o = utils::capture.output( { 
        setffDefault("Code", codeDir, "CODE", projectName)
        setffDefault("Proc", procDir, "PROCESSED", projectName)
        setffDefault("Raw", rawDir, "DATA", projectName)
        setffDefault("Web", webDir, "WEB", projectName)
        setffDefault("Out", outDir, "PROCESSED", file.path(projectName, "analysis"))

        folderfun::setff("Res", pathVar="RESOURCES")
        folderfun::setff("ResCache", ffRes(), postpend=file.path("cache", "RCache"))
        folderfun::setff("Cache", ffProc(), postpend="RCache")
        folderfun::setff("ProcRoot", pathVar="PROCESSED")
        folderfun::setff("RawRoot", pathVar="DATA")
        folderfun::setff("WebRoot", pathVar="WEB")
        folderfun::setff("OutRoot", pathVar="PROCESSED")
        folderfun::setff("Build", ffCode(), postpend="RBuild")
    }, type="message")
    # 2. Load PEP

    prj = NULL  # default value in case config is not found


    cfgFile = findConfigFile(ffCode(), pepConfig, projectName)

    if (!is.null(cfgFile)){
        message("Found config file: ", cfgFile)
        if (requireNamespace("pepr", quietly=TRUE)) {
            prj = pepr::Project(cfgFile, subproject)
           
            # Use loadr to keep the pep in a shared environment, if installed
            if (requireNamespace("loadr", quietly=TRUE)) {
                message("Loading project variables into shared variables environment...")
                loadr::eload(nlist(prj))
            } else {
                message("No loadr package, skipping shared environment loading")
            }
        }
    }

    # Notify if RGenomeUtils is not found.

    if (requireNamespace("RGenomeUtils", quietly=TRUE)) {
        message("Loaded RGenomeUtils")
    } else {
        message("No RGenomeUtils found.")
    }
        
    # 3. Initialize project by calling init script
    # Finalize the initialization by sourcing the project-specific
    # initialization script
    initCandidates = ffCode(scriptSubdir, list("00-init.R", "projectInit.R"))
    projectScript = .firstFile(files=initCandidates)

    if ( !is.null(projectScript)) {
        message(sprintf("Initializing: '%s'...", projectScript))
        source(projectScript)
        options(PROJECT.INIT=projectScript)
    } else {
        msg = sprintf(.tidytxt("No project init script: '%s'."), initCandidates[1])
        .tidymsg(msg)
    }


    invisible(prj)
}

#' Helper alias to re-run init script, using your current dir settings.
#' @export
projectRefresh = function() { 
    if (is.null(getOption("LOADEDPROJECT"))) {
        stop("No loaded project.")
    }
    message("Re-initializing project...")
    eval(getOption("LOADEDPROJECT"))
}

#' Alias
#' @export
pr = projectRefresh

createDir = function(...) {
    dir.create(..., showWarnings=FALSE, recursive=TRUE)
}

#' Creates and sets outputSubdir
#' @param ... Arguments passed to \code{ffProc()}.
#' @export
setOutputSubdir = function(...) {
    setff("Out", path=ffProc("analysis", ...))
}

#' Package handling function
#' Detach a custom packages, re-document, re-install, and re-load.
#' Useful if I'm debugging packages and want to try the new version.
#' Expects it to be in the ${CODE} folder by default
#' @param pkg Package name
#' @param path Local path to package folder
#' @param roxygenize   Should I roxygen2::roxygenize it to refresh documentation
#'     before installing?
#' @param compileAttributes    Should I Rcpp:compileAttributes to refresh Rcpp
#'     code before installing?
#' @export
refreshPackage = function(pkg, path=Sys.getenv("CODE"),
                        compileAttributes=TRUE, roxygenize=TRUE) {
    packageDir = file.path(path, pkg)
    if (!file.exists(packageDir)) { 
        stop("Package does not exist: ", packageDir)
    }
    if (compileAttributes) {
        requireNamespace("Rcpp")
        Rcpp::compileAttributes(packageDir)
    }
    if (roxygenize) {
        #requireNamespace("roxygen2")
        #roxygen2::roxygenize(packageDir)
        devtools::document(packageDir)
    }
    # devtools::unload is superior because it also unloads dlls, so this
    # function could work with packages containing c++ code.
    tryCatch({
        devtools::unload(packageDir)
    }, error = function(e) {
        message(e)
    } )
    utils::install.packages(packageDir, repos=NULL)
    library(pkg, character.only=TRUE)
}



################################################################################
# DEBUGGING FUNCTIONS
################################################################################

#' Quick shortcut procedure for toggling error mode (for my convenience)
#' te for Toggle Error
#' @export
toggleError = function() {
    if(is.null(getOption("error"))) {
        options(error=utils::recover)
        message("Error mode set to 'recover'")
    } else{
        options(error=NULL)
        message("Error mode set to 'NULL'")
    }
}
#' Alias of toggleError()
#' @export
te = toggleError



#' Nathan's magical named list function.
#' This function is a drop-in replacement for the base list() function,
#' which automatically names your list according to the names of the 
#' variables used to construct it.
#' It seamlessly handles lists with some names and others absent,
#' not overwriting specified names while naming any unnamed parameters.
#' Took me awhile to figure this out.
#'
#' @param ...   arguments passed to list()
#' @return A named list object.
#' @export
#' @examples
#' x=5
#' y=10
#' nlist(x,y) # returns list(x=5, y=10)
#' list(x,y) # returns unnamed list(5, 10)
nlist = function(...) {
    fcall = match.call(expand.dots=FALSE)
    l = list(...)
    if(!is.null(names(list(...)))) { 
        names(l)[names(l) == ""] = fcall[[2]][names(l) == ""]
    } else {    
        names(l) = fcall[[2]]
    }
    return(l)
}