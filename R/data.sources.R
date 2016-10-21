# parse data sources like python can do with format()
# Currently non-functional; just some notes.


# library(stringr)

# str_locate_all(cfg$ewing$data_sources$bsf_samples, "\\{.*?\\}")
# res = str_extract_all(cfg$ewing$data_sources$bsf_samples, "\\{.*?\\}")
# result = cfg$ewing$data_sources$bsf_samples
# for (r in res[[1]]) { 
# 	res_stripped = str_replace_all(r, "[{}]", "")
# 	message(r, res_stripped)
# 	result = gsub(r, res_stripped, result)
# }
# result 
# str_match_all(result, "\\{.*?\\}")
# str_match_all(result, "\\{.*?\\}")[[1]]

# str_replace_all(cfg$ewing$data_sources$bsf_samples, "\\{.*?\\}", "blah")
# str_replace_all(cfg$ewing$data_sources$bsf_samples, "\\{.*?\\}", "\1")

# psaProj[1,]

# library(stringi)

# result = "{sample_name}/{age_class}"
# vars = stri_match_all(result, regex = "\\{.*?\\}", vectorize_all = FALSE)[[1]][,1]
# strip = stri_sub(vars, 2, -2)




# myreplacer = function(x, y, z) {
# 	for (i in seq_len(y)) {
# 		a = y[i]
# 		b = z[i]
# 		x = stringi::stri_replace_all_fixed(x, a, get(b), vectorize_all = TRUE)
# 	}
# }

# psaProj[, myreplacer(result, vars, get(strip))]

# apply(psaProj, 1, stringi::stri_replace_all_fixed(result, vars, get(strip), vectorize_all = FALSE))

# lapply(strip, function(x) { psaProj[[x]]})
# psaProj[["flowcell"]]
# psaProj

