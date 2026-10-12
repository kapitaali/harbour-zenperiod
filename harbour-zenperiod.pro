TARGET = harbour-zenperiod
CONFIG += sailfishapp sailfishapp_i18n c++11
QT += qml quick sql dbus

SOURCES += src/harbour-zenperiod.cpp \
           src/cyclestore.cpp

HEADERS += src/cyclestore.h

DISTFILES += qml/harbour-zenperiod.qml \
             qml/cover/CoverPage.qml \
             qml/pages/MainPage.qml \
             qml/pages/OnboardingPage.qml \
             qml/pages/LogPage.qml \
             qml/pages/HistoryPage.qml \
             qml/pages/SettingsPage.qml \
             qml/backend/cycle.js \
             rpm/harbour-zenperiod.spec \
             rpm/harbour-zenperiod.changes \
             rpm/harbour-zenperiod.changes.run \
             harbour-zenperiod.desktop \
             translations/*.ts

SAILFISHAPP_ICONS = 86x86 108x108 128x128 172x172

TRANSLATIONS += translations/harbour-zenperiod-de.ts
