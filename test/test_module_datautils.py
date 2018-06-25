#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os
from unittest import TestCase

import hy
from nose.tools import eq_, ok_

from module.datautils import (
    bin_to_str,
    get_merged_dict,
    split_lines
)


class TestModuleDatautils(TestCase):
    def test_bin_to_str(self):
        binary = bytes.fromhex("81600D0A8160")
        actual = bin_to_str(binary, "cp932")
        eq_(actual, "～\r\n～")

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

    def test_split_lines(self):
        actual = split_lines("～\r\n～")
        eq_(actual, ["～", "～"])
