#include "MathFunctions.h"

#include <cmath>

#ifdef USE_MYMATH
#include "mysqrt.h"
#endif

namespace mathfunctions {
double sqrt(double x) {
  // Otherwise, use std::sqrt.
#ifdef USE_MYMATH
  return detail::mysqrt(x);
#else
  return std::sqrt(x);
#endif // USE_MYMATH
}
} // namespace mathfunctions
