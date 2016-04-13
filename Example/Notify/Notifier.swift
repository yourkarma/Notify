//
//  Notifier.swift
//  Notify
//
//  Created by Andrew Sowers on 2/10/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Notify

func notify(notification: Notification, withStatusBar: Bool = false) {
    Notifier(themeProvider: NotifyThemeProvider()).notify(notification, withStatusBar: withStatusBar)
}

class NotifyThemeProvider: Notify.ThemeProvider {
    func iconForNotification(notification: Notification) -> UIImage? {
        switch notification.level {
        case .Success: return UIImage(named: "notification-icon-success")!
        case .Error: return UIImage(named: "notification-icon-error")!
        case .Default: return nil
        }
    }
    
    func labelForNotification(notification: Notification) -> UILabel {

        switch notification.level {
        case .Success:
            let label = UILabel()
            label.font = UIFont(name: "HelveticaNeue", size: 17.0)
            label.textColor = .whiteColor()
            return label
        case .Error:
            let label = UILabel()
            label.font = UIFont(name: "HelveticaNeue", size: 17.0)
            label.textColor = .whiteColor()
            return label
        
        case .Default: // example of iPhone style notification banner
            let label = UILabel()
            label.font = UIFont(name: "HelveticaNeue", size: 12.0)
            label.textColor = .whiteColor()
            
            let pulseAnimation = CABasicAnimation(keyPath: "opacity")
            pulseAnimation.duration = 2
            pulseAnimation.fromValue = 0.2
            pulseAnimation.toValue = 1
            pulseAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            pulseAnimation.autoreverses = true
            pulseAnimation.repeatCount = FLT_MAX
            label.layer.addAnimation(pulseAnimation, forKey: nil)
            return label
        }
        
    }
    
    func backgroundColorForNotification(notification: Notification) -> UIColor {
        switch notification.level {
        case .Success: return Color.Green
        case .Error: return Color.Red
        case .Default: return Color.Blue
        }
    }
    
    func buttonForNotification(notification: Notification, action: Notification.Action) -> UIButton {
        let button = UIButton()
        button.layer.cornerRadius = 4.0
        button.layer.borderColor = UIColor.clearColor().CGColor
        button.layer.borderWidth = 1.0
        button.layer.masksToBounds = true
        button.adjustsImageWhenHighlighted = true
        button.titleLabel?.font = UIFont(name: "HelveticaNeue", size: 12.0)
        button.addConstraint(NSLayoutConstraint(item: button, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 36.0))
        button.setBackgroundImage(imageWithSolidColor(Color.RedDarkened), forState: .Normal)
        return button
    }
}

public protocol NotifierType {
    func notify(notification: Notification, delay: NSTimeInterval?)
    func notifyWithStatusBar(notification: Notification,  delay: NSTimeInterval?, withStatusBar: Bool)
}

extension Notifier: NotifierType {
    public func notify(notification: Notification, delay: NSTimeInterval? = nil) {
        if let delay = delay {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
                Notify_Example.notify(notification, withStatusBar: false)
            }
        } else {
            Notify_Example.notify(notification, withStatusBar: false)
        }
    }
    
    public func notifyWithStatusBar(notification: Notification,  delay: NSTimeInterval? = nil, withStatusBar: Bool = false) {
        if let delay = delay {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
                Notify_Example.notify(notification, withStatusBar: withStatusBar)
            }
        } else {
            Notify_Example.notify(notification, withStatusBar: withStatusBar)
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
    
    func presentNotification(notification: Notification, delay: NSTimeInterval? = nil, withStatusBar: Bool = false) {
        self.notifier.notifyWithStatusBar(notification, delay: delay, withStatusBar: withStatusBar)
    }
}