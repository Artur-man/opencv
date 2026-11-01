
// ropencv.h: lets packages with 'LinkingTo: opencv' compile against the same
// OpenCV as the opencv R package.
//
// In the DESCRIPTION of the package that uses it:
//   LinkingTo: opencv
// and in its src/Makevars:
//   PKG_CPPFLAGS = `"$(R_HOME)/bin$(R_ARCH_BIN)/Rscript" -e "opencv::ocv_config('cflags')"`
//   PKG_LIBS = `"$(R_HOME)/bin$(R_ARCH_BIN)/Rscript" -e "opencv::ocv_config('libs')"`
//
// opencv2/opencv.hpp includes every main module present in this OpenCV build.
// Contrib modules (xfeatures2d, ximgproc, ...) are not included by it: include
// them yourself, guarded by the HAVE_OPENCV_<MODULE> macros from
// opencv2/opencv_modules.hpp, e.g.
//   #ifdef HAVE_OPENCV_XIMGPROC
//   #include <opencv2/ximgproc.hpp>
//   #endif

#ifndef ROPENCV_H
#define ROPENCV_H

#include <opencv2/opencv_modules.hpp>
#include <opencv2/opencv.hpp>

#endif
