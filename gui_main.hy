#!/usr/bin/env hy
;; -*- coding: utf-8 -*-

(import argparse)
(import [collections [OrderedDict]])
(import json)
(import logging)
(import os)
(import sys)

(import [PySide2.QtCore [QStringListModel]])
(import [Qt.QtCore [Qt]])
(import [Qt.QtWidgets [QApplication
                       QFileDialog
                       QMessageBox
                       QWidget]])

(import [module.datautils [get-merged-dict]])
(import [module.io [dump-html
                    dump-json
                    read-json
                    read-texts
                    show]])
(import [module.search [find-from-dir
                        find-from-file
                        find-from-text
                        find-from-texts]])
(import [ui.PySide2.search_keywords :as search_keywords])


(setv *logger* ((. logging getLogger) "search-keywords.gui-main"))


(defclass MainWindow [QWidget search_keywords.Ui_Form]
  (setv *title* "SearchKeywords")
  (setv *semantic-version* (, "0" "2" "0"))
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
    ((. self radio-stdout toggled connect) (. self build-ui))
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
    ((. self -load-config) ((. os path join) "config" "config_default.json"))
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
        (do ((. *logger* info) "Executed.")
            (setv args ((. self -get-params)))
            ((. *logger* debug)
             "Start search keywords from files for each directories.")
            (setv results [])
            (for [dir- (. args ["directories"])]
                 (for [(, path dirs filenames)
                      ((. os walk) dir- :onerror callback-onerror)]
                      (setv result (find-from-dir path
                                                  filenames
                                                  (. args ["keywords"])
                                                  (. args ["ignores"])
                                                  (. args ["insensitive"])))
                 (when result
                       ((. results append) result))))
            ((. *logger* debug) "Done.")

            ;; Output result data.
            ((. *logger* debug) "Start output result data.")
            (if results
                (do ((. *logger* info) "Detected.")
                    (setv result (get-merged-dict results))
                    ((. self text-edit-result setText) "")
                    (cond [(. args ["stdout"]) (show result)]
                          [(. args ["json"]["radio"]) (dump-json args result)]
                          [(. args ["html"]["radio"]) (dump-html args result)]
                          [True (raise Exception)])
                    ((. self -show) result))
                (do ((. *logger* info) "Did not detect."))))
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

  (defn -get-path [self &optional [directory False] [file_extension "json"]]
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
          (setv keywords ((. params get) "keywords" []))
          (setv ignores ((. params get) "ignores" []))
          (setv insensitive ((. params get) "insensitive" True))
          (setv stdout ((. params get) "stdout" True))
          (setv json-output (. ((. params get) "json" False) ["radio"]))
          (setv json-path (. ((. params get) "json" "") ["output"]))
          (setv html-output (. ((. params get) "html" False) ["radio"]))
          (setv html-path (. ((. params get) "html" "") ["output"]))
          (setv html-template (. ((. params get) "html" "") ["template"]))
          (setv html-browser (. ((. params get) "html" "") ["browser"]))

          (when geometry
                ((. self setGeometry) #* geometry))
          ((. self line-edit-config setText) config-path)
          ((. self list-view-directories setModel)
           ((. QStringListModel) directories))
          ((. self list-view-keywords setModel)
           ((. QStringListModel) keywords))
          ((. self list-view-ignores setModel)
           ((. QStringListModel) ignores))
          ((. self check-box-insensitive setChecked) insensitive)
          ((. self radio-stdout setChecked) stdout)
          ((. self radio-json setChecked) json-output)
          ((. self line-edit-json-file setText) json-path)
          ((. self radio-html setChecked) html-output)
          ((. self line-edit-html-file setText) html-path)
          ((. self line-edit-html-template setText) html-template)
          ((. self line-edit-html-browser setText) html-browser))
    None)

  (defn save-ini [self]
    "
    :rtype: None
    "
    (setv geometry ((. self geometry)))
    (setv geom {"window_geometry" (, ((. geometry x))
                                     ((. geometry y))
                                     ((. geometry width))
                                     ((. geometry height)))})
    (setv params (get-merged-dict [geom ((. self -get-params))]))
    (with [fp (open (. self ini-file-name) :mode "w" :encoding "utf-8")]
          ((. json dump) params
                         fp
                         :indent 2))
    None)

  (defn build-ui [self]
    "
    :rtype: None
    "
    (cond [((. self radio-stdout isChecked))
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
    None)

  (defn -get-list [self list-view]
    "
    :type list-view: QListView
    :rtype: list[str]
    "
    (setv -model ((. list-view model)))
    (if -model
        ((. -model stringList))
        []))

  (defn -get-params [self]
    "
    :rtype: dict
    "
    (setv params {})
    (assoc params "config" ((. self line-edit-config text)))
    (assoc params "directories"
           ((. self -get-list) (. self list-view-directories)))
    (assoc params "keywords" ((. self -get-list) (. self list-view-keywords)))
    (assoc params "ignores" ((. self -get-list) (. self list-view-ignores)))
    (assoc params "insensitive" ((. self check-box-insensitive isChecked)))
    (assoc params "stdout" ((. self radio-stdout isChecked)))
    (assoc params "json" {"radio" ((. self radio-json isChecked))
                        "output" ((. self line-edit-json-file text))})
    (assoc params "html" {"radio" ((. self radio-html isChecked))
                        "output" ((. self line-edit-html-file text))
                        "template" ((. self line-edit-html-template text))
                        "browser" ((. self line-edit-html-browser text))})
    params)

  (defn -load-config [self path]
    "
    :rtype: None
    "
    (setv config-default (read-json path))
    (setv list-directories
          (QStringListModel (. config-default ["directories"])))
    (setv list-keywords
          (QStringListModel (. config-default ["keywords"])))
    (setv list-ignores
          (QStringListModel (. config-default ["ignores"])))
    ((. self list-view-directories setModel) list-directories)
    ((. self list-view-keywords setModel) list-keywords)
    ((. self list-view-ignores setModel) list-ignores)
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

  (defn -show [self result]
    "
    :type result: dict[str, list[list[str, list[list[int, list[int]]]]]]
    :rtype: None
    "
    (setv result-list [])
    (for [keyword- result]
         (for [(, file-path positions) (. result [keyword-])]
              (for [(, row columns) positions]
                   ((. result-list append)
                    ((. "{0}:{1} ({2}: {3})" format)
                     file-path
                     (inc row)
                     ((. ", " join) (map (fn [column] (str (inc column)))
                                         columns))
                     keyword-)))))
    ((. self text-edit-result setPlainText) ((. "\n" join) result-list))
    None))


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
