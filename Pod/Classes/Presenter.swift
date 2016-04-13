import UIKit

struct PresentedNotification {
    let window: UIWindow
    let view: UIView
    let dimView: UIView
    let notification: Notification
    let presenter: Presenter

    let presentedAt: NSTimeInterval
}

public protocol PresenterType {
    func present(notification: Notification, showStatusBar: Bool)
}

public class Presenter: PresenterType {
    
    static var presentedNotification: PresentedNotification? = nil
    static var notificationQueue: [(Notification, Bool)] = []
    
    var dismissAfter: NSTimeInterval?

    let themeProvider: ThemeProvider

    public init(themeProvider: ThemeProvider) {
        self.themeProvider = themeProvider
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(Presenter.hidePresentedNotification), name: "HidePresentedNotification", object: nil)
    }

    public func present(notification: Notification, showStatusBar: Bool = false) {
        if Presenter.presentedNotification == nil {
            self.makeNotificationVisible(notification, statusBarHeight: showStatusBar ? 1 : 0)
        } else {
            Presenter.notificationQueue.append((notification, showStatusBar))
        }
    }

    func makeNotificationVisible(notification: Notification, statusBarHeight: CGFloat = 0) {
        
        let window = self.makeNotificationWindowWithStatusBarHeight(statusBarHeight)
        let view = self.makeNotificationViewForNotification(notification)
        window.addSubview(view)

        let dimView = UIView()
        dimView.backgroundColor = UIColor.blackColor()
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
        Presenter.presentedNotification = PresentedNotification(window: window, view: view, dimView: dimView, notification: notification, presenter: self, presentedAt: NSDate().timeIntervalSinceReferenceDate)

        // Constrain the notification to the top of the view
        let views = ["notification": view, "dim": dimView]
        window.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[notification]|", options: [], metrics: nil, views: views))
        window.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[dim]|", options: [], metrics: nil, views: views))

        let offScreenTopConstraint = NSLayoutConstraint(item: view, attribute: .Bottom, relatedBy: .Equal, toItem: window, attribute: .Top, multiplier: 2.0, constant: 0.0)
        offScreenTopConstraint.identifier = "offScreenTopConstraint"
        window.addConstraint(offScreenTopConstraint)

        let onscreenTopConstraint = NSLayoutConstraint(item: view, attribute: .Top, relatedBy: .Equal, toItem: window, attribute: .Top, multiplier: 2.0, constant: 0.0)
        onscreenTopConstraint.identifier = "onscreenTopConstraint"

        window.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[dim]|", options: [], metrics: nil, views: views))

        window.layoutIfNeeded()

        UIView.animateWithDuration(0.2, animations: {
            window.removeConstraint(offScreenTopConstraint)
            window.addConstraint(onscreenTopConstraint)

            if preventsUserInteraction {
                dimView.alpha = 0.55
            } else {
                dimView.alpha = 0.0
            }

            window.layoutIfNeeded()
        })
        window.hidden = false

        if (!preventsUserInteraction) {
            window.touchCallback = {
                if let presentedAt = Presenter.presentedNotification?.presentedAt {

                    if let timeInterval: NSTimeInterval = self.dismissAfter {
                        let elapsedSeconds = NSDate().timeIntervalSinceReferenceDate - presentedAt
                        let minimumSecondsNotificationShouldBeVisible: NSTimeInterval = timeInterval
                        
                        let waitFor = minimumSecondsNotificationShouldBeVisible - elapsedSeconds
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(waitFor * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
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

            UIView.animateWithDuration(0.2, animations: {
                view.transform = CGAffineTransformMakeTranslation(0.0, -view.frame.height)
                dimView.alpha = 0.0
            }, completion: { _ in
                window.hidden = true
                Presenter.presentedNotification = nil
                NSNotificationCenter.defaultCenter().postNotificationName("didDismissNotiftyNotification", object: nil, userInfo: nil)
                
                if Presenter.notificationQueue.count > 0 {
                    let notification = Presenter.notificationQueue.removeAtIndex(0)
                    self.present(notification.0, showStatusBar: notification.1)
                }
            })
        }
    }

    @objc func notificationTapped(gestureRecognizer: UITapGestureRecognizer) {
        if let actions = Presenter.presentedNotification?.notification.actions {
            if actions.count <= 0 {
                self.hidePresentedNotification()
            }
        }
    }

    func makeNotificationViewForNotification(notification: Notification) -> UIView {
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
            button.addTarget(self, action: #selector(Presenter.handleAction(_:)), forControlEvents: .TouchUpInside)
            button.translatesAutoresizingMaskIntoConstraints = false
        }

        label.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.translatesAutoresizingMaskIntoConstraints = false

        let views = ["icon": imageView, "label": label]

        // Constrain the horizontal axis
        imageView.setContentHuggingPriority(252, forAxis: .Horizontal)
        imageView.setContentHuggingPriority(252, forAxis: .Vertical)
        label.setContentHuggingPriority(251, forAxis: .Horizontal)
        
        let horizontalLabelContraints = shouldShowImage ? "H:|-16-[icon]-16-[label]->=16-|" : "H:|->=16-[label]->=16-|"
        
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(horizontalLabelContraints, options: [], metrics: nil, views: views))
        
        if !shouldShowImage {
            view.addConstraint(NSLayoutConstraint(item: label, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.CenterX, multiplier: 1.0, constant: 0.0))
        }
        

        var previousButton: UIButton? = nil
        for (index, button) in buttons.enumerate() {
            if previousButton == nil {
                view.addConstraint(NSLayoutConstraint(item: button, attribute: .Leading, relatedBy: .Equal, toItem: view, attribute: .Leading, multiplier: 1.0, constant: 5.0))
            } else if index < notification.actions.endIndex {
                view.addConstraint(NSLayoutConstraint(item: button, attribute: .Leading, relatedBy: .Equal, toItem: previousButton, attribute: .Trailing, multiplier: 1.0, constant: 5.0))
                view.addConstraint(NSLayoutConstraint(item: button, attribute: .Baseline, relatedBy: .Equal, toItem: previousButton, attribute: .Baseline, multiplier: 1.0, constant: 0.0))

                let widthConstraint = NSLayoutConstraint(item: button, attribute: .Width, relatedBy: .Equal, toItem: previousButton, attribute: .Width, multiplier: 1.0, constant: previousButton?.frame.width ?? 0.0)
                widthConstraint.priority = UILayoutPriorityDefaultLow
                view.addConstraint(widthConstraint)
            }

            if buttons.last == button {
                view.addConstraint(NSLayoutConstraint(item: view, attribute: .Trailing, relatedBy: .Equal, toItem: button, attribute: .Trailing, multiplier: 1.0, constant: 5.0))
            }

            previousButton = button
        }

        // Constrain the vertical axis
        if let button = buttons.first {
            let viewsWithButton = ["icon": imageView, "label": label, "button": button]
            view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-10-[label]-10-[button]-16-|", options: [], metrics: nil, views: viewsWithButton))
            view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-16-[icon]->=16-|", options: [], metrics: nil, views: viewsWithButton))
        } else {
            let verticalLabelContraints = shouldShowImage ? "V:|-10-[label]-10-|" : "V:|-20-[label]-6-|"
            view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(verticalLabelContraints, options: [], metrics: nil, views: views))
            view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-16-[icon]->=16-|", options: [], metrics: nil, views: views))
        }

        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(Presenter.notificationTapped(_:))))

        return view
    }

    func buttonsForNotification(notification: Notification) -> [UIButton] {
        var buttons: [UIButton] = []
        for (index, action) in notification.actions.enumerate() {
            let button = self.themeProvider.buttonForNotification(notification, action: action)
            button.setTitle(action.title, forState: .Normal)
            button.tag = index
            buttons.append(button)
        }
        return buttons
    }

    @objc func handleAction(sender: UIButton) {
        if let presented = Presenter.presentedNotification {
            let actions = presented.notification.actions
            let action = actions[sender.tag]
            action.handler?(action)

            self.hidePresentedNotification()
        }
    }
    
    func makeNotificationWindowWithStatusBarHeight(height: CGFloat) -> NotificationWindow {
        let screen = UIScreen.mainScreen()
        let window = NotificationWindow(frame: CGRect(x: 0.0, y: 0.0, width: screen.bounds.width, height: screen.bounds.height))
        
        window.windowLevel = UIWindowLevelStatusBar - height
        window.backgroundColor = .clearColor()
        
        // A root view controller is necessary for the window
        // to automatically participate in rotation.
        window.rootViewController = NotifyViewController()
        
        return window
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}