#' Locator of config file for a project.
#'
#' \code{findConfigFile} returns the path to a config file for a project 
#' given a particular folder. It allows a \code{projectName} or a 
#' \code{nameConfigFile} to take precedence in the search, but it searches
#' for files with suitable config-like default names. It also allows a 
#' \code{projectName} with which to create another high-priority filename 
#' to look for.
#'
#' @param projectFolder: Path to folder for project.
#' @param nameConfigFile: Specific config file name, given top priority for 
#'                        the search.
#' @param projectName: Name for the project, from which a secondary 
#'                     high-priority config file name is derived.
#' @return Path to the top-prioirty config file found; \code{NULL} if no 
#'         config file could be found.
#' @export
findConfigFile = function(
	projectFolder, nameConfigFile=NULL, projectName=NULL) {

	# First, form the relative filepaths to consider as config file candidates.
	filenames = c("config.yaml", "project_config.yaml", "pconfig.yaml")    # Defaults
	
	if (!is.null(projectName)) {
		# Project-named config takes last priority.
		filenames = c(filenames, sprintf("%s.yaml", projectName))
	}
	if (!is.null(nameConfigFile)) {
		# Explicitly specified config file name takes first priority.
		filenames = c(nameConfigFile, filenames)
	}

	# A project's configuration file is in its metadata folder.
	candidates = sapply( filenames,
		function(filename) { file.path("metadata", filename) } )

	# Within current project directory, find the first configuration
	# file that exists from among a pool of config file names.
	tryCatch( { 
		ensureAbsolute = pryr::partial(.makeAbsPath, parent=projectFolder)
		cfgFile = firstFile(files=candidates, modify=ensureAbsolute)
		return(cfgFile)
	}, error = function(e) {
		confPatt = "*_config.yaml"
		message(sprintf("Did not find fixed-name config (%s); trying match: %s", 
			paste0(filenames, collapse = ", "), confPatt))
		suffixMatches = Sys.glob(.makeAbsPath(
			perhapsRelative = file.path("metadata", confPatt), parent = projectFolder))
		numConfMatch = length(suffixMatches)
		if (numConfMatch == 1) suffixMatches else {
			ctx = if (numConfMatch > 1) sprintf("Multiple (%d) config pattern matches: %s", 
				numConfMatch, paste0(suffixMatches, collapse = ", ")) else "No config matches"
			message("Can't determine config file (%s)", ctx)
		}
	})
}


#' Locator of first file from given sequence that exists.
#'
#' \code{firstFile} examines the filesystem and selects the first file
#' from the given sequence that exists on it.
#'
#' @param files: The sequence file names or paths to consider.
#' @param modify: How to modify each file before checking existence.
#' @return (Absolute) path to the first file that exists.
#'         \code{NULL} if there isn't one.
firstFile = function(files, modify=identity) {
	fileExists = function(fpath) { file_test("-f", fpath) }
	modified = sapply(files, modify)
	for (modpath in modified) { if (file_test("-f", modpath)) return(modpath) }
}

