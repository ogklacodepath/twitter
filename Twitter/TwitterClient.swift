//
//  TwitterClient.swift
//  Twitter
//
//  Created by Golak Sarangi on 9/14/15.
//  Copyright (c) 2015 Golak Sarangi. All rights reserved.
//

let consumerkey = "VXUBTXqBuiue8XKr3gvboOLe3"
let consumerSecret = "mDXhLH94TkbmL5Jl5yUe129d6aicG36XnHc5Pp8qbo2UwVFd2e"
let baseUrl = "https://api.twitter.com"
class TwitterClient: BDBOAuth1RequestOperationManager {
    
    var loginCompletion :((user: User?, error: NSError?) ->())?
    
    class var sharedInstance: TwitterClient {
        struct Static {
            static let instance = TwitterClient(baseURL: NSURL(string: baseUrl), consumerKey: consumerkey, consumerSecret: consumerSecret)
        }
        return Static.instance
    }
    
    
    func loginWithCompletion (completion: (user: User?, error: NSError?) ->()){
        loginCompletion = completion
        
        TwitterClient.sharedInstance.requestSerializer.removeAccessToken()
        TwitterClient.sharedInstance.fetchRequestTokenWithPath("/oauth/request_token", method: "GET", callbackURL: NSURL(string: "ogklatwitter://oauth"), scope: nil,
            success: {
                (requestToken: BDBOAuth1Credential!) -> Void in
                println("got the requestToken")
                
                var authUrl = NSURL(string: "https://api.twitter.com/oauth/authorize?oauth_token=\(requestToken.token)")
                UIApplication.sharedApplication().openURL(authUrl!)
            }) { (error: NSError!) -> Void in
                println("Failed")
                self.loginCompletion?(user: nil, error: error)
        }
    }
    
    func openURL (url: NSURL) {
        TwitterClient.sharedInstance.fetchAccessTokenWithPath("oauth/access_token", method: "POST", requestToken: BDBOAuth1Credential(queryString: url.query),
            success: {
                (accessToken: BDBOAuth1Credential!) -> Void in
                println("got the access token")
                TwitterClient.sharedInstance.requestSerializer.saveAccessToken(accessToken)
                
                TwitterClient.sharedInstance.GET("1.1/account/verify_credentials.json", parameters: nil, success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
                    println("It verified")
                    println("user \(response)")
                    var loggedInUser = User(dictionary: response as! NSDictionary)
                    User.currentUser = loggedInUser
                    self.loginCompletion?(user: loggedInUser, error: nil)
                    }, failure: {
                        (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                        println("Could not get the user")
                        self.loginCompletion?(user: nil, error: error)
                })
                
            }) { (error: NSError!) -> Void in
                self.loginCompletion?(user: nil, error: error)
        }

    }
    func fetchTweets(params: NSDictionary?, completion: (tweets: [Tweet]?, error: NSError?) -> ()) {
        TwitterClient.sharedInstance.GET("1.1/statuses/home_timeline.json", parameters: params, success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
            var allTweets = Tweet.tweetsWithArray(response as! [NSDictionary])
                completion(tweets: allTweets, error: nil)
            }, failure: {
                (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                println(error)
                println("Could not get the tweets")
                completion(tweets: nil, error: error)
                
        })
    }
    
    func postNewTweet(params: NSDictionary?, completion: (response: AnyObject?, error: NSError?) ->()) {
        TwitterClient.sharedInstance.POST("1.1/statuses/update.json", parameters: params, success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
                completion(response: response, error: nil)
            }, failure: {
                (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                println(error)
                println("Could not save the tweets")
                completion(response: nil, error: error)
                
        })
    }
    
    
    func reTweet(params: NSDictionary?, completion: (response: AnyObject?, error: NSError?) ->()) {
        var tweetId = params!["id"] as! String
        var url = "/1.1/statuses/retweet/\(tweetId).json"
        TwitterClient.sharedInstance.POST(url, parameters: params, success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
            println("successfully retweeted")
                completion(response: response, error: nil)
            }, failure: {
                (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                completion(response: nil, error: error)
                
        })
    }
    
    func favorite(params: NSDictionary?, completion: (response: AnyObject?, error: NSError?) ->()){
        TwitterClient.sharedInstance.POST("/1.1/favorites/create.json", parameters: params, success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
                completion(response: response, error: nil)
            }, failure: {
                (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                completion(response: nil, error: error)
                
        })
    }
    
}
