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
    
    static let sharedInstance = TwitterClient(baseURL: NSURL(string: "https://api.twitter.com"), consumerKey: "qPDZMKsesEU2VqRQycEbtWtEs", consumerSecret: "Wx8KLHmRQn2L3XXDDqmGtBBlr742r75XhXbfZTJTbheH3YPjqY")
    
    func login(success: () -> (), failure: (NSError) -> ()){
        loginsuccess = success
        loginfailure = failure

        let client = TwitterClient.sharedInstance
        client.deauthorize()
        
        client.fetchRequestTokenWithPath("oauth/request_token", method: "GET", callbackURL: NSURL(string: "myTwitterApp://oauth"), scope: nil, success: { (requestToken: BDBOAuth1Credential!) -> Void in
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
                
                
                /*
                //let client = TwitterClient.sharedInstance
                client.currentAccount({ (user: User) -> () in
                    print("name: \(user.name)")
                    print("screen name: \(user.screen_name)")
                    print("profile image url: \(user.user_profile_image_url)")
                    print("tagline: \(user.tagline)")
                    }, failure: {(error: NSError) -> () in
                        print("Verify credentials error: \(error)")
                })
                
                client.homeTimeline({ (tweets: [Tweets]) -> () in
                    for tweet in tweets{
                        print("Tweet: \(tweet.text)")
                        print("Retweet count: \(tweet.retweet_count)")
                        print("Likes: \(tweet.likes_count)")
                        print("Date-Time: \(tweet.timestamp)")
                    }
                    }, failure: { (error: NSError) -> () in
                        print("home timeline error: \(error)")
                })*/
                
            }) { (error: NSError!) -> Void in
                print("Access token error: \(error)")
                self.loginfailure?(error)
        }
    }
    
    func homeTimeline(success: ([Tweets]) -> (), failure: (NSError) -> () ){
        GET("1.1/statuses/home_timeline.json", parameters: nil, progress: nil,
            success: { (task: NSURLSessionDataTask, response: AnyObject?) -> Void in
                print("Home timeline tweets")
                
                let tweetsArrayDictionary = response as! [NSDictionary]
                let tweets = Tweets.arrayOfTweets(tweetsArrayDictionary)
                
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
    
    func replyToTweet(tweetId: String, status: String, success: () -> (), failure: (NSError) -> () ){
        print(tweetId)
        POST("1.1/statuses/update.json?in_reply_to_status_id_str=\(tweetId)&status=\(status)", parameters: nil, progress: nil,
            success: { (task: NSURLSessionDataTask, response: AnyObject?) -> Void in
                print("Replied to: \(tweetId)")
                success()
            },
            failure: { (task: NSURLSessionDataTask?, error: NSError) -> Void in
                failure(error)
            }
        )
    }
}
