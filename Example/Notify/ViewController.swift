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
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.didDismissNotification), name: "didDismissNotiftyNotification", object: nil)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func didDismissNotification() {
        print("It did the thing")
    }
    
    @IBAction func presentSuccessNotification(sender: AnyObject) {
        self.presentNotification(Notification(level: .Success, message: self.notificationBodyTextView.text))
    }
    
    @IBAction func presentErrorNotification(sender: AnyObject) {
        self.presentNotification(Notification(level: .Error, message: self.notificationBodyTextView.text))
    }
    
    @IBAction func presentDefaultNotification(sender: AnyObject) {
        self.presentNotification(Notification(level: .Default, message: self.notificationBodyTextView.text), withStatusBar: true)
    }
    
    
    @IBAction func didTapManualDismissNotification(sender: AnyObject) {
        self.manualDismissNotification()
    }
    
    @IBAction func dismissKeyboard(sender: AnyObject) {
        self.notificationBodyTextView.resignFirstResponder()
    }
    
    func manualDismissNotification() {
        NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "HidePresentedNotification", object: nil))
    }
    
    deinit {
        // make sure to remove observers when they're deallocated
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

}

