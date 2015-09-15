//
//  ViewController.swift
//  Twitter
//
//  Created by Golak Sarangi on 9/14/15.
//  Copyright (c) 2015 Golak Sarangi. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {


    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginToTwitter(sender: UIButton) {

        
        TwitterClient.sharedInstance.loginWithCompletion() {
            (user: User?, error: NSError?) in
            if (user != nil) {
                self.performSegueWithIdentifier("loginSegue", sender: self)
            } else {
                println("Error")
            }
        }
    }


}

