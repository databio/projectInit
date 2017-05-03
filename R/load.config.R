library("utils")

#' Loads a yaml config file
#' @param project A project (use default config file names for this project)
#' @param sp Subproject to activate
#' @param file file path to config file, allows you to specify an exact file.
#' @export
load.config = function(project=NULL, sp=NULL, filename=NULL) {
	if ( ! requireNamespace("yaml", quietly=TRUE)) {
		warning("Package yaml is required to load yaml config files.")
		return
	}
	
	if (is.null(project)) { 
		projectDir = options("PROJECT.DIR")
	} else {
		codepath = Sys.getenv("CODEBASE")
		projectDir = if(is.null(codepath) | identical("", codepath)) project else file.path(codepath, project)
	}
	
	# If no file is specified, try these default locations
	yamls = c("metadata/config.yaml", 
		"metadata/project_config.yaml", 
		file.path("metadata", sprintf("%s.yaml", project)))
	
	# DEBUG
	sprintf(paste0(yamls, collapse=" "), file=stdout())

	# Prioritize given filename over defaults.
	if (!is.null(filename)) {
		yamls = c(filename, yamls)
	}

	cfgFile = FirstExtantFile(files = yamls, parent = projectDir)
	if (is.null(cfgFile)) {
		message("No config file found.")
		return
	}
	
	cfg = yaml::yaml.load_file(cfgFile)
	message("Loaded config file: ", cfgFile)
	
	if (!is.null(sp)) {
		# Update with subproject variables.
		spc = cfg$subprojects[[sp]]
		if (is.null(spc)) {
			message("Subproject not found: ", sp)
			return
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
	mdn = names(cfg$metadata)
	for (n in mdn) {
		if ( ! IsAbsolute(cfg$metadata[n]) ) { 
			cfg$metadata[n] = file.path(dirname(cfgFile), cfg$metadata[n])
		}
	}

	return(cfg)
}


FirstExtantFile = function(files, parent) {
	# Find the first extant file from a sequence of candidates.
	#
	# Args:
	#   files: The sequence file names or paths to consider.
	#   parent: Path to the folder to which each element considered 
	#           should be joined if the element isn't absolute path.
	#
	# Returns:
	#   (Absolute) path to the first element that exists. Null if 
	#   no element considered resolves to valid filesystem location.
	for (f in files) {
		path = if(IsAbsolute(f)) f else file.path(parent, f)
		if (file_test("-f", path)) return(path)
	}
}


IsAbsolute = function(path) {
	return(identical(path, normalizePath(path)))
}
