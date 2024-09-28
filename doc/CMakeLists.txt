# Doxygen documentation configuration
option(GTSAM_BUILD_DOCS "Enable/Disable building of doxygen docs" ON)
# configure doxygen
option(GTSAM_BUILD_DOC_HTML "Enable/Disable doxygen HTML output" ON)
option(GTSAM_BUILD_DOC_LATEX "Enable/Disable doxygen LaTeX output" OFF)

# Find required packages
find_package(Doxygen REQUIRED)
find_package(Sphinx REQUIRED)

# add a target to generate API documentation with Doxygen
if(GTSAM_BUILD_DOCS)
  # Convert configuration to YES/NO variables
  if(GTSAM_BUILD_DOC_HTML)
    set(GTSAM_BUILD_DOC_HTML_YN "YES")
  else()
    set(GTSAM_BUILD_DOC_HTML_YN "NO")
  endif()
  if(GTSAM_BUILD_DOC_LATEX)
    set(GTSAM_BUILD_DOC_LATEX_YN "YES")
  else()
    set(GTSAM_BUILD_DOC_LATEX_YN "NO")
  endif()

  # GTSAM core subfolders
  set(gtsam_doc_subdirs
      gtsam/base
      gtsam/basis
      gtsam/discrete
      gtsam/geometry
      gtsam/hybrid
      gtsam/inference
      gtsam/linear
      gtsam/navigation
      gtsam/nonlinear
      gtsam/sam
      gtsam/sfm
      gtsam/slam
      gtsam/symbolic
      gtsam)

  # Optional GTSAM_UNSTABLE subfolders
  set(gtsam_unstable_doc_subdirs
      gtsam_unstable/base
      gtsam_unstable/discrete
      gtsam_unstable/dynamics
      gtsam_unstable/geometry
      gtsam_unstable/linear
      gtsam_unstable/nonlinear
      gtsam_unstable/partition
      gtsam_unstable/slam
      gtsam_unstable)

  # Build a list of folders to include depending on build options
  set(doc_subdirs ${gtsam_doc_subdirs})
  if(GTSAM_BUILD_UNSTABLE)
    list(APPEND doc_subdirs ${gtsam_unstable_doc_subdirs})
  endif()
  if(GTSAM_BUILD_EXAMPLES_ALWAYS)
    list(APPEND doc_subdirs examples)
  endif()

  # Find all header files in doc_subdirs
  set(GTSAM_HEADERS "")
  foreach(dir ${doc_subdirs})
    file(GLOB_RECURSE DIR_HEADERS "${PROJECT_SOURCE_DIR}/${dir}/*.h"
         "${PROJECT_SOURCE_DIR}/${dir}/*.hpp")
    list(APPEND GTSAM_HEADERS ${DIR_HEADERS})
  endforeach()

  # From subfolders, build a list with whitespace separation of paths
  set(GTSAM_DOXYGEN_INPUT_PATHS "")
  foreach(dir ${doc_subdirs})
    set(GTSAM_DOXYGEN_INPUT_PATHS
        "${GTSAM_DOXYGEN_INPUT_PATHS} ${PROJECT_SOURCE_DIR}/${dir}")
  endforeach()

  # Doxygen settings
  set(DOXYGEN_OUTPUT_DIR ${CMAKE_CURRENT_BINARY_DIR}/doxygen)
  set(DOXYGEN_HTML_DIR ${DOXYGEN_OUTPUT_DIR}/html)
  set(DOXYGEN_XML_DIR ${DOXYGEN_OUTPUT_DIR}/xml)
  set(DOXYGEN_INDEX_FILE ${DOXYGEN_OUTPUT_DIR}/html/index.html)
  set(DOXYFILE_IN ${CMAKE_CURRENT_SOURCE_DIR}/Doxyfile.in)
  set(DOXYFILE_OUT ${CMAKE_CURRENT_BINARY_DIR}/Doxyfile)

  # Configure Doxyfile
  configure_file(${DOXYFILE_IN} ${DOXYFILE_OUT} @ONLY)

  # Add custom command to generate Doxygen documentation
  add_custom_command(
    OUTPUT ${DOXYGEN_INDEX_FILE}
    DEPENDS ${GTSAM_HEADERS}
    COMMAND ${CMAKE_COMMAND} -E make_directory ${DOXYGEN_OUTPUT_DIR}
    COMMAND ${CMAKE_COMMAND} -E make_directory ${DOXYGEN_HTML_DIR}
    COMMAND ${CMAKE_COMMAND} -E make_directory ${DOXYGEN_XML_DIR}
    COMMAND ${DOXYGEN_EXECUTABLE} ${DOXYFILE_OUT}
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
    COMMENT "Generating API documentation with Doxygen"
    VERBATIM)

  # Add custom target for Doxygen
  add_custom_target(Doxygen ALL DEPENDS ${DOXYGEN_INDEX_FILE})

  # Sphinx settings
  set(SPHINX_SOURCE ${CMAKE_CURRENT_SOURCE_DIR})
  set(SPHINX_BUILD ${CMAKE_CURRENT_BINARY_DIR}/sphinx)
  set(SPHINX_INDEX_FILE ${SPHINX_BUILD}/index.html)

  # Add custom target for Sphinx
  add_custom_target(
    Sphinx ALL
    COMMAND
      ${SPHINX_EXECUTABLE} -b html
      -Dbreathe_projects.${PROJECT_NAME}=${DOXYGEN_OUTPUT_DIR}/xml
      ${SPHINX_SOURCE} ${SPHINX_BUILD}
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
    DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/index.rst ${DOXYGEN_INDEX_FILE}
            ${SPHINX_SOURCE}/conf.py
    COMMENT "Generating documentation with Sphinx")

  # Make sure Sphinx runs after Doxygen
  add_dependencies(Sphinx Doxygen)

  # Clean target
  add_custom_target(
    doc_clean
    COMMAND ${CMAKE_COMMAND} -E remove_directory ${DOXYGEN_OUTPUT_DIR}
    COMMAND ${CMAKE_COMMAND} -E remove_directory ${SPHINX_BUILD}
    COMMENT "Removing Doxygen and Sphinx documentation")

endif()
