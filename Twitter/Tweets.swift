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
    
    init(tweet_dictionary: NSDictionary){
        text = tweet_dictionary["text"] as? String
        retweet_count = (tweet_dictionary["retweet_count"] as? Int) ?? 0
        
        if let user = tweet_dictionary["user"] as? NSDictionary{
            likes_count = (user["favourites_count"] as? Int) ?? 0
        }
        
        if let timestampString = tweet_dictionary["created_at"] as? String{
            let formatter = NSDateFormatter()
            formatter.dateFormat = "EEE MMM d HH:mm:ss Z y"
            timestamp = formatter.dateFromString(timestampString)
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
