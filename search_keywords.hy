#!/usr/bin/env hy
;; -*- coding: utf-8 -*-

(import argparse)
(import json)
(import logging)
(import os)
(import re)
(import sys)
(import traceback)


(setv *logger* ((. logging getLogger) "my-logger"))


(defclass DirectoryNotFound [Exception]
  (pass))


(defn callback-onerror [exception]
  "
  :type exception: Exception
  :rtype: None
  "
  ((. traceback print-exc))
  None)


(defn find-keywords-from-dir [path file-names keywords valid-extensions]
  "
  :type path: str
  :type filenames: list[str]
  :type keywords: list[str]
  :type valid-extensions: list[str]
  :rtype: dict[str, list[list[str, list[list[int, list[int]]]]]]
  "
  (setv result-dict-list [])
  (for [file-name file-names]
       (when (is-invalid-extension file-name valid-extensions)
             (continue))
       (setv result-dict
             ((. find-keywords-from-file) ((. os path join) path file-name)
                                         keywords))
       (when result-dict
             ((. result-dict-list append) result-dict)))
  (get-merge-dict result-dict-list))


(defn find-keywords-from-file [file-path keywords]
  "
  :type file-path: str
  :type keywords: list[str]
  :rtype: dict[str, list[list[str, list[HyList[HyInteger, HyList[HyInteger]]]]]]
  "
  (setv result-dict {})
  (try (setv texts (read-texts file-path))
       (for [keyword- keywords]
            (setv lines (find-keyword-from-texts texts keyword-))
            (when lines
                  (setv (. result-dict [keyword-])
                        [[file-path lines]])))
       (except [UnboundLocalError]
               ((. *logger* error)
                ((. "Cannot decode this file: {0}" format) file-path)))
       (except [PermissionError]
               ((. *logger* error)
                ((. "Cannot open this file (permission denied): {0}" format)
                 file-path))))
  result-dict)


(defn find-keyword-from-text [text keyword-]
  "
  :type text: str
  :type keyword-: str
  :rtype: list[int]
  "
  (setv found ((. re finditer) keyword-
                               text
                               (| (. re UNICODE)
                                  (. re IGNORECASE))))
  (list (map (fn [f] ((. f start))) found)))


(defn find-keyword-from-texts [texts keyword-]
  "
  :type texts: list[str]
  :type keyword-: str
  :type row: int
  :rtype: list[list[int, list[int]]]
  "
  (setv found [])
  (for [(, index text) (enumerate texts)]
       (setv columns (find-keyword-from-text text keyword-))
       (if columns
           ((. found append) [index columns])))
  found)


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


(defn is-invalid-extension [file-name valid-extensions]
  (if (in True (list (map (. file-name endswith) valid-extensions)))
      False
      True))


(defn read-config [file-path]
  "
  :type file-path: str
  :rtype: dict or list
  "
  (with [f (open file-path :mode "r" :encoding "utf-8-sig")]

        ((. json load) f)))


(defn read-texts [path]
  "
  :type path: str
  :rtype: list[str]
  "
  (setv encords
        ["utf-8-sig"
         "utf-16-be"
         "utf-16-le"
         "cp932"
         "shift-jis"
         "euc-jp"
         "euc-jis-2004"
         "euc-jisx0213"
         "iso2022-jp"
         "ascii"])
  (for [enc encords]
       (try (with [f (open path :mode "r" :encoding enc)]
                  (setv data ((. f readlines)))
                  ((. *logger* info)
                   ((. "[Encoding] {0} [File] {1}" format) enc path)))
            (break)
            (except [UnicodeError]
                    (continue))
            (except [PermissionError]
                    (raise))))
  data)


(defn show-result [result-dict]
  "
  :type result-dict: dict[str, list[list[str, list[list[int, list[int]]]]]]

  :rtype: None
  "
  (for [keyword- result-dict]
       (for [(, file-path positions) (. result-dict [keyword-])]
            (for [(, row columns) positions]
                 (print ((. "[keyword] {0}: [file] {1}, [line] {2}: {3}" format)
                    keyword-
                    file-path
                    (inc row)
                    ((. ", " join) (map (fn [column] (str (inc column)))
                                        columns)))))))
  None)


(defn write-data-to-file [data file]
  "
  :type data: dict or list
  :type file: str
  :rtype: None
  "
  (with [f (open file :mode "w" :encoding "utf-8")]
        ((. json dump) data f :ensure-ascii False :indent 2))
  None)


(defn main []
  "main

  :rtype: int
  "
  (setv parser ((. argparse ArgumentParser) :description "search keywords"))
  ((. parser add-argument) "-k" "--keywords"
                           :default "keywords.json"
                           :dest "keywords_file"
                           :help "keywords file path"
                           :type str)
  ((. parser add-argument) "-d" "--directories"
                           :default "."
                           :dest "directories"
                           :help "search directories"
                           :nargs "+"
                           :type str)
  ((. parser add-argument) "-e" "--extensions"
                           :default "extensions.json"
                           :dest "extensions_file"
                           :help "extensions file"
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

  ;; Validate arguments.
  ((. *logger* debug) "Start arguments validation.")
  (if-not ((. args keywords-file endswith) ".json")
          (do ((. *logger* critical)
               ((. "JSON file is required: {0}" format)
                (. args keywords-file)))
              (raise ValueError)))

  (if-not ((. args extensions-file endswith) ".json")
          (do ((. *logger* critical)
               ((. "JSON file is required: {0}" format)
                (. args extension-file)))
              (raise ValueError)))

  (setv invalid-directories
        (list-comp dir-
                   [dir- (. args directories)]
                   (not ((. os path isdir) dir-))))

  (when invalid-directories
        (for [dir- invalid-directories]
             ((. *logger* critical)
              ((. "Directory not found: {0}" format)
               dir-)))
        (raise DirectoryNotFound))

  (try (setv keywords (read-config (. args keywords-file)))
       (except [IOError]
               ((. *logger* critical)
                ((. "Cannot open a keywords file: {0}" format)
                 (. args keywords-file)))
               (raise)))

  (try (setv valid-extensions (read-config (. args extensions-file)))
       (except [IOError]
               ((. *logger* critical)
                ((. "Cannot open a valid extensions file: {0}" format)
                 (. args extensions-file)))
               (raise)))
  ((. *logger* debug) "Done.")

  ;; Search keywords from files at each directories.
  ((. *logger* debug) "Start search keywords from files at each directories.")
  (setv result-dict-list [])
  (for [dir- (. args directories)]
       (for [(, path dirs filenames)
             ((. os walk) dir- :onerror callback-onerror)]
            (setv result-dict (find-keywords-from-dir path
                                                     filenames
                                                     keywords
                                                     valid-extensions))
            (when result-dict
                  ((. result-dict-list append) result-dict))))
  ((. *logger* debug) "Done.")

  ;; Output result data.
  ((. *logger* debug) "Start output result data.")
  (if result-dict-list
      (do (setv result-dict (get-merge-dict result-dict-list))
          (if (= (. args output-file) "")
              (show-result result-dict)
              (write-data-to-file result-dict (. args output-file)))
          0)
      1))


(when (= --name-- "__main__")
      ((. sys exit) (main)))
