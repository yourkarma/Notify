import UIKit

struct PresentedNotification {
    let window: UIWindow
    let view: UIView
    let dimView: UIView
    let notification: NotifyNotification
    let presenter: Presenter

    let presentedAt: TimeInterval
}

public protocol PresenterType {
    func present(_ notification: NotifyNotification, showStatusBar: Bool)
}

open class Presenter: PresenterType {
    
    static var presentedNotification: PresentedNotification? = nil
    static var notificationQueue: [(NotifyNotification, Bool)] = []
    
    var dismissAfter: TimeInterval?

    let themeProvider: ThemeProvider

    public init(themeProvider: ThemeProvider) {
        self.themeProvider = themeProvider
        NotificationCenter.default.addObserver(self, selector: #selector(Presenter.hidePresentedNotification), name: NSNotification.Name(rawValue: "HidePresentedNotification"), object: nil)
    }

    open func present(_ notification: NotifyNotification, showStatusBar: Bool = false) {
        if Presenter.presentedNotification == nil {
            self.makeNotificationVisible(notification, statusBarHeight: showStatusBar ? 1 : 0)
        } else {
            Presenter.notificationQueue.append((notification, showStatusBar))
        }
    }

    func makeNotificationVisible(_ notification: NotifyNotification, statusBarHeight: CGFloat = 0) {
        
        let window = self.makeNotificationWindowWithStatusBarHeight(statusBarHeight)
        let view = self.makeNotificationViewForNotification(notification)
        window.addSubview(view)

        let dimView = UIView()
        dimView.backgroundColor = UIColor.black
        dimView.alpha = 0.0
        dimView.translatesAutoresizingMaskIntoConstraints = false
        window.insertSubview(dimView, belowSubview: view)

        let preventsUserInteraction = notification.actions.count > 0
        // This serves several purposes:
        // 1) It is used to ensure we're never showing more than one notification;
        // 2) It keeps a reference to the window to prevent it from being deallocated.
        // 3) When the presented notification is changed,
        // the window is deallocated and thus not visible anymore.
        // In other words, if for some reason the cleanup logic fails, this ensures we still only
        // ever have one window visible.
        Presenter.presentedNotification = PresentedNotification(window: window, view: view, dimView: dimView, notification: notification, presenter: self, presentedAt: Date().timeIntervalSinceReferenceDate)

        // Constrain the notification to the top of the view
        let views = ["notification": view, "dim": dimView]
        window.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|[notification]|", options: [], metrics: nil, views: views))
        window.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|[dim]|", options: [], metrics: nil, views: views))

        let offScreenTopConstraint = NSLayoutConstraint(item: view, attribute: .bottom, relatedBy: .equal, toItem: window, attribute: .top, multiplier: 2.0, constant: 0.0)
        offScreenTopConstraint.identifier = "offScreenTopConstraint"
        window.addConstraint(offScreenTopConstraint)

        let onscreenTopConstraint = NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal, toItem: window, attribute: .top, multiplier: 2.0, constant: 0.0)
        onscreenTopConstraint.identifier = "onscreenTopConstraint"

        window.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[dim]|", options: [], metrics: nil, views: views))

        window.layoutIfNeeded()

        UIView.animate(withDuration: 0.2, animations: {
            window.removeConstraint(offScreenTopConstraint)
            window.addConstraint(onscreenTopConstraint)

            if preventsUserInteraction {
                dimView.alpha = 0.55
            } else {
                dimView.alpha = 0.0
            }

            window.layoutIfNeeded()
        })
        window.isHidden = false

        if (!preventsUserInteraction) {
            window.touchCallback = {
                if let presentedAt = Presenter.presentedNotification?.presentedAt {

                    if let timeInterval: TimeInterval = self.dismissAfter {
                        let elapsedSeconds = Date().timeIntervalSinceReferenceDate - presentedAt
                        let minimumSecondsNotificationShouldBeVisible: TimeInterval = timeInterval
                        
                        let waitFor = minimumSecondsNotificationShouldBeVisible - elapsedSeconds
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(waitFor * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
                            self.hidePresentedNotification()
                        }
                    }

                    // There are cases where the NotificationWindow touchCallback is called multiple times for the same
                    // touch. This prevents us from accidentally dismissing the notificatino more than once.
                    window.touchCallback = nil
                }
            }
        }
    }

