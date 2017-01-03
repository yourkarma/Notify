//
//  Notifier.swift
//  Notify
//
//  Created by Andrew Sowers on 2/10/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Notify

func notify(_ notification: NotifyNotification, withStatusBar: Bool = false) {
    Notifier(themeProvider: NotifyThemeProvider()).notify(notification, withStatusBar: withStatusBar)
}

class NotifyThemeProvider: Notify.ThemeProvider {
    func iconForNotification(_ notification: NotifyNotification) -> UIImage? {
        switch notification.level {
        case .success: return UIImage(named: "notification-icon-success")!
        case .error: return UIImage(named: "notification-icon-error")!
        case .default: return nil
        }
    }
    
    func labelForNotification(_ notification: NotifyNotification) -> UILabel {

        switch notification.level {
        case .success:
            let label = UILabel()
            label.font = UIFont(name: "HelveticaNeue", size: 17.0)
            label.textColor = .white
            return label
        case .error:
            let label = UILabel()
            label.font = UIFont(name: "HelveticaNeue", size: 17.0)
            label.textColor = .white
            return label
        
        case .default: // example of iPhone style notification banner
            let label = UILabel()
            label.font = UIFont(name: "HelveticaNeue", size: 12.0)
            label.textColor = .white
            
            let pulseAnimation = CABasicAnimation(keyPath: "opacity")
            pulseAnimation.duration = 2
            pulseAnimation.fromValue = 0.2
            pulseAnimation.toValue = 1
            pulseAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            pulseAnimation.autoreverses = true
            pulseAnimation.repeatCount = FLT_MAX
            label.layer.add(pulseAnimation, forKey: nil)
            return label
        }
        
    }
    
    func backgroundColorForNotification(_ notification: NotifyNotification) -> UIColor {
        switch notification.level {
        case .success: return Color.Green
        case .error: return Color.Red
        case .default: return Color.Blue
        }
    }
    
    func buttonForNotification(_ notification: NotifyNotification, action: NotifyNotification.Action) -> UIButton {
        let button = UIButton()
        button.layer.cornerRadius = 4.0
        button.layer.borderColor = UIColor.clear.cgColor
        button.layer.borderWidth = 1.0
        button.layer.masksToBounds = true
        button.adjustsImageWhenHighlighted = true
        button.titleLabel?.font = UIFont(name: "HelveticaNeue", size: 12.0)
        button.addConstraint(NSLayoutConstraint(item: button, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 36.0))
        button.setBackgroundImage(imageWithSolidColor(Color.RedDarkened), for: .normal)
        return button
    }
}

public protocol NotifierType {
    func notify(_ notification: NotifyNotification, delay: TimeInterval?)
    func notifyWithStatusBar(_ notification: NotifyNotification,  delay: TimeInterval?, withStatusBar: Bool)
}

extension Notifier: NotifierType {
    public func notify(_ notification: NotifyNotification, delay: TimeInterval? = nil) {
        if let delay = delay {
			DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
				Notify_Example.notify(notification, withStatusBar: false)
			}
        } else {
            Notify_Example.notify(notification, withStatusBar: false)
        }
    }
    
    public func notifyWithStatusBar(_ notification: NotifyNotification,  delay: TimeInterval? = nil, withStatusBar: Bool = false) {
        if let delay = delay {
			DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
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
            objc_setAssociatedObject(self, notifierPropertyKey, newValue as AnyObject, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    func presentNotification(_ notification: NotifyNotification, delay: TimeInterval? = nil, withStatusBar: Bool = false) {
        self.notifier.notifyWithStatusBar(notification, delay: delay, withStatusBar: withStatusBar)
    }
}
