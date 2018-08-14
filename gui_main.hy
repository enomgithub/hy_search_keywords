#!/usr/bin/env hy
;; -*- coding: utf-8 -*-

(import argparse)
(import [collections [OrderedDict]])
(import json)
(import logging)
(import os)
(import sys)

(import [Qt.QtCore [Qt]])
(import [Qt.QtWidgets [QApplication
                       QFileDialog
                       QMessageBox
                       QWidget]])
(import [ui.PySide2.search_keywords :as search_keywords])


(setv *logger* ((. logging getLogger) "search-keywords.gui-main"))


(defclass MainWindow [QWidget search_keywords.Ui_Form]
  (setv *title* "SearchKeywords")
  (setv *semantic-version* (, "0" "1" "1"))
  (defn --init-- [self]
    "
    :rtype: None
    "
    ((. (super) --init--))
    ((. self.setupUi) self)

    ((. self setWindowTitle)
     ((. "{0} - v{1}" format) (. self *title*)
                             ((. "." join) (. self *semantic-version*))))

    ;; Geometry setting
    (setv ini-dir "ini")
    (if-not ((. os path exists) ini-dir)
            ((. os makedirs) ini-dir))
    (setv (. self ini-file-name)
          ((. os path join) ini-dir
                            (+ (. self *title*) ".json")))
    ((. self load-ini))

    ;; Connection settings
    ((. self button-config clicked connect) (. self callback-config))
    ((. self radio-stdio toggled connect) (. self build-ui))
    ((. self radio-json toggled connect) (. self build-ui))
    ((. self button-json-file clicked connect) (. self callback-json-file))
    ((. self radio-html toggled connect) (. self build-ui))
    ((. self button-html-file clicked connect) (. self callback-html-file))
    ((. self button-html-template clicked connect)
     (. self callback-html-template))
    ((. self button-html-browser clicked connect)
     (. self callback-html-browser))
    ((. self button-default clicked connect) (. self callback-default))
    ((. self button-execute clicked connect) (. self callback-execute))

    ;; Initialize condition
    ((. self build-ui))
    None)

  (defn callback-help [self]
    "
    :rtype: None
    "
    None)

  (defn callback-default [self]
    "
    :rtype: None
    "
    (with [fp (open ((. os path join) "config" "config_default.json")
                                      :mode "r"
                                      :encoding "utf-8")]
          (setv config-default ((. json load) fp)))
    ((. self line-edit-config setText) "")
    ((. self line-edit-json-file setText)
     (. config-default ["json"] ["output"]))
    ((. self line-edit-html-file setText)
     (. config-default ["html"] ["output"]))
    ((. self line-edit-html-template setText)
     (. config-default ["html"] ["template"]))
    ((. self line-edit-html-browser setText)
     (. config-default ["html"] ["browser"]))
    None)

  (defn callback-execute [self]
    "
    :rtype: None
    "
    (setv message
          ((. QMessageBox question) self
                                    "Confirmation"
                                    "Are you sure you want to execute?"
                                    (| (. QMessageBox Yes)
                                       (. QMessageBox No))
                                    (. QMessageBox No)))
    (if (= message (. QMessageBox Yes))
        ((. *logger* info) "Executed.")
        ((. *logger* info) "Aborted."))
    None)

  (defn callback-directory-add [self]
    "
    :rtype: None
    "
    (setv directory-name ((. self -get-path) :directory True))
    ; (when directory-name
    ;      ((. self combo-box-directories addItem) directory-name))
    None)

  (defn callback-directory-delete [self]
    "
    :rtype: None
    "
    ; ((. self combo-box-directories removeItem)
    ; ((. self combo-box-directories currentIndex)))
    None)

  (defn callback-config [self]
    "
    :rtype: None
    "
    (setv file-name ((. self -get-path)))
    (when (first file-name)
          ((. self line-edit-config setText) (first file-name)))
    None)

  (defn callback-json-file [self]
    "
    :rtype: None
    "
    (setv file-name ((. self -get-path)))
    (when (first file-name)
          ((. self line-edit-json-file setText) (first file-name)))
    None)

  (defn callback-html-file [self]
    "
    :rtype: None
    "
    (setv file-name ((. self -get-path) :file-extension "html"))
    (when (first file-name)
          ((. self line-edit-html-file setText) (first file-name)))
    None)

  (defn callback-html-template [self]
    "
    :rtype: None
    "
    (setv file-name ((. self -get-path) :file-extension "tpl.html"))
    (when (first file-name)
          ((. self line-edit-html-template setText) (first file-name)))
    None)

  (defn callback-html-browser [self]
    "
    :rtype: None
    "
    (setv file-name ((. self -get-path) :file-extension "exe"))
    (when (first file-name)
          ((. self line-edit-html-browser setText) (first file-name)))
    None)

  (defn closeEvent [self event]
    "
    :type event: QEvent
    :rtype: None
    "
    ((. self save-ini))
    None)

  (defn -get-path [self &key {"directory" False "file_extension" "json"}]
    "
    :type directory: bool
    :rtype: str or list[str]
    "
    (if directory
        ((. QFileDialog getExistingDirectory) self
                                              "Open directory"
                                              "")
        ((. QFileDialog getOpenFileName) self
                                         "Open file"
                                         ""
                                         ((. "{0} files (*.{1})" format)
                                          ((. file-extension upper))
                                          file-extension))))

  (defn load-ini [self]
    "
    :rtype: None
    "
    (when ((. os path isfile) (. self ini-file-name))
          (with [fp (open (. self ini-file-name) :encoding "utf-8")]
                (try (setv params ((. json load) fp))
                     (except [Exception]
                             ((. *logger* error)
                              ((. "Can't read ini file: {0}" format)
                               (. self ini-file-name)))
                             (raise))))
          (setv geometry ((. params get) "window_geometry" None))
          (setv config-path ((. params get) "config" ""))
          (setv directories ((. params get) "directories" []))
          (when geometry
                ((. self setGeometry) #* geometry))
          ((. self line-edit-config setText) config-path))
    None)

  (defn save-ini [self]
    "
    :rtype: None
    "
    (setv params (OrderedDict))
    (setv geometry ((. self geometry)))
    ; (setv directories
    ;      (list (map (fn [index]
    ;                   ((. self combo-box-directories itemText) index))
    ;                 (range ((. self combo-box-directories count))))))
    (assoc params "window_geometry" (, ((. geometry x))
                                       ((. geometry y))
                                       ((. geometry width))
                                       ((. geometry height))))
    ; (when directories
    ;      (assoc params "directories" directories))
    (assoc params "config" ((. self line-edit-config text)))
    (assoc params "stdio" ((. self radio-stdio isChecked)))
    (assoc params "json" {"radio" ((. self radio-json isChecked))
                          "path" ((. self line-edit-json-file text))})
    (assoc params "html" {"radio" ((. self radio-html isChecked))
                          "path" ((. self line-edit-html-file text))})
    (with [fp (open (. self ini-file-name) :mode "w" :encoding "utf-8")]
          ((. json dump) params
                         fp
                         :indent 2))
    None)

  (defn build-ui [self]
    "
    :rtype: None
    "
    (cond [((. self radio-stdio isChecked))
           ((. self line-edit-json-file setDisabled) True)
           ((. self button-json-file setDisabled) True)
           ((. self line-edit-html-file setDisabled) True)
           ((. self button-html-file setDisabled) True)
           ((. self line-edit-html-template setDisabled) True)
           ((. self button-html-template setDisabled) True)
           ((. self line-edit-html-browser setDisabled) True)
           ((. self button-html-browser setDisabled) True)]
          [((. self radio-json isChecked))
           ((. self line-edit-json-file setEnabled) True)
           ((. self button-json-file setEnabled) True)
           ((. self line-edit-html-file setDisabled) True)
           ((. self button-html-file setDisabled) True)
           ((. self line-edit-html-template setDisabled) True)
           ((. self button-html-template setDisabled) True)
           ((. self line-edit-html-browser setDisabled) True)
           ((. self button-html-browser setDisabled) True)]
          [((. self radio-html isChecked))
           ((. self line-edit-json-file setDisabled) True)
           ((. self button-json-file setDisabled) True)
           ((. self line-edit-html-file setEnabled) True)
           ((. self button-html-file setEnabled) True)
           ((. self line-edit-html-template setEnabled) True)
           ((. self button-html-template setEnabled) True)
           ((. self line-edit-html-browser setEnabled) True)
           ((. self button-html-browser setEnabled) True)])
    None))


(defn main []
  "
  :rtype: int
  "
  (setv parser ((. argparse ArgumentParser) :description "search keywords"))
  ((. parser add-argument) "--debug"
                           :action "store_true"
                           :help "debug mode")
  (setv args ((. parser parse-args)))

  ;; Logger setting
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

  (setv app (QApplication (. sys argv)))
  (setv window (MainWindow))
  ((. window show))
  ((. app exec-))
  0)


(when (= --name-- "__main__")
      ((. sys exit) (main)))
