//
//  ViewController.swift
//  Notify
//
//  Created by asowers on 02/10/2016.
//  Copyright (c) 2016 asowers. All rights reserved.
//

import UIKit
import Notify

class ViewController: UIViewController {
    
    @IBOutlet weak var notificationBodyTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.didDismissNotification), name: NSNotification.Name(rawValue: "didDismissNotiftyNotification"), object: nil)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func didDismissNotification() {
        print("It did the thing")
    }
    
    @IBAction func presentSuccessNotification(_ sender: AnyObject) {
        self.presentNotification(NotifyNotification(level: .success, message: self.notificationBodyTextView.text))
    }
    
    @IBAction func presentErrorNotification(_ sender: AnyObject) {
        self.presentNotification(NotifyNotification(level: .error, message: self.notificationBodyTextView.text))
    }
    
    @IBAction func presentDefaultNotification(_ sender: AnyObject) {
        self.presentNotification(NotifyNotification(level: .default, message: self.notificationBodyTextView.text), withStatusBar: true)
    }
    
    
    @IBAction func didTapManualDismissNotification(_ sender: AnyObject) {
        self.manualDismissNotification()
    }
    
    @IBAction func dismissKeyboard(_ sender: AnyObject) {
        self.notificationBodyTextView.resignFirstResponder()
    }
    
    func manualDismissNotification() {
        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "HidePresentedNotification"), object: nil))
    }
    
    deinit {
        // make sure to remove observers when they're deallocated
        NotificationCenter.default.removeObserver(self)
    }

}

