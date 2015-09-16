//
//  TimelineViewController.swift
//  Twitter
//
//  Created by Golak Sarangi on 9/14/15.
//  Copyright (c) 2015 Golak Sarangi. All rights reserved.
//

import UIKit

class TimelineViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var timelineTableView: UITableView!

    var allTweets: [Tweet]?
    var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        self.timelineTableView.dataSource = self
        self.timelineTableView.delegate = self
        Tweet.clearAllTweets()
        
        fetchTweets()
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl.addTarget(self, action: "fetchTweets", forControlEvents: UIControlEvents.ValueChanged)
        self.timelineTableView.addSubview(refreshControl)

    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (allTweets != nil) {
            return allTweets!.count
        } else {
            return 0
        }
    }
    

    func fetchTweets() {
        var params = NSDictionary()
        var since_id = Tweet.getLastSinceId()
        if let since_id = since_id {
            params.setValue(since_id, forKey: "since_id")
        }
        
        TwitterClient.sharedInstance.fetchTweets(nil) {(tweets, error) -> () in
            if (error == nil) {
                self.allTweets = tweets
                self.timelineTableView.reloadData()
            } else {
                println(error)
                println("Could not get the tweets")
            }
            self.refreshControl?.endRefreshing()
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = timelineTableView.dequeueReusableCellWithIdentifier("timeLineCell", forIndexPath: indexPath) as! TimelineTableViewCell
        var tweet = allTweets![indexPath.row] as Tweet
        
        cell.userName.text = tweet.user!.name!
        cell.userScreenName.text = tweet.user!.screenName!
        cell.tweetText.text = tweet.text!
        cell.profileImageView.setImageWithURL(NSURL(string:tweet.user!.profileImageUrl!))
        cell.timeDuration.text = getTimeInterVal(tweet.createdAt!)
        
        cell.tweetId = tweet.tweetId
        return cell
    }
    
    func getTimeInterVal(tweetDate: NSDate) -> String{
        var interval : String?
        var timeDiff = Int(-tweetDate.timeIntervalSinceNow)
        if timeDiff < 10 {
            interval = "now";
        } else if timeDiff < 60{
            interval = "\(timeDiff)s"
        } else if timeDiff < 3600 {
            interval = "\(Int(timeDiff/60))m"
        } else if timeDiff < 86400 {
            interval = "\(Int(timeDiff/3600))h"
        } else {
            interval = "\(Int(timeDiff/86400))d"
        }
        
        return interval!;
    }
    
    @IBAction func signOutUser(sender: UIBarButtonItem) {
        User.currentUser?.logout()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "detailedSegue" {
            var vc = segue.destinationViewController as! TweetDetailedViewController
            var indexPath = timelineTableView.indexPathForCell(sender as! UITableViewCell)
            let tweetObj = allTweets![indexPath!.section] as Tweet
            vc.name = tweetObj.user!.name
            vc.screenName = tweetObj.user!.screenName
            vc.profileImageUrl = tweetObj.user!.profileImageUrl
            vc.tweet = tweetObj.text
            vc.createdDate = tweetObj.createdAtString
            vc.tweetId = tweetObj.tweetId
        } else if (segue.identifier == "timelineReplyPost") {
            var vc = segue.destinationViewController as! NewTweetViewController
            var indexPath = timelineTableView.indexPathForCell(sender as! UITableViewCell)
            let tweetObj = allTweets![indexPath!.section] as Tweet
            vc.inReplyToStatus = tweetObj.tweetId
        }
    }
}


class TimelineTableViewCell: UITableViewCell{
    
    @IBOutlet weak var timeDuration: UILabel!
    @IBOutlet weak var userScreenName: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var tweetText: UILabel!
    var tweetId: String?
    @IBAction func favorite(sender: UIButton) {
        var params = ["id": tweetId!];
        TwitterClient.sharedInstance.favorite(params){(response, error) -> () in
            if (error == nil) {
                println("successfully favorited")
                sender.setBackgroundImage(UIImage(named: "donefav"), forState: UIControlState.Normal)
            } else {
                println(error)
                println("could not favorite it")
            }
        }

    }
    @IBAction func reTweet(sender: UIButton) {
        var params = ["id": tweetId!];
        
        TwitterClient.sharedInstance.reTweet(params){(response, error) -> () in
            if (error == nil) {
                println("retweeted")
            } else {
                println(error)
                println("Could not save the tweets")
            }
        }
    }
}
