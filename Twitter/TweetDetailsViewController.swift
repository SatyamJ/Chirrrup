//
//  TweetDetailsViewController.swift
//  Twitter
//
//  Created by Satyam Jaiswal on 2/27/16.
//  Copyright © 2016 Satyam Jaiswal. All rights reserved.
//

import UIKit

class TweetDetailsViewController: UIViewController {
    
    var tweetid: String?
    
    @IBOutlet weak var tweetProfileImageView: UIImageView!
    
    @IBOutlet weak var tweetUsernameLabel: UILabel!
    
    @IBOutlet weak var tweetHandleLabel: UILabel!
    
    @IBOutlet weak var tweetTextLabel: UILabel!
    
    @IBOutlet weak var tweetTimestampLabel: UILabel!
    
    @IBOutlet weak var retweetCountLabel: UILabel!
    
    @IBOutlet weak var likesCountLabel: UILabel!
    
    @IBOutlet weak var replyImageView: UIImageView!
    
    @IBOutlet weak var retweetImageView: UIImageView!
    
    @IBOutlet weak var likeImageView: UIImageView!
    
    var tweet: Tweets?
    var retweeted: Bool?
    var liked: Bool?
    var tweetId: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let profile_image_url = tweet?.profile_image_url{
                tweetProfileImageView.setImageWithURL(profile_image_url)
        }
        
        tweetUsernameLabel.text = tweet?.username as? String ?? ""
        tweetHandleLabel.text = tweet?.user_screenname as? String ?? ""
        tweetTextLabel.text = tweet?.text as? String ?? ""
        
        if let tweet_timestamp = tweet?.timestamp{
            tweetTimestampLabel.text = "\(tweet_timestamp)"
        }
        
        if let tweet_retweet_count = tweet?.retweet_count{
            retweetCountLabel.text = "\(tweet_retweet_count)"
        }
        
        if let tweet_likes_count = tweet?.likes_count{
            likesCountLabel.text = "\(tweet_likes_count)"
        }
        
        if let liked = tweet?.liked{
            self.liked = liked
        }
        
        if let retweeted = tweet?.retweeted{
            self.retweeted = retweeted
        }
        
        if let tweetId = tweet?.tweetId{
            self.tweetId = tweetId as String
        }
        
        // Do any additional setup after loading the view.
        let tapRetweet = UITapGestureRecognizer(target: self, action: Selector("tappedRetweet"))
        self.retweetImageView.addGestureRecognizer(tapRetweet)
        self.retweetImageView.userInteractionEnabled = true
        
        let tapLike = UITapGestureRecognizer(target: self, action: Selector("tappedLike"))
        self.likeImageView.addGestureRecognizer(tapLike)
        self.likeImageView.userInteractionEnabled = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tappedRetweet(){
        if self.retweeted == true{
            TwitterClient.sharedInstance.unretweet(self.tweetId!,
                success: { () -> () in
                    self.retweetImageView.image = UIImage(named: "retweet")
                    self.retweeted = false
                    self.tweet?.retweet_count -= 1
                    if let retweet_count = self.tweet?.retweet_count{
                        self.retweetCountLabel.text = "\(retweet_count)"
                    }
                    
                    
                }, failure: { (error: NSError) -> () in
                    print("Unretweet Error: \(error.localizedDescription)")
            })
        }else{
            TwitterClient.sharedInstance.retweet(self.tweetId!,
                success: { () -> () in
                    self.retweetImageView.image = UIImage(named: "retweeted")
                    self.retweeted = true
                    self.tweet?.retweet_count += 1
                    if let retweet_count = self.tweet?.retweet_count{
                        self.retweetCountLabel.text = "\(retweet_count)"
                    }
                }, failure: { (error: NSError) -> () in
                    print("Retweet Error: \(error.localizedDescription)")
                    
            })
        }
    }
    
    func tappedLike(){
        if self.liked == true{
            TwitterClient.sharedInstance.unlike(self.tweetId!,
                success: { () -> () in
                    self.likeImageView.image = UIImage(named: "like")
                    self.liked = false
                    self.tweet?.likes_count -= 1
                    
                    if let likes_count = self.tweet?.likes_count{
                        self.likesCountLabel.text = "\(likes_count)"
                    }
                }, failure: { (error: NSError) -> () in
                    print("Tweet Unlike error: \(error.localizedDescription)")
            })
        }else{
            TwitterClient.sharedInstance.like(self.tweetId!,
                success: { () -> () in
                    self.likeImageView.image = UIImage(named: "liked")
                    self.liked = true
                    self.tweet?.likes_count += 1
                    if let likes_count = self.tweet?.likes_count{
                        self.likesCountLabel.text = "\(likes_count)"
                    }
                }, failure: { (error: NSError) -> () in
                    print("Tweet Like error: \(error.localizedDescription)")
            })
            
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    

}
