//
//  Tweets.swift
//  Twitter
//
//  Created by Satyam Jaiswal on 2/20/16.
//  Copyright © 2016 Satyam Jaiswal. All rights reserved.
//

import UIKit

class Tweets: NSObject {
    var text: NSString?
    var timestamp: NSDate?
    var retweet_count: Int = 0
    var likes_count: Int = 0
    var profile_image_url: NSURL?
    var username: NSString?
    var user_screenname: NSString?
    var user:User?
    
    init(tweet_dictionary: NSDictionary){
        text = tweet_dictionary["text"] as? String
        retweet_count = (tweet_dictionary["retweet_count"] as? Int) ?? 0
        
        if let user = tweet_dictionary["user"] as? NSDictionary{
            self.user = User(user_dictionary: user)
            likes_count = (user["favourites_count"] as? Int) ?? 0
            if let profile_image_url = user["profile_image_url"] as? String{
                self.profile_image_url = NSURL(string: profile_image_url)
            }
        }
        
        if let timestampString = tweet_dictionary["created_at"] as? String{
            let formatter = NSDateFormatter()
            formatter.dateFormat = "EEE MMM d HH:mm:ss Z y"
            timestamp = formatter.dateFromString(timestampString)
        }
        
        
        
        if let user = tweet_dictionary["user"] as? NSDictionary{
            if let username = user["name"] as? String{
                self.username = username
            }
            
            if let user_screenname = user["screen_name"] as? String{
                self.user_screenname = user_screenname
            }
        }
        
    }
    
    class func arrayOfTweets(tweetArray_dictionary: [NSDictionary]) -> [Tweets]{
        var tweets = [Tweets]()
        
        for tweet in tweetArray_dictionary{
            tweets.append(Tweets(tweet_dictionary: tweet))
        }
        
        return tweets
    }
}
