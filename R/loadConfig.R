#' used for my internal project naming scheme. 
#' returns a config file at a default location,
#' given a project name.
findConfigFile = function(projectFolder, nameConfigFile=NULL, 
							projectName=NULL) {

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
		cfgFile = firstExtantFile(files=candidates, modify=ensureAbsolute)
		return(cfgFile)
	}, error = function(e) {
		message("Can't find config file.")
		return()
	})
}


# Find the first extant file from a sequence of candidates.
#
# Args:
#   files: The sequence file names or paths to consider.
#   parent: Path to the folder to which each element considered 
#           should be joined if the element isn't absolute path.
#   modify: Function with which to modify each element before 
#           checking existence.
#
# Returns:
#   (Absolute) path to the first element that exists. NA if 
#   no element considered resolves to valid filesystem location.
firstExtantFile = function(files, modify=identity) {

	fileExists = function(fpath) { file_test("-f", fpath) }

	modified = sapply(files, modify)
	return(modified[which(sapply(modified, fileExists))[1]])
}

