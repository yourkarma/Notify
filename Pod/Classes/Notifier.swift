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

    public func notify(_ notification: NotifyNotification, withStatusBar: Bool = false) {
        self.presenter.present(notification, showStatusBar: withStatusBar)
    }
}

public protocol ThemeProvider {
    func iconForNotification(_ notification: NotifyNotification) -> UIImage?
    func labelForNotification(_ notification: NotifyNotification) -> UILabel
    func backgroundColorForNotification(_ notification: NotifyNotification) -> UIColor
    func buttonForNotification(_ notification: NotifyNotification, action: NotifyNotification.Action) -> UIButton
}
