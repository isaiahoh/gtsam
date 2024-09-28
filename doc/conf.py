import os

extensions = [
    "breathe",
    "sphinx_rtd_theme",
]

html_theme = "sphinx_rtd_theme"

# Get the directory where conf.py is located
docs_dir = os.path.abspath(os.path.dirname(__file__))
xml_dir = os.path.abspath(
    os.path.join(docs_dir, "..", "build", "doc", "doxygen", "xml")
)

breathe_projects = {"GTSAM": xml_dir}
breathe_default_project = "GTSAM"
