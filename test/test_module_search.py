#!/usr/bin/env python
# -*- coding: utf-8 -*-

import json
import os
from unittest import TestCase

import hy
from nose.tools import eq_, ok_

from module.search import (
    find_from_dir,
    find_from_file,
    find_from_text,
    find_from_texts
)


class TestModuleSearch(TestCase):
    def test_find_from_text(self):
        text = "hogefugapiyohogefugapiyohoge"
        keyword = "hoge"
        actual = find_from_text(text, keyword)
        eq_(actual, [0, 12, 24])
        ok_(isinstance(actual, list))

    def test_find_from_texts(self):
        texts = [
            "hogefugapiyohogefugapiyohoge",
            "fugahogefugapiyohogefugapiyo",
            "",
            "fugapiyo",
            "piyohogefuga"
        ]
        keyword = "hoge"
        actual = find_from_texts(texts, keyword)
        eq_(actual,
            [[0, [0, 12, 24]],
             [1, [4, 16]],
             [4, [4]]])

    def test_find_from_file(self):
        _dir = "test_dir"
        file_name = "test_file_1.txt"
        file_path = os.path.join(_dir, file_name)
        keywords_path = os.path.join("src", "keywords.json")
        with open(keywords_path, "r", encoding="utf-8") as fp:
            keywords = json.load(fp)
        actual = find_from_file(_dir, file_name, keywords)
        eq_(actual,
            {
                "hoge": [[file_path, [[0, [0]]]]],
                "fuga": [[file_path, [[1, [0]]]]],
                "piyo": [[file_path, [[2, [0]]]]]
            })
