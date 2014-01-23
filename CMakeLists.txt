project ( lub )

cmake_minimum_required ( VERSION 2.8 )

include ( cmake/lubyk.cmake )

#include ( cmake/dist.cmake )
#include ( lua )


set(MODULE_NAME lub)
# --------------------------------------------------------------

include_directories(include)

# --------------------------------------------------------------
#  module
# --------------------------------------------------------------
add_custom_target(${MODULE_NAME} true)

# --------------------------------------------------------------
#  src module/core.so
# --------------------------------------------------------------
add_subdirectory(src)

# --------------------------------------------------------------
#  module_bind                                   
# --------------------------------------------------------------
file(GLOB MODULE_HEADERS include/${MODULE_NAME}/*.h)
add_custom_target("${MODULE_NAME}_bind"
  COMMAND lua bind.lua
  WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
  DEPENDS ${MODULE_HEADERS} bind.lua)

# --------------------------------------------------------------
#  install                                     
# --------------------------------------------------------------
install (
  DIRECTORY ${MODULE_NAME}/
  DESTINATION ${INSTALL_LMOD}/${MODULE_NAME}
  COMPONENT Runtime
)

# install_data ( README.md LICENSE )

# install_example ( examples/ )

