#!/usr/bin/env hy
;; -*- coding: utf-8 -*-

(import logging)


(setv *logger* ((. logging getLogger) "search-keywords.module.datautils"))


(defn bin-to-str [binary enc]
  "
  :type binary: bin
  :type enc: str
  :rtype: list[str] or None
  "
  (try (setv texts ((. binary decode) enc))
       ((. *logger* info) ((. "Encoding {0}" format) enc))
       texts
       (except [UnicodeError]
               None)
       (except [PermissionError]
               (raise))))


(defn get-merged-dict [dicts-]
  "
  :type dicts-: list[dict]
  :rtype: dict
  "
  (cond [(= dicts- []) {}]
        [(= (len dicts-) 1) (. dicts- [0])]
        [True (merge-with (fn [x y] (+ x y)) #* dicts-)]))


(defn split-lines [text]
  "
  :type text: str
  :rtype: list[str]
  "
  (-> text (.replace "\r" "") (.split "\n")))
