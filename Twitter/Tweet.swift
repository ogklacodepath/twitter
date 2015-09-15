//
//  Tweet.swift
//  Twitter
//
//  Created by Golak Sarangi on 9/14/15.
//  Copyright (c) 2015 Golak Sarangi. All rights reserved.
//

import UIKit

var last_since_id : String?

var tweets = [Tweet]()
class Tweet: NSObject{
    var user: User?
    var text: String?
    var createdAtString: String?
    var createdAt: NSDate?
    var id: String?
    
    init(dictionary: NSDictionary) {
        user = User(dictionary: dictionary["user"] as! NSDictionary)
        text = dictionary["text"] as? String
        createdAtString = dictionary["created_at"] as? String
        id = dictionary["id"] as? String
        
        var formatter = NSDateFormatter()
        formatter.dateFormat = "EEE MMM d HH:mm:ss Z y"
        createdAt = formatter.dateFromString(createdAtString!)
    }
    
    class func tweetsWithArray(array: [NSDictionary]) -> [Tweet] {

        var maxDate: NSDate?
        
        for dictionary in array {
            var tweet = Tweet(dictionary: dictionary as NSDictionary)
            if maxDate == nil {
                maxDate = tweet.createdAt
            } else {
                if (maxDate!.timeIntervalSinceNow < tweet.createdAt!.timeIntervalSinceNow) {
                    maxDate = tweet.createdAt
                    last_since_id = tweet.id
                }
            }
            tweets.append(tweet)
        }
        return tweets
    }
    
    class func clearAllTweets() {
        last_since_id = nil
        tweets = [Tweet]()
    }
    
    class func getLastSinceId() -> String? {
        return last_since_id
    }
}
