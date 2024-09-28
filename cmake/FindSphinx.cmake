# Look for an executable called sphinx-build
find_program(
  SPHINX_EXECUTABLE
  NAMES sphinx-build
  # set location of where you installed requirements.txt
  PATHS ${CMAKE_SOURCE_DIR}/doc-venv/bin
  NO_DEFAULT_PATH
  DOC "Path to sphinx-build executable")

include(FindPackageHandleStandardArgs)
# Handle standard arguments to find_package like REQUIRED
find_package_handle_standard_args(
  Sphinx "Failed to find sphinx-build executable" SPHINX_EXECUTABLE)
