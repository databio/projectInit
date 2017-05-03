# Helper functions 


Hint = function(varname) {
  # Make suggestion about configuring an environment variable.
  # 
  # Args:
  #   varname: Name of environment variable to suggest setting.
  # 
  # Returns:
  #   Message about benefit of setting the given environment variable.
  return(sprintf("You should set environment variable %s to use the 
    shared R utils most effectively. Then you can refer to R projects 
    with relative paths, making the code portable and sharable.", varname))
}


IsAbsolute = function(path) {
  # Determine whether a path is absolute.
  #
  # Args:
  #   path: File or folder path to check for absolute-ness.
  #
  # Returns:
  #   Whether the given path indeed appears to be absolute.
  return(identical(path, normalizePath(path)))
}


MakePath = function(target, env_var, when_null) {
  # Make an absolute path based on one of interest and some alternatives.
  #
  # Args:
  #   target: The primary path for which an absolute version is desired.
  #   env_var: Environment variable for which value is parent path candidate.
  #   when_null: How to make the path when the target is null.
  #
  # Returns:
  #   (Absolute) path derived from inputs. If the first argument was 
  #   already absolute, then this is returned. If it was null, then 
  #   the path to the working directory is used. If the first argument 
  #   is neither null nor absolute, it's joined with the parent candidate.
  
  if (is.null(target)) { # null working dir.
		fullpath = when_null()
		warning ("Using alternative for null target: ", fullpath);
	} else {
		parent = Sys.getenv(env_var)
		
		if (identical("", parent)) {
			stop(Hint(env_var))
		}
		
		normalized = normalizePath(target)
		if (identical(target, normalized)) {
			fullpath = normalized
		} else {
			fullpath = file.path(parent, target)
		}
		
		if (!IsAbsolute(fullpath)) { 
      stop(sprintf("Could not make absolute path from primary 
        target %s and parent candidate %s (from %s)", target, parent, env_var)) 
		}
	}
	
	return(fullpath)
}
