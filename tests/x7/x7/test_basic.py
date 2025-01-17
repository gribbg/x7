# -*- coding: utf-8 -*-

import sys
import unittest
from x7 import x7


class BasicTestSuite(unittest.TestCase):
    """Basic test cases."""

    def test_succeeds(self):
        print('__version__ is', x7.__version__)
        print('    '+'\n    '.join(sys.path))
        self.assertTrue(True)

    def test_fails(self):
        self.assertTrue(not False)


if __name__ == '__main__':
    unittest.main()
