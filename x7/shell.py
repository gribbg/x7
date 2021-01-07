"""
    Tools for python interactive shell.

    Usage: from x7.shell import *
"""


try:
    import x7.devtools.shell_tools
    x7.devtools.shell_tools.do_import(globals())
except ModuleNotFoundError as err:
    print('shell_tools not loaded: %s' % err)
