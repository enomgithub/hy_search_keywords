#!/usr/bin/env hy
;; -*- coding: utf-8 -*-

(import fnmatch)
(import logging)
(import os)
(import re)
(import traceback)
(import unicodedata)

(import [module.datautils [get-merged-dict]])
(import [module.io [read-texts]])


(setv *logger* ((. logging getLogger) "search-keywords.module.search"))


(defn find-from-dir [path file-names keywords
                     &optional [ignores []]
                               [insensitive False]]
  "
  :type path: str
  :type filenames: list[str]
  :type keywords: list[str]
  :type ignores: list[str]
  :type insensitive: bool
  :rtype: dict[str, list[list[str, list[list[int, list[int]]]]]]
  "
  (setv path-list ((. path split) (. os path sep)))
  (if (any (list (map (fn [dir-]
                        (any (list (map (fn [ignore]
                                          ((. fnmatch fnmatch) dir-
                                                               ignore))
                                        ignores))))
                        path-list)))
      (do ((. *logger* debug) ((. "Skip this directory: {0}" format) path))
          {})
      (get-merged-dict (list (remove empty?
                                     (map (fn [file-name]
                                            ((. find-from-file)
                                             path
                                             file-name
                                             keywords
                                             ignores
                                             insensitive))
                                          file-names))))))


(defn find-from-file [path file-name keywords
                      &optional [ignores []]
                                [insensitive False]]
  "
  :type path: str
  :type file-name: str
  :type keywords: list[str]
  :type ignores: list[str]
  :type insensitive: bool
  :rtype: dict[str, list[list[str, list[list[int, list[int]]]]]]
  "
  (if (any (list (map (fn [ignore]
                        ((. fnmatch fnmatch) file-name ignore))
                      ignores)))
      (do ((. *logger* debug)
           ((. "Skip this file: {0}" format) ((. os path join) path file-name)))
          {})
      (try (setv file-path ((. os path join) path file-name))
           (setv texts (read-texts file-path))
           (if (is texts None)
               (do ((. *logger* error)
                    ((. "Cannot decode this file: {0}" format) file-path))
                   {})
               (get-merged-dict
                 (list (remove empty?
                               (map (fn [keyword-]
                                      (do (setv lines
                                                (find-from-texts texts
                                                                 keyword-
                                                                 insensitive))
                                          (if lines
                                              {keyword- [[file-path lines]]}
                                              {})))
                                    keywords)))))
           (except [PermissionError]
                   ((. *logger* error)
                    ((. "Cannot open this file (permission denied): {0}" format)
                     file-path))
                   (return {}))
           (except [OSError]
                   ((. *logger* error) ((. "Invalid file: {0}" format)
                    file-path))
                   (return {})))))


(defn find-from-text [text keyword- &optional [insensitive False]]
  "
  :type text: str
  :type keyword-: str
  :type insensitive: bool
  :rtype: list[int]
  "
  (list (map (fn [found] ((. found start)))
             (if insensitive
                 ((. re finditer) ((. unicodedata normalize)
                                   "NFKC"
                                   ((. keyword- replace) "～" "〜"))
                                  ((. unicodedata normalize)
                                   "NFKC"
                                   ((.  text replace) "～" "〜"))
                                  (| (. re UNICODE)
                                     (. re IGNORECASE)))
                 ((. re finditer) keyword-
                                  text
                                  (. re UNICODE))))))


(defn find-from-texts [texts keyword- &optional [insensitive False]]
  "
  :type texts: list[str]
  :type keyword-: str
  :type insensitive: bool
  :rtype: list[list[int, list[int]]]
  "
  (list (remove empty?
                (map (fn [args]
                       (do (setv index (. args [0]))
                           (setv text (. args [1]))
                           (setv columns
                                 (find-from-text text
                                                 keyword-
                                                 insensitive))
                           (if columns
                               [index columns]
                               [])))
                     (enumerate texts)))))
