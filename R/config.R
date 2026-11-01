#' Build flags for packages that link to OpenCV through opencv
#'
#' Other packages can compile C++ code against the same OpenCV as this package
#' by adding \code{Imports: opencv} and \code{LinkingTo: Rcpp, opencv} to their
#' DESCRIPTION (which also gives them the \code{ropencv.h} header) and putting
#' this in their \code{src/Makevars}:
#'
#' \preformatted{
#' PKG_CPPFLAGS = `"$(R_HOME)/bin$(R_ARCH_BIN)/Rscript" -e "opencv::ocv_config('cflags')"`
#' PKG_LIBS = `"$(R_HOME)/bin$(R_ARCH_BIN)/Rscript" -e "opencv::ocv_config('libs')"`
#' }
#'
#' The flags that \code{configure} found when opencv was installed are used as
#' long as they still point to an existing OpenCV. Otherwise, and always on
#' Windows where OpenCV comes from Rtools, they are looked up with
#' \code{pkg-config} at the time the other package is built.
#'
#' @export
#' @param what either \code{"cflags"} or \code{"libs"}
#' @return the flags as a single string, printed with \code{cat()} and returned
#' invisibly
ocv_config <- function(what = c("cflags", "libs")){
  what <- match.arg(what)
  flags <- recorded_flags()
  if(is.null(flags))
    flags <- pkgconfig_flags()
  if(is.null(flags)){
    stop("Could not find OpenCV to link against. Install libopencv-dev (Debian/Ubuntu), ",
         "opencv-devel (Fedora) or opencv and pkg-config (Homebrew), ",
         "or use a recent Rtools on Windows.", call. = FALSE)
  }
  cat(flags[[what]])
  invisible(flags[[what]])
}

# Written to inst/opencv-flags.txt by configure, only when pkg-config found OpenCV
recorded_flags <- function(){
  path <- system.file("opencv-flags.txt", package = "opencv")
  if(!nzchar(path))
    return(NULL)
  lines <- readLines(path, warn = FALSE)
  cflags <- sub("^cflags=", "", grep("^cflags=", lines, value = TRUE))
  libs <- sub("^libs=", "", grep("^libs=", lines, value = TRUE))
  if(length(cflags) != 1 || length(libs) != 1)
    return(NULL)
  # Ignore the recorded flags if that OpenCV has been removed or moved since
  args <- strsplit(trimws(cflags), "[[:space:]]+")[[1]]
  incdirs <- substring(grep("^-I", args, value = TRUE), 3)
  if(length(incdirs) && !all(dir.exists(incdirs)))
    return(NULL)
  list(cflags = trimws(cflags), libs = trimws(libs))
}

pkgconfig_flags <- function(){
  for(name in c("opencv4", "opencv5")){
    libs <- pkgconfig("--libs", name)
    if(length(libs))
      return(list(cflags = pkgconfig("--cflags", name), libs = libs))
  }
  NULL
}

pkgconfig <- function(arg, name){
  out <- tryCatch(suppressWarnings(
    system2("pkg-config", c(arg, name), stdout = TRUE, stderr = FALSE)
  ), error = function(e) NULL)
  if(is.null(out) || !is.null(attr(out, "status")))
    return(NULL)
  trimws(paste(out, collapse = " "))
}
