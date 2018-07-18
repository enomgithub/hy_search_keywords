#!/usr/bin/env hy
;; -*- coding: utf-8 -*-

(import [collections [OrderedDict]])
(import json)
(import logging)
(import os)
(import sys)

(import [Qt.QtCore [Qt]])
(import [Qt.QtWidgets [QApplication
                       QComboBox
                       QDialog
                       QFileDialog
                       QHBoxLayout
                       QLabel
                       QLineEdit
                       QMessageBox
                       QPushButton
                       QVBoxLayout]])


(setv *logger* ((. logging getLogger) "search-keywords.gui-main"))


(defclass MainWindow [QDialog]
  (setv *title* "SearchKeywords")
  (setv *semantic-version* "v0.1.0")
  (defn --init-- [self]
    "
    :rtype: None
    "
    ((. (super) --init--))

    ;; Layout settings
    (setv (. self label-config) (QLabel "Config file"))
    (setv (. self line-edit-config) (QLineEdit))
    (setv (. self button-config) (QPushButton "Open"))
    (setv hbox-config (QHBoxLayout))
    ((. hbox-config addWidget) (. self label-config))
    ((. hbox-config addWidget) (. self line-edit-config))
    ((. hbox-config addWidget) (. self button-config))

    (setv (. self label-directories) (QLabel "Search directories"))
    (setv (. self combo-box-directories) (QComboBox))
    ((. self combo-box-directories setSizeAdjustPolicy)
     (. QComboBox AdjustToContents))
    (setv (. self button-directory-add) (QPushButton "Add"))
    (setv (. self button-directory-delete) (QPushButton "Delete"))
    (setv hbox-directories (QHBoxLayout))
    ((. hbox-directories addWidget) (. self label-directories))
    ((. hbox-directories addWidget) (. self combo-box-directories))
    ((. hbox-directories addWidget) (. self button-directory-add))
    ((. hbox-directories addWidget) (. self button-directory-delete))
    ((. hbox-directories addStretch) 0)

    (setv (. self button-help) (QPushButton "Help"))
    (setv (. self button-default) (QPushButton "Default"))
    (setv (. self button-execute) (QPushButton "Execute"))
    (setv hbox-buttons (QHBoxLayout))
    ((. hbox-buttons addWidget) (. self button-help))
    ((. hbox-buttons addWidget) (. self button-default))
    ((. hbox-buttons addStretch) 0)
    ((. hbox-buttons addWidget) (. self button-execute))

    (setv vbox (QVBoxLayout))
    ((. vbox addLayout) hbox-config)
    ((. vbox addLayout) hbox-directories)
    ((. vbox addStretch) 0)
    ((. vbox addLayout) hbox-buttons)

    ((. self setLayout) vbox)
    ((. self setWindowTitle)
     ((. "{0} - {1}" format) (. self *title*)
                             (. self *semantic-version*)))

    ;; Geometry setting
    ;((. self setGeometry) 300 300 400 400)
    (setv ini-dir ((. os path join) "ini"))
    (if-not ((. os path exists) ini-dir)
            ((. os makedirs) ini-dir))
    (setv (. self ini-file-name)
          ((. os path join) ini-dir
                            (+ (. self *title*) ".json")))
    ((. self load-ini))

    ;; Connection settings
    ((. self button-config clicked connect) (. self callback-config))
    ((. self button-directory-add clicked connect)
     (. self callback-directory-add))
    ((. self button-directory-delete clicked connect)
     (. self callback-directory-delete))
    ((. self button-default clicked connect) (. self callback-default))
    ((. self button-execute clicked connect) (. self callback-execute))

    ;; Initialize condition
    None)

  (defn callback-default [self]
    "
    :rtype: None
    "
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
        (print "Executed.")
        (print "Aborted."))
    None)

  (defn callback-directory-add [self]
    "
    :rtype: None
    "
    (setv directory-name ((. self -get-path) :directory True))
    (when directory-name
          ((. self combo-box-directories addItem) directory-name))
    None)

  (defn callback-directory-delete [self]
    "
    :rtype: None
    "
    ((. self combo-box-directories removeItem)
     ((. self combo-box-directories currentIndex)))
    None)

  (defn callback-config [self]
    "
    :rtype: None
    "
    (setv file-name ((. self -get-path)))
    (when (first file-name)
          ((. self line-edit-config setText) (first file-name)))
    None)

  (defn closeEvent [self event]
    "
    :type event: QEvent
    :rtype: None
    "
    ((. self save-ini))
    None)

  (defn -get-path [self &key {"directory" False}]
    "
    :rtype: str or list[str]
    "
    (if directory
        ((. QFileDialog getExistingDirectory) self
                                              "Open directory"
                                              "")
        ((. QFileDialog getOpenFileName) self
                                         "Open file"
                                         ""
                                         "JSON files (*.json)")))

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
          ((. self line-edit-config setText) config-path)
          (when directories
                (for [dir- directories]
                     ((. self combo-box-directories addItem) dir-))))
    None)

  (defn save-ini [self]
    "
    :rtype: None
    "
    (setv params (OrderedDict))
    (setv geometry ((. self geometry)))
    (setv directories
          (list (map (fn [index]
                       ((. self combo-box-directories itemText) index))
                     (range ((. self combo-box-directories count))))))
    (assoc params "window_geometry" (, ((. geometry x))
                                       ((. geometry y))
                                       ((. geometry width))
                                       ((. geometry height))))
    (when directories
          (assoc params "directories" directories))
    (assoc params "config" ((. self line-edit-config text)))
    (with [fp (open (. self ini-file-name) :mode "w" :encoding "utf-8")]
          ((. json dump) params
                         fp
                         :indent 2))
    None))


(defn main []
  "
  :rtype: int
  "
  (setv app (QApplication (. sys argv)))
  (setv window (MainWindow))
  ((. window show))
  ((. app exec-))
  0)


(when (= --name-- "__main__")
      ((. sys exit) (main)))
