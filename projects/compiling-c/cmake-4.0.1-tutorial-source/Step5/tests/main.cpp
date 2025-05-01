#include "gtest/gtest.h"

// #include <sdtio.h>
TEST(SimpleTest, BasicAssertion) {
  EXPECT_EQ(1 + 1, 2);
  EXPECT_EQ(1 + 2, 3);
}
