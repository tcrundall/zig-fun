add_library(MathFunctions MathFunctions.cxx)

option(USE_MYMATH "use my sqrt impl" ON)

if(USE_MYMATH)
    target_compile_definitions(MathFunctions PUBLIC USE_MYMATH) 
    add_library(SqrtLibrary mysqrt.cxx)
    target_link_libraries(MathFunctions SqrtLibrary)
endif()

