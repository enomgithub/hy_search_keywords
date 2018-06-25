#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os
from unittest import TestCase

import hy
from nose.tools import eq_, ok_

from module.io import read_texts


class TestModuleIo(TestCase):
    def test_read_texts(self):
        actual = read_texts(os.path.join("test_dir", "test_file_1.txt"))
        eq_(actual, ["hoge", "fuga", "piyo", ""])
