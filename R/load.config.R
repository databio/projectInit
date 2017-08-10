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
		projectDir = paste0(Sys.getenv("CODEBASE"), project)
	}
	# If no file is specified, try these default locations
	yamls = list("metadata/config.yaml",
						"metadata/project_config.yaml",
						paste0("metadata/", project, ".yaml"))
	cfg = NULL
	if (! is.null(filename)) {
		yamls = c(filename, yamls)
	}

	for (yfile in yamls) {
		if ( ! pathIsAbs(yfile) ) {
			cfgFile = file.path(projectDir, yfile)
		} else {
			cfgFile = yfile
		}
		if (file.exists(cfgFile)) {
			break
		}
	}
	
	cfg = yaml::yaml.load_file(cfgFile)

	if (is.null(cfg)) {
		message("No config file found.")
		return
	}
	message("Loaded config file: ", cfgFile)
	
	if (! is.null(sp)) {
		# Update with subproject variables
		spc = cfg$subprojects[[sp]]
		if (is.null(spc)) {
			message("Subproject not found: ", sp)
			return
		}
		cfg = modifyList(cfg, cfg$subprojects[[sp]])
		message("Loading subproject: ", sp)
	}
	# Show available subprojects
	sps = names(cfg$subprojects)
	if (length(sps) > 1) { 
		message("Available subprojects: ", paste0(sps, collapse=","))
	}

	# Make metadata absolute
	# This used to be all metadata columns; now it's just: results_subdir
	mdn = names(cfg$metadata)
	for (n in mdn) {
		if ( !pathIsAbs(cfg$metadata[n]) ) { 
			cfg$metadata[n] = file.path(dirname(cfgFile), cfg$metadata[n])
		}
	}

	return(cfg)
}

pathIsAbs = function(path) {
	return(substr(path, 1, 1) == "/")
}

