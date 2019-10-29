//
//  STRootViewController.swift
//  SalesforceToday
//
//  Created by Bhavna Gupta on 27/07/15.
//  Copyright (c) 2015 Metacube. All rights reserved.
//

import UIKit

class STRootViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*!
    This action is called when user taps "Logout" bar button item to logout user.
    @param sender -> the event sender
    */
    @IBAction func logout(sender: AnyObject) {
        // Call SFAuthenticationManager to logout user
        SFAuthenticationManager.shared().logout()
    }

}
