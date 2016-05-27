//
//  Tweets.swift
//  Twitter
//
//  Created by Satyam Jaiswal on 2/20/16.
//  Copyright © 2016 Satyam Jaiswal. All rights reserved.
//

import UIKit

class Tweet: NSObject {
    var text: NSString?
    var timestamp: NSDate?
    var retweet_count: Int = 0
    var likes_count: Int = 0
    var profile_image_url: NSURL?
    var username: NSString?
    var user_screenname: NSString?
    var user:User?
    var retweetedBy: NSString?
    var retweeted: Bool?
    var liked: Bool?
    var tweetId: NSString?
    var tweetMediaUrl: NSURL?
    
    init(tweet_dictionary: NSDictionary){
        
        if let retweetedBlock = tweet_dictionary["retweeted_status"] as? NSDictionary{
            
            if let text = retweetedBlock["text"]{
                self.text = text as? String
            }else{
                print("text tag not found")
            }
            
            if let userBlock = retweetedBlock["user"] as? NSDictionary{
                self.user = User(user_dictionary: userBlock)
                
                if let profile_image_url = userBlock["profile_image_url"] as? String{
                    self.profile_image_url = NSURL(string: profile_image_url)
                }else{
                    print("profile_image_url tag not found")
                }
                
                if let username = userBlock["name"] as? String{
                    self.username = username
                }else{
                    print("name tag not found")
                }
                
                if let user_screenname = userBlock["screen_name"] as? String{
                    self.user_screenname = user_screenname
                }else{
                    print("screen_name tag not found")
                }
            }
            
            if let retweetedByUserBlock = tweet_dictionary["user"] as? NSDictionary{
                if let retweetedBy = retweetedByUserBlock["name"] as? String{
                    self.retweetedBy = "\(retweetedBy) Retweeted"
                }
            }
        }else{
            
            if let text = tweet_dictionary["text"]{
                self.text = text as? String
            }else{
                print("text tag not found")
            }
            
            if let user = tweet_dictionary["user"] as? NSDictionary{
                self.user = User(user_dictionary: user)
                
                if let profile_image_url = user["profile_image_url"] as? String{
                    self.profile_image_url = NSURL(string: profile_image_url)
                }else{
                    print("profile_image_url tag not found")
                }
                
                if let username = user["name"] as? String{
                    self.username = username
                }else{
                    print("name tag not found")
                }
                
                if let user_screenname = user["screen_name"] as? String{
                    self.user_screenname = user_screenname
                }else{
                    print("screen_name tag not found")
                }
                
            }else{
                print("user tag not found")
            }
        }
        
        if let retweet_count = tweet_dictionary["retweet_count"] as? Int{
            self.retweet_count = retweet_count
        }else{
            print("retweet_count tag not found")
        }
        
        if let timestampString = tweet_dictionary["created_at"] as? String{
            let formatter = NSDateFormatter()
            formatter.dateFormat = "EEE MMM d HH:mm:ss Z y"
            timestamp = formatter.dateFromString(timestampString)
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
        
        if let favoriteCount = tweet_dictionary["favorite_count"] as? Int{
            self.likes_count = favoriteCount
        }else{
            print("favorite_count tag not found")
        }
        
        if let tweetId = tweet_dictionary["id_str"]{
            self.tweetId = tweetId as! String
        }else{
            print("id_str tag not found")
        }
        
        if let entityBlock = tweet_dictionary["entities"]as? NSDictionary{
            if let mediaBlockArray = entityBlock["media"] as? [NSDictionary]{
                if let mediaUrl = mediaBlockArray[0]["media_url"] as? String{
                    self.tweetMediaUrl = NSURL(string: mediaUrl)
                }
            }
        }
    }
    
    class func arrayOfTweets(tweetArray_dictionary: [NSDictionary]) -> [Tweet]{
        var tweets = [Tweet]()
        
        for tweet in tweetArray_dictionary{
            tweets.append(Tweet(tweet_dictionary: tweet))
        }
        
        return tweets
    }
}
