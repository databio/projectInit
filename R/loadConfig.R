# File: loadConfig.R
# Tool to facilitate--using common naming conventions--finding project 
# configuration file.


#' Locator of first file from given sequence that exists.
#'
#' \code{.firstFile} examines the filesystem and selects the first file
#' from the given sequence that exists on it.
#'
#' @param files: The sequence file names or paths to consider.
#' @param modify: How to modify each file before checking existence.
#' @return (Absolute) path to the first file that exists.
#'         \code{NULL} if there isn't one.
.firstFile = function(files, modify=identity) {

	modifiedFilePaths = sapply(files, modify)

	for (modpath in modifiedFilePaths) { 
		if (file_test("-f", modpath)) return(modpath) 
	}
}


#' Locator of config file for a project.
#'
#' \code{findConfigFile} returns the path to a config file for a project 
#' given a particular folder. It allows a \code{projectName} or a 
#' \code{projectConfig} to take precedence in the search, but it searches
#' for files with suitable config-like default names. It also allows a 
#' \code{projectName} with which to create another high-priority filename 
#' to look for.
#'
#' @param projectFolder: Path to folder for project.
#' @param projectConfig: Specific config file name, given top priority for 
#'                        the search.
#' @param projectName: Name for the project, from which a secondary 
#'                     high-priority config file name is derived.
#' @return Path to the top-prioirty config file found; \code{NULL} if no 
#'         config file could be found.
#' @export
findConfigFile = function(
	projectFolder, projectConfig=NULL, projectName=NULL) {

	# Find the first configuration file that exists from among a pool of config
	# file names.

	# First, form the relative filepaths to consider as config file candidates.
	filenames = c("config.yaml", "project_config.yaml", "pconfig.yaml")    # Defaults
	
	# Append project-named config as last priority, if projectName is provided
	if (!is.null(projectName)) {
		filenames = c(filenames, sprintf("%s.yaml", projectName))
	}

	# Explicitly specified config file name takes first priority.
	if (!is.null(projectConfig)) {
		filenames = c(projectConfig, filenames)
	}

	# Prepend metadata folder, and make paths absolute.
	candidates = lapply(filenames, function(filename) {
			.makeAbsPath(file.path("metadata", filename), parent=projectFolder)
		})

	cfgFile = .firstFile(files=candidates)
	if (length(cfgFile) > 0) {
		return(cfgFile)
	} else {
		message("Did not find fixed-name config: ", paste(candidates, collapse="; "))
		return(NULL)
	}
}

