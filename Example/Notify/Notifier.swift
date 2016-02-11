//
//  Notifier.swift
//  Notify
//
//  Created by Andrew Sowers on 2/10/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Notify

func notify(notification: Notification) {
    Notifier(themeProvider: NotifyThemeProvider()).notify(notification)
}

class NotifyThemeProvider: Notify.ThemeProvider {
    func iconForNotification(notification: Notification) -> UIImage {
        switch notification.level {
        case .Success: return UIImage(named: "notification-icon-success")!
        case .Error: return UIImage(named: "notification-icon-error")!
        }
    }
    
    func labelForNotification(notification: Notification) -> UILabel {
        let label = UILabel()
        label.font = UIFont(name: "Helveltica-Neue", size: 17.0)
        label.textColor = .whiteColor()
        return label
    }
    
    func backgroundColorForNotification(notification: Notification) -> UIColor {
        switch notification.level {
        case .Success: return Color.Green
        case .Error: return Color.Red
        }
    }
    
    func buttonForNotification(notification: Notification, action: Notification.Action) -> UIButton {
        let button = UIButton()
        button.layer.cornerRadius = 4.0
        button.layer.borderColor = UIColor.clearColor().CGColor
        button.layer.borderWidth = 1.0
        button.layer.masksToBounds = true
        button.adjustsImageWhenHighlighted = true
        button.titleLabel?.font = UIFont(name: "Helveltica-Neue", size: 17.0)
        button.addConstraint(NSLayoutConstraint(item: button, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 36.0))
        button.setBackgroundImage(imageWithSolidColor(Color.RedDarkened), forState: .Normal)
        return button
    }
}

public protocol NotifierType {
    func notify(notification: Notification, delay: NSTimeInterval?)
}
extension Notifier: NotifierType {
    public func notify(notification: Notification, delay: NSTimeInterval? = nil) {
        if let delay = delay {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
                Notify_Example.notify(notification)
            }
        } else {
            Notify_Example.notify(notification)
        }
    }
}

private let notifierPropertyKey = malloc(4)
extension UIViewController {
    public var notifier: NotifierType {
        get {
            if let notifier = objc_getAssociatedObject(self, notifierPropertyKey) as? NotifierType {
                return notifier
            } else {
                let notifier = Notifier(themeProvider: NotifyThemeProvider())
                self.notifier = notifier
                return notifier
            }
        }
        set {
            objc_setAssociatedObject(self, notifierPropertyKey, newValue as? AnyObject, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    func presentNotification(notification: Notification, delay: NSTimeInterval? = nil) {
        self.notifier.notify(notification, delay: delay)
    }
}