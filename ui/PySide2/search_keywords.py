# -*- coding: utf-8 -*-

# Form implementation generated from reading ui file 'search_keywords.ui'
#
# Created: Tue Aug 14 11:29:25 2018
#      by: pyside2-uic  running on PySide2 5.11.0a1.dev1525359714
#
# WARNING! All changes made in this file will be lost!

from PySide2 import QtCore, QtGui, QtWidgets

class Ui_Form(object):
    def setupUi(self, Form):
        Form.setObjectName("Form")
        Form.resize(312, 486)
        self.gridLayout = QtWidgets.QGridLayout(Form)
        self.gridLayout.setObjectName("gridLayout")
        spacerItem = QtWidgets.QSpacerItem(20, 40, QtWidgets.QSizePolicy.Minimum, QtWidgets.QSizePolicy.Expanding)
        self.gridLayout.addItem(spacerItem, 4, 0, 1, 1)
        self.horizontalLayout_2 = QtWidgets.QHBoxLayout()
        self.horizontalLayout_2.setObjectName("horizontalLayout_2")
        self.group_box_directories = QtWidgets.QGroupBox(Form)
        self.group_box_directories.setObjectName("group_box_directories")
        self.gridLayout_3 = QtWidgets.QGridLayout(self.group_box_directories)
        self.gridLayout_3.setObjectName("gridLayout_3")
        self.list_view_directories = QtWidgets.QListView(self.group_box_directories)
        self.list_view_directories.setObjectName("list_view_directories")
        self.gridLayout_3.addWidget(self.list_view_directories, 0, 0, 1, 1)
        self.horizontalLayout_2.addWidget(self.group_box_directories)
        self.group_box_keywords = QtWidgets.QGroupBox(Form)
        self.group_box_keywords.setObjectName("group_box_keywords")
        self.gridLayout_4 = QtWidgets.QGridLayout(self.group_box_keywords)
        self.gridLayout_4.setObjectName("gridLayout_4")
        self.list_view_keywords = QtWidgets.QListView(self.group_box_keywords)
        self.list_view_keywords.setObjectName("list_view_keywords")
        self.gridLayout_4.addWidget(self.list_view_keywords, 0, 0, 1, 1)
        self.horizontalLayout_2.addWidget(self.group_box_keywords)
        self.group_box_ignores = QtWidgets.QGroupBox(Form)
        self.group_box_ignores.setObjectName("group_box_ignores")
        self.gridLayout_5 = QtWidgets.QGridLayout(self.group_box_ignores)
        self.gridLayout_5.setObjectName("gridLayout_5")
        self.list_view_ignores = QtWidgets.QListView(self.group_box_ignores)
        self.list_view_ignores.setObjectName("list_view_ignores")
        self.gridLayout_5.addWidget(self.list_view_ignores, 0, 0, 1, 1)
        self.horizontalLayout_2.addWidget(self.group_box_ignores)
        self.gridLayout.addLayout(self.horizontalLayout_2, 2, 0, 1, 1)
        self.horizontalLayout_8 = QtWidgets.QHBoxLayout()
        self.horizontalLayout_8.setObjectName("horizontalLayout_8")
        self.button_help = QtWidgets.QPushButton(Form)
        self.button_help.setObjectName("button_help")
        self.horizontalLayout_8.addWidget(self.button_help)
        self.button_default = QtWidgets.QPushButton(Form)
        self.button_default.setObjectName("button_default")
        self.horizontalLayout_8.addWidget(self.button_default)
        spacerItem1 = QtWidgets.QSpacerItem(40, 20, QtWidgets.QSizePolicy.Expanding, QtWidgets.QSizePolicy.Minimum)
        self.horizontalLayout_8.addItem(spacerItem1)
        self.button_execute = QtWidgets.QPushButton(Form)
        self.button_execute.setObjectName("button_execute")
        self.horizontalLayout_8.addWidget(self.button_execute)
        self.gridLayout.addLayout(self.horizontalLayout_8, 5, 0, 1, 1)
        self.groupBox = QtWidgets.QGroupBox(Form)
        self.groupBox.setObjectName("groupBox")
        self.gridLayout_2 = QtWidgets.QGridLayout(self.groupBox)
        self.gridLayout_2.setObjectName("gridLayout_2")
        self.verticalLayout_2 = QtWidgets.QVBoxLayout()
        self.verticalLayout_2.setObjectName("verticalLayout_2")
        self.radio_json = QtWidgets.QRadioButton(self.groupBox)
        self.radio_json.setObjectName("radio_json")
        self.verticalLayout_2.addWidget(self.radio_json)
        self.horizontalLayout_4 = QtWidgets.QHBoxLayout()
        self.horizontalLayout_4.setObjectName("horizontalLayout_4")
        self.label_json_file = QtWidgets.QLabel(self.groupBox)
        self.label_json_file.setObjectName("label_json_file")
        self.horizontalLayout_4.addWidget(self.label_json_file)
        self.line_edit_json_file = QtWidgets.QLineEdit(self.groupBox)
        self.line_edit_json_file.setObjectName("line_edit_json_file")
        self.horizontalLayout_4.addWidget(self.line_edit_json_file)
        self.button_json_file = QtWidgets.QPushButton(self.groupBox)
        self.button_json_file.setObjectName("button_json_file")
        self.horizontalLayout_4.addWidget(self.button_json_file)
        self.verticalLayout_2.addLayout(self.horizontalLayout_4)
        self.gridLayout_2.addLayout(self.verticalLayout_2, 3, 0, 1, 1)
        self.verticalLayout = QtWidgets.QVBoxLayout()
        self.verticalLayout.setObjectName("verticalLayout")
        self.radio_html = QtWidgets.QRadioButton(self.groupBox)
        self.radio_html.setObjectName("radio_html")
        self.verticalLayout.addWidget(self.radio_html)
        self.horizontalLayout_5 = QtWidgets.QHBoxLayout()
        self.horizontalLayout_5.setObjectName("horizontalLayout_5")
        self.label_html_file = QtWidgets.QLabel(self.groupBox)
        self.label_html_file.setObjectName("label_html_file")
        self.horizontalLayout_5.addWidget(self.label_html_file)
        self.line_edit_html_file = QtWidgets.QLineEdit(self.groupBox)
        self.line_edit_html_file.setObjectName("line_edit_html_file")
        self.horizontalLayout_5.addWidget(self.line_edit_html_file)
        self.button_html_file = QtWidgets.QPushButton(self.groupBox)
        self.button_html_file.setObjectName("button_html_file")
        self.horizontalLayout_5.addWidget(self.button_html_file)
        self.verticalLayout.addLayout(self.horizontalLayout_5)
        self.horizontalLayout_6 = QtWidgets.QHBoxLayout()
        self.horizontalLayout_6.setObjectName("horizontalLayout_6")
        self.label_html_template = QtWidgets.QLabel(self.groupBox)
        self.label_html_template.setObjectName("label_html_template")
        self.horizontalLayout_6.addWidget(self.label_html_template)
        self.line_edit_html_template = QtWidgets.QLineEdit(self.groupBox)
        self.line_edit_html_template.setObjectName("line_edit_html_template")
        self.horizontalLayout_6.addWidget(self.line_edit_html_template)
        self.button_html_template = QtWidgets.QPushButton(self.groupBox)
        self.button_html_template.setObjectName("button_html_template")
        self.horizontalLayout_6.addWidget(self.button_html_template)
        self.verticalLayout.addLayout(self.horizontalLayout_6)
        self.horizontalLayout_7 = QtWidgets.QHBoxLayout()
        self.horizontalLayout_7.setObjectName("horizontalLayout_7")
        self.label_html_browser = QtWidgets.QLabel(self.groupBox)
        self.label_html_browser.setObjectName("label_html_browser")
        self.horizontalLayout_7.addWidget(self.label_html_browser)
        self.line_edit_html_browser = QtWidgets.QLineEdit(self.groupBox)
        self.line_edit_html_browser.setObjectName("line_edit_html_browser")
        self.horizontalLayout_7.addWidget(self.line_edit_html_browser)
        self.button_html_browser = QtWidgets.QPushButton(self.groupBox)
        self.button_html_browser.setObjectName("button_html_browser")
        self.horizontalLayout_7.addWidget(self.button_html_browser)
        self.verticalLayout.addLayout(self.horizontalLayout_7)
        self.gridLayout_2.addLayout(self.verticalLayout, 5, 0, 1, 1)
        self.radio_stdio = QtWidgets.QRadioButton(self.groupBox)
        self.radio_stdio.setChecked(True)
        self.radio_stdio.setObjectName("radio_stdio")
        self.gridLayout_2.addWidget(self.radio_stdio, 1, 0, 1, 1)
        self.line = QtWidgets.QFrame(self.groupBox)
        self.line.setFrameShape(QtWidgets.QFrame.HLine)
        self.line.setFrameShadow(QtWidgets.QFrame.Sunken)
        self.line.setObjectName("line")
        self.gridLayout_2.addWidget(self.line, 2, 0, 1, 1)
        self.line_2 = QtWidgets.QFrame(self.groupBox)
        self.line_2.setFrameShape(QtWidgets.QFrame.HLine)
        self.line_2.setFrameShadow(QtWidgets.QFrame.Sunken)
        self.line_2.setObjectName("line_2")
        self.gridLayout_2.addWidget(self.line_2, 4, 0, 1, 1)
        self.gridLayout.addWidget(self.groupBox, 3, 0, 1, 1)
        self.horizontalLayout = QtWidgets.QHBoxLayout()
        self.horizontalLayout.setObjectName("horizontalLayout")
        self.label_config = QtWidgets.QLabel(Form)
        self.label_config.setObjectName("label_config")
        self.horizontalLayout.addWidget(self.label_config)
        self.line_edit_config = QtWidgets.QLineEdit(Form)
        self.line_edit_config.setObjectName("line_edit_config")
        self.horizontalLayout.addWidget(self.line_edit_config)
        self.button_config = QtWidgets.QPushButton(Form)
        self.button_config.setObjectName("button_config")
        self.horizontalLayout.addWidget(self.button_config)
        self.gridLayout.addLayout(self.horizontalLayout, 0, 0, 1, 1)
        self.line_3 = QtWidgets.QFrame(Form)
        self.line_3.setFrameShape(QtWidgets.QFrame.HLine)
        self.line_3.setFrameShadow(QtWidgets.QFrame.Sunken)
        self.line_3.setObjectName("line_3")
        self.gridLayout.addWidget(self.line_3, 1, 0, 1, 1)

        self.retranslateUi(Form)
        QtCore.QMetaObject.connectSlotsByName(Form)

    def retranslateUi(self, Form):
        Form.setWindowTitle(QtWidgets.QApplication.translate("Form", "Form", None, -1))
        self.group_box_directories.setTitle(QtWidgets.QApplication.translate("Form", "Directories", None, -1))
        self.group_box_keywords.setTitle(QtWidgets.QApplication.translate("Form", "Keywords", None, -1))
        self.group_box_ignores.setTitle(QtWidgets.QApplication.translate("Form", "Ignores", None, -1))
        self.button_help.setText(QtWidgets.QApplication.translate("Form", "Help", None, -1))
        self.button_default.setText(QtWidgets.QApplication.translate("Form", "Default", None, -1))
        self.button_execute.setText(QtWidgets.QApplication.translate("Form", "Execute", None, -1))
        self.groupBox.setTitle(QtWidgets.QApplication.translate("Form", "Output", None, -1))
        self.radio_json.setText(QtWidgets.QApplication.translate("Form", "JSON", None, -1))
        self.label_json_file.setText(QtWidgets.QApplication.translate("Form", "File", None, -1))
        self.button_json_file.setText(QtWidgets.QApplication.translate("Form", "Browse", None, -1))
        self.radio_html.setText(QtWidgets.QApplication.translate("Form", "HTML", None, -1))
        self.label_html_file.setText(QtWidgets.QApplication.translate("Form", "File", None, -1))
        self.button_html_file.setText(QtWidgets.QApplication.translate("Form", "Browse", None, -1))
        self.label_html_template.setText(QtWidgets.QApplication.translate("Form", "Template", None, -1))
        self.button_html_template.setText(QtWidgets.QApplication.translate("Form", "Browse", None, -1))
        self.label_html_browser.setText(QtWidgets.QApplication.translate("Form", "Browser", None, -1))
        self.button_html_browser.setText(QtWidgets.QApplication.translate("Form", "Browse", None, -1))
        self.radio_stdio.setText(QtWidgets.QApplication.translate("Form", "Standard IO", None, -1))
        self.label_config.setText(QtWidgets.QApplication.translate("Form", "Config File", None, -1))
        self.button_config.setText(QtWidgets.QApplication.translate("Form", "Open", None, -1))

