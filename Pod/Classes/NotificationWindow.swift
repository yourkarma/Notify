import UIKit

class NotificationWindow: UIWindow {

    var touchCallback: (() -> ())? = nil

    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, withEvent: event)

        self.touchCallback?()

        if view != self {
            return view
        } else {
            return nil
        }
    }
}