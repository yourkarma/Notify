import UIKit

public struct Notifier {
    public let presenter: PresenterType

    let themeProvider: ThemeProvider

    public init(themeProvider: ThemeProvider, presenter: PresenterType) {
        self.presenter = presenter
        self.themeProvider = themeProvider
    }

    public init(themeProvider: ThemeProvider) {
        self.init(themeProvider: themeProvider, presenter: Presenter(themeProvider: themeProvider))
    }

    public func notify(notification: Notification, withStatusBar: Bool = false) {
        self.presenter.present(notification, showStatusBar: withStatusBar)
    }
}

public protocol ThemeProvider {
    func iconForNotification(notification: Notification) -> UIImage?
    func labelForNotification(notification: Notification) -> UILabel
    func backgroundColorForNotification(notification: Notification) -> UIColor
    func buttonForNotification(notification: Notification, action: Notification.Action) -> UIButton
}