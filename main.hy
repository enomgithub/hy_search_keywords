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
                    read-json
                    read-texts
                    show]])
(import [module.search [find-from-dir
                        find-from-file
                        find-from-text
                        find-from-texts]])


(setv *logger* ((. logging getLogger) "search-keywords.main"))


(defclass DirectoryNotFound [Exception])


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
  ((. parser add-argument) "-c" "--config"
                           :default ((. os path join) "config" "config.json")
                           :dest "config_file"
                           :help "config file path"
                           :type str)
  ((. parser add-argument) "-d" "--directories"
                           :default "."
                           :dest "directories"
                           :help "search directories"
                           :nargs "+"
                           :type str)
  ((. parser add-argument) "--insensitive"
                           :action "store_true"
                           :help "case insensitve")
  ((. parser add-argument) "--debug"
                           :action "store_true"
                           :help "debug mode")
  ((. parser add-argument) "--output"
                           :choices ["stdout" "json" "html"]
                           :default "stdout"
                           :help "output style")
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
        (lfor dir- (. args directories)
              :if (not ((. os path isdir) dir-))
              dir-))

  (when invalid-directories
        (for [dir- invalid-directories]
             ((. *logger* critical)
              ((. "Directory not found: {0}" format)
               dir-)))
        (raise DirectoryNotFound))

  (try (setv config (read-json (. args config-file)))
       (except [OSError]
               ((. *logger* critical)
                ((. "Cannot open the keywords file: {0}" format)
                 (. args config-file)))
               (raise)))
  (setv keywords ((. config get) "keywords" []))
  (setv ignores ((. config get) "ignores" []))
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
          (cond [(= (. args output) "stdout") (show result)]
                [(= (. args output) "json") (dump-json config result)]
                [(= (. args output) "html") (dump-html config result)])
          0)
      (do ((. *logger* info) "Did not detect.")
          1)))


(when (= --name-- "__main__")
      ((. sys exit) (main)))
