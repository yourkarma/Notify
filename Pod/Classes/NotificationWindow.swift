import UIKit

class NotificationWindow: UIWindow {

    var touchCallback: (() -> ())? = nil

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)

        self.touchCallback?()

        if view != self {
            return view
        } else {
            return nil
        }
    }
}
