#!/usr/bin/env hy
;; -*- coding: utf-8 -*-

(import argparse)
(import logging)
(import os)
(import sys)

(try (import [simplejson :as json])
     (except [ImportError]
             (import json)))

(import [filepathutils [get-node-dict is-valid-extension]])


(setv *logger* ((. logging getLogger) "my-logger"))


(defn get-dir-search-result [path keywords valid-extensions]
  "
  :type path: str
  :type keywords: list[str]
  :type valid-extensions: list[str]
  :rtype: dict
  "
  (setv node (get-node-dict path))
  (setv result-dict-list [])
  (for [file (. node ["file"])]
       (if-not (is-valid-extension file valid-extensions)
               (continue))
       (setv result-dict
            ((. get-file-search-result) ((. os path join) path file)
                                        keywords))
       (when result-dict
             ((. result-dict-list append) result-dict)))
  (for [dir- (. node ["directory"])]
       (setv result-dict
             ((. get-dir-search-result) ((. os path join) path dir-)
                                        keywords
                                        valid-extensions))
       (when result-dict
             ((. result-dict-list append) result-dict)))
  (get-merge-dict result-dict-list))


(defn get-file-search-result [file-path keywords]
  "
  :type file-path: str
  :type keywords: list[str]
  :rtype: dict"
  (setv text
        (get-text-from-file file-path))
  (setv result-dict {})
  (for [keyword- keywords]
       (setv lines [])
       (for [line (range (len text))]
            (when (in keyword- (. text [line]))
                  ((. lines append) (str (+ line 1)))))
       (when lines
             (setv (. result-dict [keyword-])
                   [[file-path ((. ", " join) lines)]])))
  result-dict)


(defn get-data-from-file [file-path]
  "
  :type file-path: str
  :rtype: dict or list
  "
  (with [f (open file-path :mode "r" :encoding "utf-8")]
        ((. json load) f)))


(defn get-merge-dict [dicts-]
  "
  :type dicts-: list[dict]
  :rtype: dict
  "
  (setv merged-dict {})
  (for [dict- dicts-]
       (for [keyword- dict-]
            (if (in keyword- merged-dict)
                (for [result (. dict- [keyword-])]
                     ((. merged-dict [keyword-] append) result))
                (setv (. merged-dict [keyword-]) (. dict- [keyword-])))))
  merged-dict)


(defn get-search-result [path keywords valid-extensions]
  "
  :type path: str
  :rtype: dict
  "
  (setv norm-path ((. os path normpath) path))
  (setv current-dir ((. os getcwd)))
  (if ((. os path isabs) norm-path)
      ((. os chdir) norm-path)
      (do (setv norm-path ((. os path join) current-dir norm-path))
          (. os chdir) norm-path))
  (setv node (get-node-dict norm-path))
  (setv result-dict-list [])
  (for [file (. node ["file"])]
       (if-not (is-valid-extension file valid-extensions)
               (continue))
       (setv result-dict
            ((. get-file-search-result) ((. os path join) norm-path file)
                                        keywords))
       (when result-dict
             ((. result-dict-list append) result-dict)))
  (for [dir- (. node ["directory"])]
       (setv result-dict
            ((. get-dir-search-result) ((. os path join) norm-path dir-)
                                       keywords
                                       valid-extensions))
       (when result-dict
             ((. result-dict-list append) result-dict)))
  (setv merged-dict (get-merge-dict result-dict-list))
  ((. os chdir) current-dir)
  merged-dict)


(defn get-text-from-file [path]
  "
  :type path: str
  :rtype: list[str]
  "
  (with [f (open path :mode "r" :encoding "utf-8")]
        ((. f readlines))))


(defn show-result [result-dict]
  "
  :type result-dict: dict
  :rtype: None
  "
  (for [keyword- result-dict]
       (for [(, file-path lines) (. result-dict [keyword-])]
            (print ((. "[keyword] {0}: [file] {1}, [line] {2}" format)
                    keyword-
                    file-path
                    lines))))
  None)


(defn write-data-to-file [data file]
  "
  :type data: dict or list
  :type file: str
  :rtype: None
  "
  (with [f (open file :mode "w" :encoding "utf-8")]
    ((. json dump) data f :ensure-ascii False :indent "  "))
  None)


(defn main []
  "main

  :rtype: int
  "
  (setv parser ((. argparse ArgumentParser) :description "search keywords"))
  ((. parser add-argument) "-k" "--keywords"
                           :dest "keywords_file"
                           :help "keywords file path"
                           :required True
                           :type str)
  ((. parser add-argument) "-d" "--directories"
                           :dest "directories"
                           :help "search directories"
                           :nargs "+"
                           :required True
                           :type str)
  ((. parser add-argument) "-e" "--extensions"
                           :dest "extensions_file"
                           :help "extensions file"
                           :required True
                           :type str)
  ((. parser add-argument) "-o" "--output"
                           :default ""
                           :dest "output_file"
                           :help "output file"
                           :type str)
  ((. parser add-argument) "--debug"
                           :action "store_true"
                           :help "debug mode")
  (setv args ((. parser parse-args)))

  (if (. args debug)
      (do ((. *logger* setLevel) (. logging DEBUG))
          (setv -formatter
                ((. logging Formatter)
                 "%(asctime)s: line %(lineno)d: [%(levelname)s] %(message)s")))
      (do ((. *logger* setLevel) (. logging INFO))
          (setv -formatter
                ((. logging Formatter)
                 "[%(levelname)s] %(message)s"))))

  (setv -handler ((. logging StreamHandler)))

  ((. -handler setFormatter) -formatter)
  ((. *logger* addHandler) -handler)

  (setv valid-extensions (get-data-from-file (. args extensions-file)))
  (setv keywords (get-data-from-file (. args keywords-file)))
  (setv result-dict-list [])
  (for [dir- (. args directories)]
       (setv result-dict
             (get-search-result dir- keywords valid-extensions))
       (when result-dict
             ((. result-dict-list append) result-dict)))
  (if result-dict-list
      (do (setv result-dict (get-merge-dict result-dict-list))
          (if (= (. args output-file) "")
              (show-result result-dict)
              (write-data-to-file result-dict (. args output-file)))
          0)
      1))


(when (= --name-- "__main__")
      ((. sys exit) (main)))
