//
//  TwitterClient.swift
//  Twitter
//
//  Created by Satyam Jaiswal on 2/15/16.
//  Copyright © 2016 Satyam Jaiswal. All rights reserved.
//

import UIKit
import BDBOAuth1Manager

class TwitterClient: BDBOAuth1SessionManager {
    
    var loginsuccess: (() -> ())?
    var loginfailure: ((NSError) -> ())?
    
    static let sharedInstance = TwitterClient(
        baseURL: NSURL(string: "https://api.twitter.com"),
        consumerKey: "qPDZMKsesEU2VqRQycEbtWtEs",
        consumerSecret: "Wx8KLHmRQn2L3XXDDqmGtBBlr742r75XhXbfZTJTbheH3YPjqY")
    
    func login(success: () -> (), failure: (NSError) -> ()){
        loginsuccess = success
        loginfailure = failure

        let client = TwitterClient.sharedInstance
        client.deauthorize()
        
        client.fetchRequestTokenWithPath("oauth/request_token",
            method: "GET",
            callbackURL: NSURL(string: "myTwitterApp://oauth"),
            scope: nil,
            success: { (requestToken: BDBOAuth1Credential!) -> Void in
                print("Got request token")
        
                let url = NSURL(string: "https://api.twitter.com/oauth/authorize?oauth_token=\(requestToken.token)")
                UIApplication.sharedApplication().openURL(url!)
            
            }) { (error: NSError!) -> Void in
                print("error: \(error.localizedDescription)")
                self.loginfailure?(error)
        }
    }
    
    func logout(){
        User.currentUser = nil
        TwitterClient.sharedInstance.deauthorize()
        
        NSNotificationCenter.defaultCenter().postNotificationName("userDidLogout", object: nil)
    }
    
    func handleOpenUrl(url: NSURL){
        let requestToken = BDBOAuth1Credential(queryString: url.query)
        
        TwitterClient.sharedInstance.fetchAccessTokenWithPath("oauth/access_token", method: "POST", requestToken: requestToken,
            success: { (accessToken: BDBOAuth1Credential!) -> Void in
                print("Got access token")
                
                self.currentAccount({ (user: User) -> () in
                    User.currentUser = user
                    self.loginsuccess?()
                }, failure: { (error: NSError) -> () in
                    self.loginfailure?(error)
                })
            }) { (error: NSError!) -> Void in
                print("Access token error: \(error)")
                self.loginfailure?(error)
        }
    }
    
    func homeTimeline(success: ([Tweet]) -> (), failure: (NSError) -> () ){
        GET("1.1/statuses/home_timeline.json", parameters: nil, progress: nil,
            success: { (task: NSURLSessionDataTask, response: AnyObject?) -> Void in
                //print("Home timeline tweets")
                
                let tweetsArrayDictionary = response as! [NSDictionary]
                //print(tweetsArrayDictionary)
                let tweets = Tweet.arrayOfTweets(tweetsArrayDictionary)
                
                success(tweets)
            },
            failure: { (task: NSURLSessionDataTask?, error: NSError) -> Void in
                failure(error)
            }
        )
    }
    
    
    func homeTimelineOnScroll(lastId: Int, success: ([Tweet]) -> (), failure: (NSError) -> () ){
        let params = ["max_id": lastId]
        GET("1.1/statuses/home_timeline.json", parameters: params, progress: nil,
            success: { (task: NSURLSessionDataTask, response: AnyObject?) -> Void in
                //print("Home timeline tweets")
                
                let tweetsArrayDictionary = response as! [NSDictionary]
                //print(tweetsArrayDictionary)
                let tweets = Tweet.arrayOfTweets(tweetsArrayDictionary)
                
                success(tweets)
            },
            failure: { (task: NSURLSessionDataTask?, error: NSError) -> Void in
                failure(error)
            }
        )
    }
    
    func currentAccount(success: (User) -> (), failure: (NSError) -> ()){
        GET("1.1/account/verify_credentials.json", parameters: nil, progress: nil,
            success: { (task: NSURLSessionDataTask, response: AnyObject?) -> Void in
                let user = User(user_dictionary: response as! NSDictionary)
                success(user)
            },
            failure: { (task: NSURLSessionDataTask?, error: NSError) -> Void in
                failure(error)
            }
        )
    }
    
    
    func retweet(tweetId: String, success: () -> (), failure: (NSError) -> () ){
        
        POST("1.1/statuses/retweet/\(tweetId).json", parameters: nil, progress: nil,
            success: { (task: NSURLSessionDataTask, response: AnyObject?) -> Void in
                print("Retweeted \(tweetId)")
                
                success()
            },
            failure: { (task: NSURLSessionDataTask?, error: NSError) -> Void in
                failure(error)
            }
        )
    }
    
    func unretweet(tweetId: String, success: () -> (), failure: (NSError) -> () ){
        
        POST("1.1/statuses/unretweet/\(tweetId).json", parameters: nil, progress: nil,
            success: { (task: NSURLSessionDataTask, response: AnyObject?) -> Void in
                print("Retweet undone \(tweetId)")
                
                success()
            },
            failure: { (task: NSURLSessionDataTask?, error: NSError) -> Void in
                failure(error)
            }
        )
    }
    
    func like(tweetId: String, success: () -> (), failure: (NSError) -> () ){
        //print(tweetId)
        POST("1.1/favorites/create.json?id=\(tweetId)", parameters: nil, progress: nil,
            success: { (task: NSURLSessionDataTask, response: AnyObject?) -> Void in
                print("Liked \(tweetId)")
                
                success()
            },
            failure: { (task: NSURLSessionDataTask?, error: NSError) -> Void in
                failure(error)
            }
        )
    }
    
    func unlike(tweetId: String, success: () -> (), failure: (NSError) -> () ){
        
        POST("1.1/favorites/destroy.json?id=\(tweetId)", parameters: nil, progress: nil,
            success: { (task: NSURLSessionDataTask, response: AnyObject?) -> Void in
                print("Unlike \(tweetId)")
                success()
            },
            failure: { (task: NSURLSessionDataTask?, error: NSError) -> Void in
                failure(error)
            }
        )
    }
    
    func tweet(tweetId: String, status: String, success: (response: Tweet) -> (), failure: (NSError) -> () ){
        print(tweetId)
        
        var params = [String: AnyObject]()
        params["status"] = status
        
        // reply to a tweet or new tweet
        if tweetId.characters.count > 0 {
            params["in_reply_to_status_id"] = tweetId
        }
        
        POST("1.1/statuses/update.json", parameters: params, progress: nil,
            success: { (task: NSURLSessionDataTask, response: AnyObject?) -> Void in
                //print("Replied to: \(tweetId)")
                if let result = response as? NSDictionary{
                    //print(result)
                    let tweet = Tweet(tweet_dictionary: result)
                    success(response: tweet)
                }else{
                    print("No dictionary received")
                }
                
            },
            failure: { (task: NSURLSessionDataTask?, error: NSError) -> Void in
                failure(error)
            }
        )
    }
}
