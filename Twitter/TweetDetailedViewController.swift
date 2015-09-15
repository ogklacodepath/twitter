//
//  TweetDetailedViewController.swift
//  Twitter
//
//  Created by Golak Sarangi on 9/15/15.
//  Copyright (c) 2015 Golak Sarangi. All rights reserved.
//

import UIKit

class TweetDetailedViewController: UIViewController {

    @IBOutlet weak var tweetLabel: UILabel!
    @IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    
    
    var name : String?
    var screenName : String?
    var profileImageUrl : String?
    var createdDate : String?
    var tweet : String?
    var tweetId : String?
    
    override func viewDidLoad() {
        tweetLabel.text = tweet
        screenNameLabel.text = screenName
        nameLabel.text = name
        profileImageView.setImageWithURL(NSURL(string: profileImageUrl!))
        dateLabel.text = createdDate
    }
    
    @IBAction func reply(sender: UIButton) {
        
    }
    
    @IBAction func retweet(sender: UIButton) {
        var params = ["id": tweetId!];
        var url = "statuses/retweet/\(tweetId!).json"
        TwitterClient.sharedInstance.POST(url, parameters: nil, success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
            println("retweeted")
            }, failure: {
                (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                println(error)
                println("Could not save the tweets")
                
        })
    }
    
    @IBAction func favorite(sender: UIButton) {
        var params = ["id": tweetId!];
        var url = "/1.1/favorites/create.json"
        TwitterClient.sharedInstance.POST(url, parameters: params, success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
            sender.setBackgroundImage(UIImage(named: "donefav"), forState: UIControlState.Normal)
            }, failure: {
                (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                println(error)
                println("could not favorite it")
                
        })
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "inReplyTo" {
            var vc = segue.destinationViewController as! NewTweetViewController
            vc.inReplyToStatus = tweetId
        }
    }
    
}
