# NOTICE:
#
# Application name defined in TARGET has a corresponding QML filename.
# If name defined in TARGET is changed, the following needs to be done
# to match new name:
#   - corresponding QML filename must be changed
#   - desktop icon filename must be changed
#   - desktop filename must be changed
#   - icon definition filename in desktop file must be changed
#   - translation filenames have to be changed

# The name of your application
TARGET = harbour-batzap

CONFIG += sailfishapp

SOURCES += src/harbour-batzap.cpp \
    src/batzap.cpp \
    src/database.cpp

OTHER_FILES += qml/harbour-batzap.qml \
    qml/cover/CoverPage.qml \
    rpm/harbour-batzap.changes.in \
    rpm/harbour-batzap.spec \
    rpm/harbour-batzap.yaml \
    translations/*.ts \
    harbour-batzap.desktop \
    qml/pages/Login.qml \
    qml/pages/Register.qml \
    qml/pages/Settings.qml \
    qml/pages/js/loader.js \
    qml/pages/ConversationsList.qml \
    qml/pages/ConversationPage.qml \
    qml/pages/conversation/MessagesView.qml \
    qml/pages/conversation/ChatTextInput.qml \
    qml/pages/conversation/MessageDelegate.qml \
    qml/pages/conversation/ContactPresenceIndicator.qml \
    qml/pages/conversation/ConversationDelegate.qml \
    qml/pages/js/utils.js

# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n
TRANSLATIONS += translations/harbour-batzap-de.ts

QT += sql

HEADERS += \
    src/batzap.h \
    src/database.h \
    src/harbour-batzap.h

