//
//  NewTweetViewController.swift
//  Twitter
//
//  Created by Golak Sarangi on 9/15/15.
//  Copyright (c) 2015 Golak Sarangi. All rights reserved.
//

import UIKit

class NewTweetViewController: UIViewController {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!

    
    @IBOutlet weak var newTweetField: UITextView!
    override func viewDidLoad() {
        nameLabel.text = User.currentUser!.name
        screenNameLabel.text = User.currentUser!.screenName
        profileImageView.setImageWithURL(NSURL(string: User.currentUser!.profileImageUrl!))
        newTweetField.becomeFirstResponder()
    }
    @IBAction func PostNewTweet(sender: UIBarButtonItem) {
        var params = ["status": newTweetField.text];
        TwitterClient.sharedInstance.POST("1.1/statuses/update.json", parameters: params, success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
                self.performSegueWithIdentifier("afterPost", sender: self)
            }, failure: {
                (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                println(error)
                println("Could not save the tweets")
                
        })
    }
}
