#!/usr/bin/env hy
;; -*- coding: utf-8 -*-

(import sys)
(import os)


(defn get-child-dirs-list [path]
  "
  :type path: str
  :rtype: list[str]
  "
  (list-comp dir- [dir- ((. os listdir) path)]
                  ((. os path isdir) ((. os path join) path dir-))))


(defn get-files-list [path]
  "
  :type path: str
  :rtype: list[str]
  "
  (list-comp file [file ((. os listdir) path)]
                  ((. os path isfile) ((. os path join) path file))))


(defn get-node-dict [path]
  "
  :type path: str
  :rtype: dict[str, list or str]
  "
  (setv node {})
  (setv (. node ["directory"]) (get-child-dirs-list path))
  (setv (. node ["file"]) (get-files-list path))
  (setv (. node ["path"]) path)
  node)
