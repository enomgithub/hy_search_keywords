#!/usr/bin/env hy
;; -*- coding: utf-8 -*-

(import argparse)
(import fnmatch)
(import json)
(import logging)
(import os)
(import re)
(import sys)
(import traceback)
(import unicodedata)

(import [jinja2 [Environment]])
(import tqdm)


(setv *logger* ((. logging getLogger) "search-keywords"))


(defclass DirectoryNotFound [Exception]
  (pass))


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


(defn callback-onerror [exception]
  "
  :type exception: Exception
  :rtype: None
  "
  ((. traceback print-exc))
  None)


(defn dump-html [args data]
  "
  :type args: Namespace
  :type data: dict or list
  :rtype: None
  "
  (setv environment (Environment))
  (with [fp (open (. args template) "r" :encoding "utf-8")]
        (setv template-text ((. fp read))))
  (setv template ((. environment from-string) template-text))
  (setv html ((. template render) {"result" data}))
  ((. args output-file write) html)
  None)


(defn dump-json [args data]
  "
  :type args: Namespace
  :type data: dict or list
  :rtype: None
  "
  ((. json dump) data
                 (. args output-file)
                 :ensure-ascii False
                 :indent 2)
  None)


(defn find-from-dir [path file-names keywords ignores
                     &key {"insensitive" False}]
  "
  :type path: str
  :type filenames: list[str]
  :type keywords: list[str]
  :type ignores: list[str]
  :type insensitive: bool
  :rtype: dict[str, list[list[str, list[list[int, list[int]]]]]]
  "
  (setv path-list ((. path split) (. os path sep)))
  (if (or #* (list (map (fn [dir-]
                          (or #* (list (map (fn [ignore]
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


(defn find-from-file [path file-name keywords ignores
                      &key {"insensitive" False}]
  "
  :type path: str
  :type file-name: str
  :type keywords: list[str]
  :type ignores: list[str]
  :type insensitive: bool
  :rtype: dict[str, list[list[str, list[list[int, list[int]]]]]]
  "
  (if (or #* (list (map (fn [ignore]
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


(defn find-from-text [text keyword- &key {"insensitive" False}]
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


(defn find-from-texts [texts keyword- &key {"insensitive" False}]
  "
  :type texts: list[str]
  :type keyword-: str
  :type insensitive: bool
  :rtype: list[list[int, list[int]]]
  "
  (list (remove empty?
                (map (fn [(, index text)]
                       (do (setv columns
                                 (find-from-text text
                                                 keyword-
                                                 insensitive))
                           (if columns
                               [index columns]
                               [])))
                     (enumerate texts)))))


(defn get-merged-dict [dicts-]
  "
  :type dicts-: list[dict]
  :rtype: dict
  "
  (cond [(= dicts- []) {}]
        [(= (len dicts-) 1) (. dicts- [0])]
        [True (merge-with (fn [x y] (+ x y)) #* dicts-)]))


(defn read-texts [path]
  "
  :type path: str
  :rtype: list[str]
  "
  (setv encodes
        ["utf-8-sig"
         "euc-jp"
         "cp932"
         "utf-16"
         "utf-16-le"])
  (with [fp (open path :mode "rb")]
        (setv bin-data ((. fp read))))
  (or #* (map (fn [enc]
                (try (-> (bin-to-str bin-data enc) (split-lines))
                     (except [AttributeError]
                             None)))
              encodes)))


(defn show [args result]
  "
  :typte args: Namespace
  :type result: dict[str, list[list[str, list[list[int, list[int]]]]]]
  :rtype: None
  "
  (for [keyword- result]
       (for [(, file-path positions) (. result [keyword-])]
            (for [(, row columns) positions]
                 (print ((. "{0}:{1} ({2}: {3})" format)
                         file-path
                         (inc row)
                         ((. ", " join) (map (fn [column]
                                               (str (inc column)))
                                             columns))
                         keyword-)))))
  None)


(defn split-lines [text]
  "
  :type text: str
  :rtype: list[str]
  "
  (-> text (.replace "\r" "") (.split "\n")))


(defn main []
  "
  :rtype: int
  "
  (setv parser ((. argparse ArgumentParser) :description "search keywords"))
  ((. parser add-argument) "-k" "--keywords"
                           :default ((. os path join) "src" "keywords.json")
                           :dest "keywords_file"
                           :help "keywords file path"
                           :type ((. argparse FileType) :mode "r"
                                                        :encoding "utf-8"))
  ((. parser add-argument) "-d" "--directories"
                           :default "."
                           :dest "directories"
                           :help "search directories"
                           :nargs "+"
                           :type str)
  ((. parser add-argument) "-i" "--ignores"
                           :default ((. os path join) "src" "ignores.json")
                           :dest "ignores_file"
                           :help "ignores file path"
                           :type ((. argparse FileType) :mode "r"
                                                        :encoding "utf-8"))
  ((. parser add-argument) "--insensitive"
                           :action "store_true"
                           :help "case insensitve")
  ((. parser add-argument) "--debug"
                           :action "store_true"
                           :help "debug mode")
  (setv subparsers ((. parser add-subparsers) :help "subcommand -h"))
  (setv parser-stdout
        ((. subparsers add-parser) "stdout"
                                   :help "stdout"))
  ((. parser-stdout set-defaults) :func show)
  (setv parser-json
        ((. subparsers add-parser) "json"
                                   :help "output json"))
  ((. parser-json add-argument) "-o" "--output"
                                :default "detection.json"
                                :dest "output_file"
                                :help "output file"
                                :type ((. argparse FileType) :mode "w"
                                                             :encoding "utf-8"))
  ((. parser-json set-defaults) :func dump-json)
  (setv parser-html
        ((. subparsers add-parser) "html"
                                   :help "output html"))
  ((. parser-html add-argument) "-o" "--output"
                                :default "detection.html"
                                :dest "output_file"
                                :help "output file"
                                :type ((. argparse FileType) :mode "w"
                                                             :encoding "utf-8"))
  ((. parser-html add-argument) "--template"
                                :default "detection.tpl.html"
                                :dest "template"
                                :help "HTML template file")
  ((. parser-html set-defaults) :func dump-html)
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

  (try (setv keywords ((. json load) (. args keywords-file)))
       (except [OSError]
               ((. *logger* critical)
                ((. "Cannot open the keywords file: {0}" format)
                 (. args keywords-file)))
               (raise)))
  (try (setv ignores ((. json load) (. args ignores-file)))
       (except [OSError]
               ((. *logger* critical)
                ((. "Cannot open the ignores file: {0}" format)
                 (. args ignores-file)))
               (raise)))
  ((. *logger* debug) "Done.")

  ;; Search keywords from files at each directories.
  ((. *logger* debug) "Start search keywords from files at each directories.")
  (setv results [])
  (for [dir- ((. tqdm tqdm) (. args directories) :ascii True)]
       (for [(, path dirs filenames)
             ((. os walk) dir- :onerror callback-onerror)]
            (setv result (find-from-dir path
                                        filenames
                                        keywords
                                        ignores
                                        (. args insensitive)))
            (when result
                  ((. results append) result))))
  ((. *logger* debug) "Done.")

  ;; Output result data.
  ((. *logger* debug) "Start output result data.")
  (if results
      (do ((. *logger* info) "Detected.")
          (setv result (get-merged-dict results))
          ((. args func) args result)
          0)
      (do ((. *logger* info) "Did not detect.")
          1)))


(when (= --name-- "__main__")
      ((. sys exit) (main)))
