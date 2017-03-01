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
    var loginfailure: ((Error) -> ())?
    
    static let sharedInstance = TwitterClient(
        baseURL: URL(string: "https://api.twitter.com"),
        consumerKey: "qPDZMKsesEU2VqRQycEbtWtEs",
        consumerSecret: "Wx8KLHmRQn2L3XXDDqmGtBBlr742r75XhXbfZTJTbheH3YPjqY")
    
    func login(_ success: @escaping () -> (), failure: @escaping (Error) -> ()){
        loginsuccess = success
        loginfailure = failure

        let client = TwitterClient.sharedInstance
        client?.deauthorize()
        
        
        client?.fetchRequestToken(withPath: "oauth/request_token", method: "GET", callbackURL: URL(string:"myTwitterApp://oauth"), scope: nil, success: { (requestToken) in
            print("Got request token")
            if let token = requestToken?.token{
                let url = URL(string: "https://api.twitter.com/oauth/authorize?oauth_token=\(token)")
                UIApplication.shared.openURL(url!)
            }
            
        }, failure: { (error: Error?) in
            print("error: \(error?.localizedDescription)")
            self.loginfailure?(error!)
        })
    }
    
    func getRequestToken(success: @escaping (BDBOAuth1Credential) -> Void, failure: @escaping (Error) -> Void){
        print("Fetching request token...")
        TwitterClient.sharedInstance?.deauthorize()
        TwitterClient.sharedInstance?.fetchRequestToken(withPath: "oauth/request_token", method: "GET", callbackURL: URL(string: "myTwitterApp://oauth"), scope: nil, success: { (requestToken: BDBOAuth1Credential?) in
            print("Got request token!")
            success(requestToken!)
        }, failure: { (error: Error?) in
            failure(error!)
        })
    }
    
    func setupLoginCallbacks(success: @escaping ()->Void, failure: @escaping (Error)->Void){
        self.loginsuccess = success
        self.loginfailure = failure
    }
    
    func logout(){
        User.currentUser = nil
        TwitterClient.sharedInstance?.deauthorize()
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: "userDidLogout"), object: nil)
    }
    
    func handleOpenUrl(_ url: URL){
        let requestToken = BDBOAuth1Credential(queryString: url.query)
        
        TwitterClient.sharedInstance?.fetchAccessToken(withPath: "oauth/access_token", method: "POST", requestToken: requestToken,
                success: { (accessToken) in
                    print("Got access token")
                
                    self.currentAccount({ (user: User) -> () in
                        User.currentUser = user
                        self.loginsuccess?()
                    }, failure: {(error: NSError) -> () in
                        self.loginfailure?(error)
                })
            }) { (error: Error?) -> Void in
                print("Access token error: \(error)")
                self.loginfailure?(error!)
        }
    }
    
    func homeTimeline(_ success: @escaping ([Tweet]) -> (), failure: @escaping (NSError) -> () ){
        get("1.1/statuses/home_timeline.json", parameters: nil, progress: nil, success: { (task, response) in
            let tweetsArrayDictionary = response as! [NSDictionary]
            //print(tweetsArrayDictionary)
            let tweets = Tweet.arrayOfTweets(tweetsArrayDictionary)
            
            success(tweets)
        }) { (task, error: Error?) in
            failure(error! as NSError)
        }
    }
    
    func userTimeline(_ screenName: String, success: @escaping ([Tweet]) -> (), failure: @escaping (NSError) -> () ){
        let params = ["screen_name": screenName]
        get("1.1/statuses/user_timeline.json", parameters: params, progress: nil,
             success: {(task, response) in
                let tweetsArrayDictionary = response as! [NSDictionary]
                let tweets = Tweet.arrayOfTweets(tweetsArrayDictionary)
                success(tweets)
            },
            failure: { (task, error: Error?) -> Void in
                failure(error! as NSError)
            }
        )
    }
    
    
    func homeTimelineOnScroll(_ lastId: Int, success: @escaping ([Tweet]) -> (), failure: @escaping (NSError) -> () ){
        let params = ["max_id": lastId]
        get("1.1/statuses/home_timeline.json", parameters: params, progress: nil,
            success: { (task, response) -> Void in
                //print("Home timeline tweets")
                
                let tweetsArrayDictionary = response as! [NSDictionary]
                //print(tweetsArrayDictionary)
                let tweets = Tweet.arrayOfTweets(tweetsArrayDictionary)
                
                success(tweets)
            },
            failure: { (task, error: Error?) -> Void in
                failure(error! as NSError)
            }
        )
    }
    
    func currentAccount(_ success: @escaping (User) -> (), failure: @escaping (NSError) -> ()){
        get("1.1/account/verify_credentials.json", parameters: nil, progress: nil,
            success: { (task, response) -> Void in
                let user = User(user_dictionary: response as! NSDictionary)
                success(user)
            },
            failure: { (task, error: Error?) -> Void in
                failure(error! as NSError)
            }
        )
    }
    
    
    func retweet(_ tweetId: String, success: @escaping () -> (), failure: @escaping (NSError) -> () ){
        
        post("1.1/statuses/retweet/\(tweetId).json", parameters: nil, progress: nil,
            success: { (task, response) -> Void in
                print("Retweeted \(tweetId)")
                
                success()
            },
            failure: { (task, error: Error) -> Void in
                failure(error as NSError)
            }
        )
    }
    
    func unretweet(_ tweetId: String, success: @escaping () -> (), failure: @escaping (NSError) -> () ){
        
        post("1.1/statuses/unretweet/\(tweetId).json", parameters: nil, progress: nil,
            success: { (task, response) -> Void in
                print("Retweet undone \(tweetId)")
                
                success()
            },
            failure: { (task, error: Error) -> Void in
                failure(error as NSError)
            }
        )
    }
    
    func like(_ tweetId: String, success: @escaping () -> (), failure: @escaping (NSError) -> () ){
        //print(tweetId)
        post("1.1/favorites/create.json?id=\(tweetId)", parameters: nil, progress: nil,
            success: { (task, response) -> Void in
                print("Liked \(tweetId)")
                
                success()
            },
            failure: { (task, error: Error) -> Void in
                failure(error as NSError)
            }
        )
    }
    
    func unlike(_ tweetId: String, success: @escaping () -> (), failure: @escaping (NSError) -> () ){
        
        post("1.1/favorites/destroy.json?id=\(tweetId)", parameters: nil, progress: nil,
            success: { (task, response) in
                print("Unlike \(tweetId)")
                success()
            },
            failure: { (task, error: Error) -> Void in
                failure(error as NSError)
            }
        )
    }
    
    func tweet(_ tweetId: String, status: String, success: @escaping (_ response: Tweet) -> (), failure: @escaping (NSError) -> () ){
        print(tweetId)
        
        var params = [String: AnyObject]()
        params["status"] = status as AnyObject?
        
        // reply to a tweet or new tweet
        if tweetId.characters.count > 0 {
            params["in_reply_to_status_id"] = tweetId as AnyObject?
        }
        
        post("1.1/statuses/update.json", parameters: params, progress: nil,
            success: { (task, response) -> Void in
                //print("Replied to: \(tweetId)")
                if let result = response as? NSDictionary{
                    //print(result)
                    let tweet = Tweet(tweet_dictionary: result)
                    success(tweet)
                }else{
                    print("No dictionary received")
                }
                
            },
            failure: { (task, error: Error) -> Void in
                failure(error as NSError)
            }
        )
    }
}
