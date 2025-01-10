# Configuration file for the Sphinx documentation builder.
import os
# -- Project information

project = 'AMP Toolbox'
copyright = '2025, Università di Bologna'
author = 'Andrea Frasson'

release = '1.0'
version = '1.0.1'

# -- General configuration

extensions = [
    'sphinx.ext.duration',
    'sphinx.ext.doctest',
    'sphinx.ext.autodoc',
    'sphinx.ext.autosummary',
    'sphinxcontrib.matlab',
    "sphinx.ext.napoleon"
]

primary_domain = 'mat'


templates_path = ['_templates']

# -- Options for HTML output

html_theme = 'sphinx_rtd_theme'

# -- Options for EPUB output
epub_show_urls = 'footnote'

this_dir = os.path.dirname(os.path.abspath(__file__))
matlab_src_dir = os.path.abspath(os.path.join(this_dir, '..'))


