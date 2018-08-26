#!/usr/bin/env hy
;; -*- coding: utf-8 -*-

(import json)
(import logging)
(import subprocess)

(import [jinja2 [Environment]])

(import [module.datautils [bin-to-str
                           split-lines]])


(setv *logger* ((. logging getLogger) "search-keywords.module.io"))


(defn dump-html [config data]
  "
  :type config: dict
  :type data: dict or list
  :rtype: None
  "
  (setv environment (Environment))
  (setv template-text
        (with [fp (open (. config ["html"] ["template"])
                        :mode "r"
                        :encoding "utf-8")]
              ((. fp read))))
  (setv template ((. environment from-string) template-text))
  (setv html ((. template render) {"result" data}))
  (with [fp (open (. config ["html"] ["output"])
                  :mode "w"
                  :encoding "utf-8")]
        ((. fp write) html))
  (setv browser-path (. config ["html"] ["browser"]))
  ((. subprocess Popen) [browser-path (. config ["html"] ["output"])])
  None)


(defn dump-json [config data]
  "
  :type config: dict
  :type data: dict or list
  :rtype: None
  "
  (with [fp (open (. config ["json"] ["output"])
                  :mode "w"
                  :encoding "utf-8")]
        ((. json dump) data
                       fp
                       :ensure-ascii False
                       :indent 2))
  None)


(defn read-json [path]
  "
  :type path: str
  :rtype: list or dict or str or int or None
  "
  (with [fp (open path :mode "r" :encoding "utf-8")]
        ((. json load) fp)))


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


(defn show [result]
  "
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
