#!/usr/bin/env hy
;; -*- coding: utf-8 -*-

(import argparse)
(import logging)
(import os)
(import sys)
(import traceback)

(try (import [simplejson :as json])
     (except [ImportError]
             (import json)))

(import [filepathutils [get-node-dict is-valid-extension]])


(setv *logger* ((. logging getLogger) "my-logger"))


(defn callback-walk-handler [exception]
  "
  :type exception: BaseException
  :rtype: None
  "
  ((. traceback print-exc))
  None)


(defn get-dir-search-result [path file-names keywords valid-extensions]
  "
  :type path: str
  :type filenames: list[str]
  :type keywords: list[str]
  :type valid-extensions: list[str]
  :rtype: dict
  "
  (setv result-dict-list [])
  (for [file-name file-names]
       (if-not (is-valid-extension file-name valid-extensions)
               (continue))
       (setv result-dict
             ((. get-file-search-result) ((. os path join) path file-name)
                                         keywords))
       (when result-dict
             ((. result-dict-list append) result-dict)))
  (get-merge-dict result-dict-list))


(defn get-file-search-result [file-path keywords]
  "
  :type file-path: str
  :type keywords: list[str]
  :rtype: dict[list[list[str, list[int]]]]
  "
  (setv result-dict {})
  (try (setv text (get-text-from-file file-path))
       (for [keyword- keywords]
            (setv lines [])
            (for [line (range (len text))]
                 (when (in keyword- (. text [line]))
                       ((. lines append) (+ line 1))))
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


(defn get-text-from-file [path]
  "
  :type path: str
  :rtype: list[str]
  "
  (setv encords
        ["utf-8"
         "utf-8-sig"
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
                  (break))
            (except [UnicodeDecodeError UnicodeError]
                    (continue))
            (except [PermissionError]
                    (raise))))
  data)


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
                    ((. ", " join) (map str lines))))))
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

  ;; Validate arguments.
  (try (setv valid-extensions (get-data-from-file (. args extensions-file)))
       (except [IOError]
               ((. *logger* critical)
                ((. "Cannot open a valid extensions file: {0}" format)
                 (. args extensions-file)))
               (raise)))

  (try (setv keywords (get-data-from-file (. args keywords-file)))
       (except [IOError]
               ((. *logger* critical)
                ((. "Cannot open a keywords file: {0}" format)
                 (. args keywords-file)))
               (raise)))

  (for [dir- (. args directories)]
       (if ((. os path isdir) dir-)
           (continue)
           (do ((. logger critical)
                ((. "Invalid directory: {0}" format) dir-))
               (raise ValueError))))

  ;; Search keywords from files at each directories.
  (setv result-dict-list [])
  (for [dir- (. args directories)]
       (for [(, path dirs filenames)
            ((. os walk) dir- :onerror callback-walk-handler)]
            (setv result-dict (get-dir-search-result path
                                                     filenames
                                                     keywords
                                                     valid-extensions))
            (when result-dict
                  ((. result-dict-list append) result-dict))))

  ;; Output result data.
  (if result-dict-list
      (do (setv result-dict (get-merge-dict result-dict-list))
          (if (= (. args output-file) "")
              (show-result result-dict)
              (write-data-to-file result-dict (. args output-file)))
          0)
      1))


(when (= --name-- "__main__")
      ((. sys exit) (main)))
