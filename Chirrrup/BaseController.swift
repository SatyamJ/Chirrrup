//
//  BaseController.swift
//  Chirrrup
//
//  Created by Satyam Jaiswal on 5/21/17.
//  Copyright © 2017 Satyam Jaiswal. All rights reserved.
//

import UIKit

protocol BaseController: NSObjectProtocol, UITableViewDataSource, CellDelegate {
    var tweets: [Tweet]? {get set}
    
    func getCellIndex(of view: UIView) -> Int?
    func updateTableView()
}


extension BaseController{
    
    // Implementing UITableViewDataSource methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if self.tweets == nil {
            return 0
        }else{
            return self.tweets!.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TweetCell", for: indexPath) as! TweetCell
        cell.tweet = self.tweets![indexPath.row]
        cell.delegate = self
        cell.accessoryType = .none
        return cell
    }
    
    // Implementing CellDelegate methods
    func onTapCellLike(_ sender: AnyObject?) {
        if let view = (sender as? UITapGestureRecognizer)?.view{
            if let index = self.getCellIndex(of: view){
                if let tweet = self.tweets?[index]{
                    if let liked = tweet.liked{
                        if liked{
                            TwitterClient.sharedInstance?.unlike(String(tweet.tweetId!),
                                                                 success: { () -> () in
                                                                    self.updateLikesCount(of: index, when: liked)
                            }, failure: { (error: NSError) -> () in
                                print("Tweet Unlike error: \(error.localizedDescription)")
                            })
                        }else{
                            TwitterClient.sharedInstance?.like(String(tweet.tweetId!),
                                                               success: { () -> () in
                                                                self.updateLikesCount(of: index, when: liked)
                            }, failure: { (error: NSError) -> () in
                                print("Tweet Like error: \(error.localizedDescription)")
                            })
                        }
                    }
                }
            }
        }
    }
    
    func updateLikesCount(of index: Int, when liked: Bool){
        if let tweets = self.tweets{
            if liked{
                tweets[index].liked = false
                tweets[index].likes_count -= 1
                
            }else{
                tweets[index].liked = true
                tweets[index].likes_count += 1
            }
            
            //            self.tweetsTableView.reloadData()
            self.updateTableView()
        }
    }
    
    func onTapCellRetweet(_ sender: AnyObject?) {
        
        if let view = (sender as? UITapGestureRecognizer)?.view{
            if let index = self.getCellIndex(of: view){
                if let tweet = self.tweets?[index]{
                    if let retweeted = tweet.retweeted{
                        if retweeted {
                            TwitterClient.sharedInstance?.unretweet(String(tweet.tweetId!),
                                                                    success: { () -> () in
                                                                        self.updateRetweetCount(of: index, when: retweeted)
                            }, failure: { (error: NSError) -> () in
                                print("Un-retweet error: \(error.localizedDescription)")
                            })
                        }else{
                            TwitterClient.sharedInstance?.retweet(String(tweet.tweetId!),
                                                                  success: { () -> () in
                                                                    self.updateRetweetCount(of: index, when: retweeted)
                            }, failure: { (error: NSError) -> () in
                                print("Retweet error: \(error.localizedDescription)")
                            })
                        }
                    }
                }
            }
        }
    }
    
    func updateRetweetCount(of index: Int, when retweeted: Bool){
        if let tweets = self.tweets{
            if retweeted{
                tweets[index].retweeted = false
                tweets[index].retweet_count -= 1
                
            }else{
                tweets[index].retweeted = true
                tweets[index].retweet_count += 1
            }
            
            //self.tweetsTableView.reloadData()
            self.updateTableView()
        }
    }
    
    
}
