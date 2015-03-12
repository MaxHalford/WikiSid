# -*- coding: utf-8 -*-

# Form implementation generated from reading ui file 'GUI.ui'
#
# Created: Sun Mar  1 12:27:01 2015
#      by: PyQt4 UI code generator 4.10.4
#
# WARNING! All changes made in this file will be lost!

from PyQt4 import QtCore, QtGui

try:
    _fromUtf8 = QtCore.QString.fromUtf8
except AttributeError:
    def _fromUtf8(s):
        return s

try:
    _encoding = QtGui.QApplication.UnicodeUTF8
    def _translate(context, text, disambig):
        return QtGui.QApplication.translate(context, text, disambig, _encoding)
except AttributeError:
    def _translate(context, text, disambig):
        return QtGui.QApplication.translate(context, text, disambig)

class Ui_MainWindow(object):
    def setupUi(self, MainWindow):
        MainWindow.setObjectName(_fromUtf8("MainWindow"))
        MainWindow.resize(824, 309)
        MainWindow.setStyleSheet(_fromUtf8("#MainWindow {\n"
"background: gray;\n"
"}\n"
"\n"
"#listWidget {\n"
"border:solid;\n"
"border-color: #aaaaaa #aaaaaa #aaaaaa #aaaaaa;\n"
"border-width: 4px 4px 4px 4px;\n"
"background-color:white;\n"
"}\n"
"\n"
"#lineEdit {\n"
"background: url(search-white.png) no-repeat 10px 6px #fcfcfc;\n"
"    border: 1px solid #d1d1d1;\n"
"    width: 150px;\n"
"    -webkit-border-radius: 20px;\n"
"    -moz-border-radius: 20px;\n"
"    border-radius: 20px;\n"
"    text-shadow: 0 2px 3px rgba(0, 0, 0, 0.1);\n"
"    -webkit-box-shadow: 0 1px 3px rgba(0, 0, 0, 0.15) inset;\n"
"    -moz-box-shadow: 0 1px 3px rgba(0, 0, 0, 0.15) inset;\n"
"    box-shadow: 0 1px 3px rgba(0, 0, 0, 0.15) inset;\n"
"    -webkit-transition: all 0.7s ease 0s;\n"
"    -moz-transition: all 0.7s ease 0s;\n"
"    -o-transition: all 0.7s ease 0s;\n"
"    transition: all 0.7s ease 0s;\n"
"}\n"
"\n"
"#textBrowser {\n"
"border:solid;\n"
"border-color: #aaaaaa #aaaaaa #aaaaaa #aaaaaa;\n"
"border-width: 4px 4px 4px 4px;\n"
"background-color:white;\n"
"}\n"
"\n"
"#pushButton {\n"
"display: inline-block;\n"
"  height: 50px;\n"
"  line-height: 50px;\n"
"  position: relative;\n"
"  background-color:rgb(41,127,184);\n"
"  color:rgb(255,255,255);\n"
"  text-decoration: none;\n"
"  text-transform: uppercase;\n"
"  letter-spacing: 1px;\n"
"  margin-bottom: 15px;\n"
"  \n"
"  \n"
"  border-radius: 5px;\n"
"  -moz-border-radius: 5px;\n"
"  -webkit-border-radius: 5px;\n"
"  text-shadow:0px 1px 0px rgba(0,0,0,0.5);\n"
"}"))
        self.centralwidget = QtGui.QWidget(MainWindow)
        self.centralwidget.setObjectName(_fromUtf8("centralwidget"))
        self.textBrowser = QtGui.QTextBrowser(self.centralwidget)
        self.textBrowser.setGeometry(QtCore.QRect(448, 9, 371, 271))
        self.textBrowser.setFrameShape(QtGui.QFrame.StyledPanel)
        self.textBrowser.setObjectName(_fromUtf8("textBrowser"))
        self.listWidget = QtGui.QListWidget(self.centralwidget)
        self.listWidget.setGeometry(QtCore.QRect(9, 41, 431, 241))
        self.listWidget.setStyleSheet(_fromUtf8(""))
        self.listWidget.setFrameShape(QtGui.QFrame.StyledPanel)
        self.listWidget.setObjectName(_fromUtf8("listWidget"))
        self.pushButton = QtGui.QPushButton(self.centralwidget)
        self.pushButton.setGeometry(QtCore.QRect(320, 10, 121, 41))
        self.pushButton.setObjectName(_fromUtf8("pushButton"))
        self.lineEdit = QtGui.QLineEdit(self.centralwidget)
        self.lineEdit.setGeometry(QtCore.QRect(10, 10, 301, 27))
        self.lineEdit.setObjectName(_fromUtf8("lineEdit"))
        self.gridLayout = QtGui.QGridLayout(self.lineEdit)
        self.gridLayout.setObjectName(_fromUtf8("gridLayout"))
        MainWindow.setCentralWidget(self.centralwidget)
        self.statusbar = QtGui.QStatusBar(MainWindow)
        self.statusbar.setObjectName(_fromUtf8("statusbar"))
        MainWindow.setStatusBar(self.statusbar)

        self.retranslateUi(MainWindow)
        QtCore.QMetaObject.connectSlotsByName(MainWindow)

    def retranslateUi(self, MainWindow):
        MainWindow.setWindowTitle(_translate("MainWindow", "Search Engine", None))
        self.pushButton.setText(_translate("MainWindow", "Search", None))

