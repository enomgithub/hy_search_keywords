#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os
from unittest import TestCase

import hy
from nose.tools import eq_

from search_keywords import (
    find_keywords_from_dir,
    find_keywords_from_file,
    get_merge_dict,
    read_config,
    read_texts
)


class TestSearchKeywords(TestCase):
    def test_find_keywords_from_file(self):
        file_path = os.path.join("test_dir", "test_file_1.txt")
        keywords_path = os.path.join("src", "keywords.json")
        keywords = read_config(keywords_path)
        actual = find_keywords_from_file(file_path, keywords)
        eq_(actual,
            {
                "hoge": [[file_path, [1]]],
                "fuga": [[file_path, [2]]],
                "piyo": [[file_path, [3]]]
            })

    def test_get_merge_dict(self):
        actual = get_merge_dict([
            {
                "hoge": [
                    [os.path.join("hogehoge", "test1.txt"), [1, 3, 5]],
                    [os.path.join("hogehoge", "test2.txt"), [6, 7]]
                ],
                "fuga": [
                    [os.path.join("hogehoge", "test1.txt"), [2, 3, 4]]
                ]
            },
            {
                "hoge": [
                    [os.path.join("fugapiyo", "test3.txt"), [4, 6, 9, 11]],
                    [os.path.join("fugapiyo", "test4.txt"), [1]]
                ],
                "fuga": [
                    [os.path.join("fugapiyo", "test3.txt"), [3, 20, 34, 45, 67]],
                    [os.path.join("fugapiyo", "test5.txt"), [26, 49]]
                ],
                "piyo": [
                    [os.path.join("fugapiyo", "test3.txt"), [4]]
                ]
            }
        ])
        eq_(actual,
            {
                "hoge": [
                    [os.path.join("hogehoge", "test1.txt"), [1, 3, 5]],
                    [os.path.join("hogehoge", "test2.txt"), [6, 7]],
                    [os.path.join("fugapiyo", "test3.txt"), [4, 6, 9, 11]],
                    [os.path.join("fugapiyo", "test4.txt"), [1]]
                ],
                "fuga": [
                    [os.path.join("hogehoge", "test1.txt"), [2, 3, 4]],
                    [os.path.join("fugapiyo", "test3.txt"), [3, 20, 34, 45, 67]],
                    [os.path.join("fugapiyo", "test5.txt"), [26, 49]]
                ],
                "piyo": [
                    [os.path.join("fugapiyo", "test3.txt"), [4]]
                ]
            }
        )

    def test_read_texts(self):
        actual = read_texts(os.path.join("test_dir", "test_file_1.txt"))
        eq_(actual, ["hoge\n", "fuga\n", "piyo\n"])
