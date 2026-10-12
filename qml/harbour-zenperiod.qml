import QtQuick 2.6
import Sailfish.Silica 1.0
import "pages"
import "cover"

ApplicationWindow {
    id: app

    property Component mainPage: Component { MainPage {} }
    property Component onboardingPage: Component { OnboardingPage {} }

    initialPage: store.isOnboarded() ? mainPage : onboardingPage
    cover: Component { CoverPage { appWindow: app } }
    allowedOrientations: defaultAllowedOrientations
}