    @objc func hidePresentedNotification() {
        if let presentedNotification = Presenter.presentedNotification {
            let view = presentedNotification.view
            let window = presentedNotification.window
            let dimView = presentedNotification.dimView

            UIView.animate(withDuration: 0.2, animations: {
                view.transform = CGAffineTransform(translationX: 0.0, y: -view.frame.height)
                dimView.alpha = 0.0
            }, completion: { _ in
                window.isHidden = true
                Presenter.presentedNotification = nil
                NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: "didDismissNotiftyNotification"), object: nil, userInfo: nil)
                
                if Presenter.notificationQueue.count > 0 {
                    let notification = Presenter.notificationQueue.remove(at: 0)
                    self.present(notification.0, showStatusBar: notification.1)
                }
            })
        }
    }

    @objc func notificationTapped(_ gestureRecognizer: UITapGestureRecognizer) {
        if let actions = Presenter.presentedNotification?.notification.actions {
            if actions.count <= 0 {
                self.hidePresentedNotification()
            }
        }
    }

    func makeNotificationViewForNotification(_ notification: NotifyNotification) -> UIView {
        let view = UIView()

        view.backgroundColor = self.themeProvider.backgroundColorForNotification(notification)

        let imageView = UIImageView()
        
        imageView.image = self.themeProvider.iconForNotification(notification)
        
        var shouldShowImage = false
        
        if let _ :UIImage = imageView.image {
            shouldShowImage = true
        }
        
        view.addSubview(imageView)

        let label = self.themeProvider.labelForNotification(notification)
        label.text = notification.message
        label.numberOfLines = 0
        view.addSubview(label)

        let buttons = self.buttonsForNotification(notification)
        buttons.forEach { (button) -> () in
            view.addSubview(button)
            button.contentEdgeInsets = UIEdgeInsets(top: 0.0, left: 12.0, bottom: 0.0, right: 12.0)
            button.addTarget(self, action: #selector(Presenter.handleAction(_:)), for: .touchUpInside)
            button.translatesAutoresizingMaskIntoConstraints = false
        }

        label.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.translatesAutoresizingMaskIntoConstraints = false

        let views = ["icon": imageView, "label": label]

        // Constrain the horizontal axis
        imageView.setContentHuggingPriority(252, for: .horizontal)
        imageView.setContentHuggingPriority(252, for: .vertical)
        label.setContentHuggingPriority(251, for: .horizontal)
        
        let horizontalLabelContraints = shouldShowImage ? "H:|-16-[icon]-16-[label]->=16-|" : "H:|->=16-[label]->=16-|"
        
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: horizontalLabelContraints, options: [], metrics: nil, views: views))
        
        if !shouldShowImage {
            view.addConstraint(NSLayoutConstraint(item: label, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.centerX, multiplier: 1.0, constant: 0.0))
        }
        

        var previousButton: UIButton? = nil
        for (index, button) in buttons.enumerated() {
            if previousButton == nil {
                view.addConstraint(NSLayoutConstraint(item: button, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1.0, constant: 5.0))
            } else if index < notification.actions.endIndex {
                view.addConstraint(NSLayoutConstraint(item: button, attribute: .leading, relatedBy: .equal, toItem: previousButton, attribute: .trailing, multiplier: 1.0, constant: 5.0))
                view.addConstraint(NSLayoutConstraint(item: button, attribute: .lastBaseline, relatedBy: .equal, toItem: previousButton, attribute: .lastBaseline, multiplier: 1.0, constant: 0.0))

                let widthConstraint = NSLayoutConstraint(item: button, attribute: .width, relatedBy: .equal, toItem: previousButton, attribute: .width, multiplier: 1.0, constant: previousButton?.frame.width ?? 0.0)
                widthConstraint.priority = UILayoutPriorityDefaultLow
                view.addConstraint(widthConstraint)
            }

            if buttons.last == button {
                view.addConstraint(NSLayoutConstraint(item: view, attribute: .trailing, relatedBy: .equal, toItem: button, attribute: .trailing, multiplier: 1.0, constant: 5.0))
            }

            previousButton = button
        }

        // Constrain the vertical axis
        if let button = buttons.first {
            let viewsWithButton = ["icon": imageView, "label": label, "button": button]
            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[label]-10-[button]-16-|", options: [], metrics: nil, views: viewsWithButton))
            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-16-[icon]->=16-|", options: [], metrics: nil, views: viewsWithButton))
        } else {
            let verticalLabelContraints = shouldShowImage ? "V:|-10-[label]-10-|" : "V:|-20-[label]-6-|"
            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: verticalLabelContraints, options: [], metrics: nil, views: views))
            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-16-[icon]->=16-|", options: [], metrics: nil, views: views))
        }

        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(Presenter.notificationTapped(_:))))

        return view
    }

    func buttonsForNotification(_ notification: NotifyNotification) -> [UIButton] {
        var buttons: [UIButton] = []
        for (index, action) in notification.actions.enumerated() {
            let button = self.themeProvider.buttonForNotification(notification, action: action)
            button.setTitle(action.title, for: UIControlState())
            button.tag = index
            buttons.append(button)
        }
        return buttons
    }

    @objc func handleAction(_ sender: UIButton) {
        if let presented = Presenter.presentedNotification {
            let actions = presented.notification.actions
            let action = actions[sender.tag]
            action.handler?(action)

            self.hidePresentedNotification()
        }
    }
    
    func makeNotificationWindowWithStatusBarHeight(_ height: CGFloat) -> NotificationWindow {
        let screen = UIScreen.main
        let window = NotificationWindow(frame: CGRect(x: 0.0, y: 0.0, width: screen.bounds.width, height: screen.bounds.height))
        
        window.windowLevel = UIWindowLevelStatusBar - height
        window.backgroundColor = .clear
        
        // A root view controller is necessary for the window
        // to automatically participate in rotation.
        window.rootViewController = NotifyViewController()
        
        return window
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
