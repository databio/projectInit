library("pryr")
library("utils")

#' Loads a yaml config file
#' @param project A project (use default config file names for this project)
#' @param sp Subproject to activate
#' @param file file path to config file, allows you to specify an exact file.
#' @export
load.config = function(project=NULL, sp = NULL, filename=NULL, uses_paths_section = FALSE) {

	# Derive project folder from environment variables and project name.
	if (is.null(project)) { 
		project_dir = options("PROJECT.DIR")
	} else {
		codepath = Sys.getenv("CODE")
		project_dir = if (is.null(codepath) | identical("", codepath)) project else file.path(codepath, project)
	}

	# Load the project configuration file.
	cfg_file = FindConfigFile(project_folder = project_dir,
		name_config_file = filename, project_name = project)
	if (!IsDefined(cfg_file)) {
		message("No config file found.")
		return()
	}
	cfg = yaml::yaml.load_file(cfg_file)
	message("Loaded config file: ", cfg_file)

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
		uses_paths_section = uses_paths_section, parent = dirname(cfg_file))
	return(cfg)
}


FindConfigFile = function(
	project_folder, name_config_file = NULL, project_name = NULL) {

	# First, form the relative filepaths to consider as config file candidates.
	filenames = c("config.yaml", "project_config.yaml")    # Defaults
	if (!is.null(project_name)) {
		# Project-named config takes last priority.
		filenames = c(filenames, sprintf("%s.yaml", project_name))
	}
	# Explicitly specified config file name takes first priority.
	if (!is.null(name_config_file)) { filenames = c(name_config_file, filenames) }

	# A project's configuration file is in its metadata folder.
	candidates = sapply( filenames,
		function(filename) { file.path("metadata", filename) } )

	# Within current project directory, find the first configuration
	# file that exists from among a pool of config file names.
	ensure_abs = pryr::partial(MakeAbsPath, parent = project_folder)
	cfg_file = FirstExtantFile(files = candidates, modify = ensure_abs)
	return(cfg_file)
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
	chop_path = function(p) { if (p == dirname(p)) p else c(chop_path(dirname(p)), basename(p)) }
	expand = function(path_part) { if (startsWith(path_part, "$")) system(sprintf("echo %s", path_part), intern = TRUE) else path_part }

	# Split path; short-circuit return or ensure no reference to this folder.
	parts = chop_path(path)
	if (length(parts) < 2) { return(parts) }
	if (identical(".", parts[1])) { parts = parts[2:length(parts)] }

	# Expand any environment variables and return the complete path.
	full_path = do.call(file.path, lapply(parts, expand))
	return(full_path)
}

FileExists = function(fpath) { file_test("-f", fpath) }


MakeMetadataSectionAbsolute = function(config, uses_paths_section, parent) {

	# Enable creation of absolute path using given parent folder path.
	AbsViaParent = pryr::partial(MakeAbsPath, parent = parent)

	# For earlier project config file layout, handling each metadata
	# item in the same way, deriving absolute path from parent, was valid.
	if (uses_paths_section) { return(lapply(config$metadata, AbsViaParent)) }

	# With newer project config file layout,
	# certain metadata members are handled differently.
	absolute_metadata = list()

	# Process each metadata item, handling each value according to attribute name.
	for (mdata_attr in names(config$metadata)) {
		value = config$metadata[[mdata_attr]]

		if (mdata_attr %in% c("output_dir", "pipelines_dir", "results_subdir", "submission_subdir")) {
			value = ExpandPath(value)
			if (!IsAbsolute(value)) {
				value = file.path(ExpandPath(config$metadata[["output_dir"]]), value)
			}
		}
		else { value = AbsViaParent(value) }    # No special handling

		# Check for and warn about nonexistent path before setting value.
		if (!(FileExists(value) | dir.exists(value))) {
			warning(sprintf("Value for '%s' doesn't exist: '%s'", mdata_attr, value))
		}
		absolute_metadata[[mdata_attr]] = value
	}

	return(absolute_metadata)
}
