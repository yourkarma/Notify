import UIKit

class NotifyViewController: UIViewController {
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIApplication.shared.statusBarStyle
    }

    override var prefersStatusBarHidden : Bool {
        return UIApplication.shared.isStatusBarHidden
    }

    override func loadView() {
        super.loadView()
        self.view = UIView()
        self.view.isHidden = true
    }
}
