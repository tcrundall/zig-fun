#include <cmath>
#include <gtest/gtest.h>

#include "MathFunctions.h"

TEST(TestSqrt, WholeNumbers) {
  EXPECT_EQ(mathfunctions::sqrt(9), 3);
  EXPECT_EQ(mathfunctions::sqrt(25), 5);
  EXPECT_EQ(mathfunctions::sqrt(100), 10);
  EXPECT_EQ(mathfunctions::sqrt(1), 1);
  EXPECT_EQ(mathfunctions::sqrt(0), 0);
}

TEST(TestSqrt, FloatResults) {
  EXPECT_FLOAT_EQ(mathfunctions::sqrt(90), 9.48683);
}

TEST(TestSqrt, InvalidInputs) {
#ifdef USE_MYMATH
  EXPECT_EQ(mathfunctions::sqrt(-25), 0);
  EXPECT_EQ(mathfunctions::sqrt(-25.5), 0);
#else
  EXPECT_TRUE(std::isnan(mathfunctions::sqrt(-25)));
#endif
}
