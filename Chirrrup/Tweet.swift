//
//  Tweets.swift
//  Twitter
//
//  Created by Satyam Jaiswal on 2/20/16.
//  Copyright © 2016 Satyam Jaiswal. All rights reserved.
//

import UIKit

class Tweet: NSObject {
    var text: String?
    var timestamp: Date?
    var retweet_count: Int = 0
    var likes_count: Int = 0
    var user:User?
    var retweetedBy: String?
    var retweeted: Bool?
    var liked: Bool?
    var tweetId: String?
    var tweetMediaUrl: URL?
    
    init(tweet_dictionary: NSDictionary){
        
        if let retweetedBlock = tweet_dictionary["retweeted_status"] as? NSDictionary{
            
            if let text = retweetedBlock["text"]{
                self.text = text as? String
            }
            
            if let userBlock = retweetedBlock["user"] as? NSDictionary{
                self.user = User(user_dictionary: userBlock)
            }
            
            if let retweetedByUserBlock = tweet_dictionary["user"] as? NSDictionary{
                if let retweetedBy = retweetedByUserBlock["name"] as? String{
                    self.retweetedBy = "\(retweetedBy) Retweeted"
                }
            }
            
            if let retweet_count = retweetedBlock["retweet_count"] as? Int{
                self.retweet_count = retweet_count
            }else{
                print("retweet_count tag not found")
            }
            
            if let favoriteCount = retweetedBlock["favorite_count"] as? Int{
                self.likes_count = favoriteCount
            }else{
                print("favorite_count tag not found")
            }
            
            if let entityBlock = retweetedBlock["entities"]as? NSDictionary{
                if let mediaBlockArray = entityBlock["media"] as? [NSDictionary]{
                    if let mediaUrl = mediaBlockArray[0]["media_url"] as? String{
                        self.tweetMediaUrl = URL(string: mediaUrl)
                    }
                }
            }
        }else{
            
            if let text = tweet_dictionary["text"] as? String{
                self.text = text
            }else{
                print("text tag not found")
            }
            
            if let user = tweet_dictionary["user"] as? NSDictionary{
                self.user = User(user_dictionary: user)
            }else{
                print("user tag not found")
            }
        
            if let retweet_count = tweet_dictionary["retweet_count"] as? Int{
                self.retweet_count = retweet_count
            }else{
                print("retweet_count tag not found")
            }
            
            if let favoriteCount = tweet_dictionary["favorite_count"] as? Int{
                self.likes_count = favoriteCount
            }else{
                print("favorite_count tag not found")
            }
            
            if let entityBlock = tweet_dictionary["entities"]as? NSDictionary{
                if let mediaBlockArray = entityBlock["media"] as? [NSDictionary]{
                    if let mediaUrl = mediaBlockArray[0]["media_url"] as? String{
                        self.tweetMediaUrl = URL(string: mediaUrl)
                    }
                }
            }
        }
        
        if let timestampString = tweet_dictionary["created_at"] as? String{
            let formatter = DateFormatter()
            formatter.dateFormat = "EEE MMM d HH:mm:ss Z y"
            timestamp = formatter.date(from: timestampString)
        }else{
            print("created_at tag not found")
        }
        
        if let retweeted = tweet_dictionary["retweeted"] as? Bool{
            self.retweeted = retweeted
        }else{
            print("retweeted tag not found")
        }
        
        if let liked = tweet_dictionary["favorited"]{
            self.liked = liked as? Bool
        }else{
            print("favorited tag not found")
        }
        
        if let tweetId = tweet_dictionary["id_str"] as? String{
            self.tweetId = tweetId
        }else{
            print("id_str tag not found")
        }
    }
    
    class func arrayOfTweets(_ tweetArray_dictionary: [NSDictionary]) -> [Tweet]{
        var tweets = [Tweet]()
        
        for tweet in tweetArray_dictionary{
            tweets.append(Tweet(tweet_dictionary: tweet))
        }
        
        return tweets
    }
}
