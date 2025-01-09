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
    'sphinx.ext.intersphinx',
    'sphinxcontrib.matlab',
    'sphinx.ext.napoleon'
]

intersphinx_mapping = {
    'python': ('https://docs.python.org/3/', None),
    'sphinx': ('https://www.sphinx-doc.org/en/master/', None),
}

templates_path = ['_templates']

# -- Options for HTML output

html_theme = 'sphinx_rtd_theme'

# -- Options for EPUB output
epub_show_urls = 'footnote'

matlab_src_dir = os.path.join(os.path.dirname('.'), 'matlab')
primary_domain = 'mat'
