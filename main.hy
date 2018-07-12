#!/usr/bin/env hy
;; -*- coding: utf-8 -*-

(import argparse)
(import json)
(import logging)
(import os)
(import sys)
(import traceback)

(import [module.datautils [bin-to-str
                           get-merged-dict
                           split-lines]])
(import [module.io [dump-html
                    dump-json
                    read-texts
                    show]])
(import [module.search [find-from-dir
                        find-from-file
                        find-from-text
                        find-from-texts]])


(setv *logger* ((. logging getLogger) "search-keywords.main"))


(defclass DirectoryNotFound [Exception]
  (pass))


(defn callback-onerror [exception]
  "
  :type exception: Exception
  :rtype: None
  "
  ((. traceback print-exc))
  None)


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
                                :type str)
  ((. parser-json set-defaults) :func dump-json)
  (setv parser-html
        ((. subparsers add-parser) "html"
                                   :help "output html"))
  ((. parser-html add-argument) "-o" "--output"
                                :default "detection.html"
                                :dest "output_file"
                                :help "output file"
                                :type str)
  ((. parser-html add-argument) "--template"
                                :default "detection.tpl.html"
                                :dest "template"
                                :help "HTML template file")
  ((. parser-html add-argument) "--browser"
                                :default ((. os path join) "src"
                                                           "browser.json")
                                :dest "browser"
                                :help "browser file path"
                                :type str)
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

  ;; Search keywords from files for each directories.
  ((. *logger* debug) "Start search keywords from files for each directories.")
  (setv results [])
  (for [dir- (. args directories)]
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
