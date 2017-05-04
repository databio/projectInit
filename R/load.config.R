library("pryr")
library("utils")

#' Loads a yaml config file
#' @param project A project (use default config file names for this project)
#' @param sp Subproject to activate
#' @param file file path to config file, allows you to specify an exact file.
#' @export
load.config = function(project=NULL, sp=NULL, filename=NULL) {

	if (is.null(project)) { 
		project_dir = options("PROJECT.DIR")
	} else {
		codepath = Sys.getenv("CODE")
		project_dir = if(is.null(codepath) | identical("", codepath)) project else file.path(codepath, project)
	}
	
	# If no file is specified, try these default locations
	metadata_prefix = function(filename) { file.path("metadata", filename) }
	filenames = c("config.yaml", "project_config.yaml", 
		sprintf("%s.yaml", project))
	yamls = sapply(filenames, metadata_prefix)
	
	# Prioritize given filename over defaults.
	if (!is.null(filename)) {
		yamls = c(filename, yamls)
	}

	ensure_abs = pryr::partial(MakeAbsPath, parent = project_dir)
	cfg_file = FirstExtantFile(files = yamls, parent = project_dir, modify = ensure_abs)
	if (!IsDefined(cfg_file)) {
		message("No config file found.")
		return()
	}
	
	cfg = yaml::yaml.load_file(cfg_file)
	message("Loaded config file: ", cfg_file)
	
	if (!is.null(sp)) {
		# Update with subproject variables.
		spc = cfg$subprojects[[sp]]
		if (is.null(spc)) {
			message("Subproject not found: ", sp)
			return()
		}
		cfg = modifyList(cfg, cfg$subprojects[[sp]])
		message("Loading subproject: ", sp)
	}
	
	# Show available subprojects.
	sps = names(cfg$subprojects)
	if (length(sps) > 1) { 
		message("Available subprojects: ", paste0(sps, collapse=","))
	}

	# Make metadata absolute.
	# TODO: consider an apply-like function already implemented here.
	AbsViaParent = pryr::partial(MakeAbsPath, parent = dirname(cfg_file))
	cfg$metadata = lapply(cfg$metadata, AbsViaParent)

	return(cfg)
}


FirstExtantFile = function(files, parent, modify = identity) {
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

	# DEBUG
	write(sprintf("FILES: %s", paste0(files, collapse=", ")), file=stdout())
	write(sprintf("PARENT: %s", parent), file=stdout())
	write(sprintf("MODIFIED: %s", paste0(sapply(files, modify), collapse = ", ")), file=stderr())
	modified = sapply(files, modify)
	modified[which(sapply(modified, FileExists))[1]]
}


FileExists = function(fpath) { file_test("-f", fpath) }
