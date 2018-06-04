#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os
from unittest import TestCase

import hy
from nose.tools import eq_, ok_

from search_keywords import (
    find_from_dir,
    find_from_file,
    find_from_text,
    find_from_texts,
    get_merged_dict,
    read_config,
    read_texts
)


class TestSearchKeywords(TestCase):
    def test_get_merged_dict(self):
        actual = get_merged_dict([
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
        file_path = os.path.join("test_dir", "test_file_1.txt")
        keywords_path = os.path.join("src", "keywords.json")
        keywords = read_config(keywords_path)
        actual = find_from_file(file_path, keywords)
        eq_(actual,
            {
                "hoge": [[file_path, [[0, [0]]]]],
                "fuga": [[file_path, [[1, [0]]]]],
                "piyo": [[file_path, [[2, [0]]]]]
            })

    def test_read_texts(self):
        actual = read_texts(os.path.join("test_dir", "test_file_1.txt"))
        eq_(actual, ["hoge", "fuga", "piyo", ""])
