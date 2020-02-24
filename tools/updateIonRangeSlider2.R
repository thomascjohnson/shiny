tmpdir <- tempdir()

# https://github.com/IonDen/ion.rangeSlider
version <- "2.3.1"
zip_src <- sprintf("https://github.com/IonDen/ion.rangeSlider/archive/%s.zip", version)
zip_target <- file.path(tmpdir, "ion.zip")
download.file(zip_src, zip_target)
unzip(zip_target, exdir = dirname(zip_target))
src <- file.path(dirname(zip_target), paste0("ion.rangeSlider-", version))
target <- "inst/www/shared/ionrangeslider"
unlink(target, recursive = TRUE)
dir.create(target)
# Move over JS/CSS files
file.rename(
  file.path(src, "js"),
  file.path(target, "js")
)
# Move over JS files
file.rename(
  file.path(src, "css"),
  file.path(target, "css")
)

# Grab less src files and convert to sass
# npm install -g less2sass
less_files <- dir(file.path(src, "less"), full.names = TRUE, recursive = TRUE)
invisible(lapply(less_files, function(file) {
  system(paste("less2sass", file))
}))
sass_files <- dir(file.path(src, "less"), pattern = "scss$", full.names = TRUE, recursive = TRUE)

invisible(lapply(sass_files, function(file) {
  txt <- readLines(file)
  # Add !default flags to variable definitions
  txt <- sub("(\\$.*:.*);", "\\1 !default;", txt)
  # less2sass misses this bit
  txt <- sub("@import (reference)", "@import", txt, fixed = TRUE)
  writeLines(txt, file)
}))

# Move over less/sass
file.rename(
  file.path(src, "less"),
  file.path(target, "scss")
)
# Cleanup
file.remove(
  dir(target, pattern = "less$", full.names = TRUE, recursive = TRUE)
)
