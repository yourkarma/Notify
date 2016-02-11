import UIKit

class NotifyViewController: UIViewController {
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIApplication.sharedApplication().statusBarStyle
    }

    override func prefersStatusBarHidden() -> Bool {
        return UIApplication.sharedApplication().statusBarHidden
    }

    override func loadView() {
        super.loadView()
        self.view = UIView()
        self.view.hidden = true
    }
}