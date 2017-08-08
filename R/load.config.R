library("pryr")
library("utils")

kOldPipelinesSection = "pipelines_dir"
kRelativeSections = c("output_dir", kOldPipelinesSection, 
	"pipeline_interfaces", "results_subdir", "submission_subdir")

#' Loads a yaml config file
#' @param project A project (use default config file names for this project)
#' @param sp Subproject to activate
#' @param file file path to config file, allows you to specify an exact file.
#' @export
load.config = function(project=NULL, sp = NULL, filename=NULL, usesPathsSection = FALSE) {

	# Derive project folder from environment variables and project name.
	if (is.null(project)) { 
		projectDir = options("PROJECT.DIR")
	} else {
		codepath = Sys.getenv("CODE")
		projectDir = if (is.null(codepath) | identical("", codepath)) project else file.path(codepath, project)
	}

	# Load the project configuration file.
	cfgFile = FindConfigFile(projectFolder = projectDir,
		nameConfigFile = filename, projectName = project)
	if (!IsDefined(cfgFile)) {
		message("No config file found.")
		return()
	}
	cfg = yaml::yaml.load_file(cfgFile)
	message("Loaded config file: ", cfgFile)

	# Update based on subproject if one is specified.
	if (!is.null(sp)) {
		if (is.null(cfg$subprojects[[sp]])) {
			message("Subproject not found: ", sp)
			return()
		}
		cfg = modifyList(cfg, cfg$subprojects[[sp]])
		message("Loading subproject: ", sp)
	}
	
	# Show available subprojects.
	if (length(names(cfg$subprojects)) > 1) {
		message("Available subprojects: ", paste0(names(cfg$subprojects), collapse=","))
	}

	# Ensure that metadata (paths) are absolute and return the config.
	cfg$metadata = MakeMetadataSectionAbsolute(cfg,
		usesPathsSection = usesPathsSection, parent = dirname(cfgFile))
	return(cfg)
}


FindConfigFile = function(
	projectFolder, nameConfigFile = NULL, projectName = NULL) {

	# First, form the relative filepaths to consider as config file candidates.
	filenames = c("config.yaml", "project_config.yaml")    # Defaults
	if (!is.null(projectName)) {
		# Project-named config takes last priority.
		filenames = c(filenames, sprintf("%s.yaml", projectName))
	}
	# Explicitly specified config file name takes first priority.
	if (!is.null(nameConfigFile)) { filenames = c(nameConfigFile, filenames) }

	# A project's configuration file is in its metadata folder.
	candidates = sapply( filenames,
		function(filename) { file.path("metadata", filename) } )

	# Within current project directory, find the first configuration
	# file that exists from among a pool of config file names.
	ensureAbsolute = pryr::partial(MakeAbsPath, parent = projectFolder)
	cfgFile = FirstExtantFile(files = candidates, modify = ensureAbsolute)
	return(cfgFile)
}


FirstExtantFile = function(files, modify = identity) {
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
	modified = sapply(files, modify)
	return(modified[which(sapply(modified, FileExists))[1]])
}


ExpandPath = function(path) {

	# Handle null/empty input.
	if (!IsDefined(path)) { return(path) }

	# Helper functions
	chopPath = function(p) { if (p == dirname(p)) p else c(chopPath(dirname(p)), basename(p)) }
	expand = function(pathPart) { if (startsWith(pathPart, "$")) system(sprintf("echo %s", pathPart), intern = TRUE) else pathPart }

	# Split path; short-circuit return or ensure no reference to this folder.
	parts = chopPath(path)
	if (length(parts) < 2) { return(parts) }
	if (identical(".", parts[1])) { parts = parts[2:length(parts)] }

	# Expand any environment variables and return the complete path.
	fullPath = do.call(file.path, lapply(parts, expand))
	return(fullPath)
}

FileExists = function(fpath) { file_test("-f", fpath) }


MakeMetadataSectionAbsolute = function(config, usesPathsSection, parent) {

	# Enable creation of absolute path using given parent folder path.
	AbsViaParent = pryr::partial(MakeAbsPath, parent = parent)

	# For earlier project config file layout, handling each metadata
	# item in the same way, deriving absolute path from parent, was valid.
	if (usesPathsSection) { return(lapply(config$metadata, AbsViaParent)) }

	# With newer project config file layout,
	# certain metadata members are handled differently.
	absoluteMetadata = list()

	# Process each metadata item, handling each value according to attribute name.
	for (metadataAttribute in names(config$metadata)) {
		value = config$metadata[[metadataAttribute]]

		if (metadataAttribute %in% kRelativeSections) {
			if (metadataAttribute == kOldPipelinesSection) {
				warning(sprintf(
					"Config contains old pipeline location specification section: '%s'", 
					kOldPipelinesSection))
			}
			value = ExpandPath(value)
			if (!IsAbsolute(value)) {
				value = file.path(ExpandPath(config$metadata[["output_dir"]]), value)
			}
		}
		else { value = AbsViaParent(value) }    # No special handling

		# Check for and warn about nonexistent path before setting value.
		if (!(FileExists(value) | dir.exists(value))) {
			warning(sprintf("Value for '%s' doesn't exist: '%s'", metadataAttribute, value))
		}
		absoluteMetadata[[metadataAttribute]] = value
	}

	return(absoluteMetadata)
}
