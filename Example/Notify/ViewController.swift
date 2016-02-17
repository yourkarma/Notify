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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didDismissNotification", name: "didDismissNotiftyNotification", object: nil)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        //self.presentNotification(Notification(level: .Success, message: "This is a successful test notification"))
        //self.presentNotification(Notification(level: .Error, message: "This is a error test notification"))
        self.presentNotification(Notification(level: .Default, message: "This is a default test notification"), delay: 0, withStatusBar: true)
    }
    
    func didDismissNotification() {
        print("Did the thing")
    }
    
    @IBAction func didTapManualDismissNotification(sender: AnyObject) {
        self.manualDismissNotification()
    }
    
    func manualDismissNotification() {
        NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "HidePresentedNotification", object: nil))
    }

}

