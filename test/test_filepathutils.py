#!/usr/bin/env python
# -*- coding: utf-8 -*-

from unittest import TestCase

import hy
from nose.tools import eq_

from filepathutils import (
    get_child_dirs_list,
    get_files_list,
    get_node_dict
)


class TestFilePathUtils(TestCase):
    def test_get_child_dirs_list(self):
        actual = get_child_dirs_list("test_dir")
        eq_(actual, ["child_dir"])

    def test_get_files_list(self):
        actual = get_files_list("test_dir")
        eq_(actual, ["test_file_1.txt", "test_file_2.md", "test_file_3.ini"])

    def test_get_node_dict(self):
        actual = get_node_dict("test_dir")
        eq_(actual, {
            "directory": ["child_dir"],
            "file": ["test_file_1.txt", "test_file_2.md", "test_file_3.ini"],
            "path": "test_dir"
        })
