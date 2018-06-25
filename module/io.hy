#!/usr/bin/env hy
;; -*- coding: utf-8 -*-

(import json)
(import logging)

(import [jinja2 [Environment]])

(import [module.datautils [bin-to-str
                    split-lines]])


(setv *logger* ((. logging getLogger) "search-keywords.module.io"))


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
