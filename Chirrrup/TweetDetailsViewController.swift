//
//  TweetDetailsViewController.swift
//  Twitter
//
//  Created by Satyam Jaiswal on 2/27/16.
//  Copyright © 2016 Satyam Jaiswal. All rights reserved.
//

import UIKit

class TweetDetailsViewController: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate {
    
    var tweetid: String?
    
    @IBOutlet weak var tweetProfileImageView: UIImageView!
    
    @IBOutlet weak var tweetUsernameLabel: UILabel!
    
    @IBOutlet weak var tweetHandleLabel: UILabel!
    
    @IBOutlet weak var tweetTextLabel: UITextView!
    
    @IBOutlet weak var tweetTimestampLabel: UILabel!
    
    @IBOutlet weak var retweetCountLabel: UILabel!
    
    @IBOutlet weak var likesCountLabel: UILabel!
    
    @IBOutlet weak var replyImageView: UIImageView!
    
    @IBOutlet weak var retweetImageView: UIImageView!
    
    @IBOutlet weak var likeImageView: UIImageView!
    
    @IBOutlet weak var tweetPosterView: UIImageView!
    
    @IBOutlet weak var retweetedByImageView: UIImageView!
    
    @IBOutlet weak var retweetedByLabel: UILabel!
    
    var tweet: Tweet?
    //var retweeted: Bool?
    //var liked: Bool?
    var tweetId: String?
    var row: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.delegate = self
        navigationController?.navigationBar.barTintColor = UIColor(red: 0.2, green: 0.5, blue: 0.7, alpha: 1.0)
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        setupUIElements()
        addGestures()

    }
    
    func setupUIElements(){
        if let profile_image_url = tweet?.profile_image_url{
            tweetProfileImageView.setImageWithURL(profile_image_url)
        }
        
        tweetUsernameLabel.text = tweet?.username as? String ?? ""
        //tweetHandleLabel.text = tweet?.user_screenname as? String ?? ""
        
        if let tweet_handle = tweet?.user_screenname{
            tweetHandleLabel.text = "@\(tweet_handle)"
        }
        tweetTextLabel.text = tweet?.text as? String ?? ""
        
        if let tweet_timestamp = tweet?.timestamp{
            let formatter = NSDateFormatter()
            formatter.dateStyle = .MediumStyle
            formatter.timeStyle = .ShortStyle
            
            let dateString = formatter.stringFromDate(tweet_timestamp)
            tweetTimestampLabel.text = "\(dateString)"
        }
        
        if let tweet_retweet_count = tweet?.retweet_count{
            retweetCountLabel.text = "\(tweet_retweet_count)"
        }
        
        if let tweet_likes_count = tweet?.likes_count{
            likesCountLabel.text = "\(tweet_likes_count)"
        }
        
        if let liked = tweet?.liked{
            //self.liked = liked
            if liked{
               self.likeImageView.image = UIImage(named: "liked")
            }else{
                self.likeImageView.image = UIImage(named: "like")
            }
        }
        
        if let retweeted = tweet?.retweeted{
            //self.retweeted = retweeted
            if retweeted{
                self.retweetImageView.image = UIImage(named: "retweeted")
            }else{
                self.retweetImageView.image = UIImage(named: "retweet")
            }
        }
        
        if let tweetId = tweet?.tweetId{
            self.tweetId = tweetId as String
        }
        
        if let tweetPosterUrl = tweet?.tweetMediaUrl{
            self.tweetPosterView.hidden = false
            self.tweetPosterView.setImageWithURL(tweetPosterUrl)
        }else{
            self.tweetPosterView.hidden = true
        }
        
        if let retweetBy = tweet?.retweetedBy{
            self.retweetedByLabel.hidden = false
            self.retweetedByImageView.hidden = false
            self.retweetedByLabel.text = retweetBy as String
        }else{
            self.retweetedByLabel.hidden = true
            self.retweetedByImageView.hidden = true
        }
    }
    
    func addGestures(){
        let tapRetweet = UITapGestureRecognizer(target: self, action: #selector(TweetDetailsViewController.tappedRetweet(_:)))
        self.retweetImageView.addGestureRecognizer(tapRetweet)
        self.retweetImageView.userInteractionEnabled = true
        
        let tapLike = UITapGestureRecognizer(target: self, action: #selector(TweetDetailsViewController.tappedLike(_:)))
        self.likeImageView.addGestureRecognizer(tapLike)
        self.likeImageView.userInteractionEnabled = true
        
        let tapReply = UITapGestureRecognizer(target: self, action: #selector(TweetDetailsViewController.tappedReply(_:)))
        self.replyImageView.addGestureRecognizer(tapReply)
        self.replyImageView.userInteractionEnabled = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tappedRetweet(sender: AnyObject){
        if self.tweet?.retweeted == true{
            TwitterClient.sharedInstance.unretweet(self.tweetId!,
                success: { () -> () in
                    self.retweetImageView.image = UIImage(named: "retweet")
                    //self.retweeted = false
                    self.tweet?.retweeted = false
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
                    //self.retweeted = true
                    self.tweet?.retweeted = true
                    self.tweet?.retweet_count += 1
                    if let retweet_count = self.tweet?.retweet_count{
                        self.retweetCountLabel.text = "\(retweet_count)"
                    }
                }, failure: { (error: NSError) -> () in
                    print("Retweet Error: \(error.localizedDescription)")
                    
            })
        }
    }
    
    func tappedLike(sender: AnyObject){
        if self.tweet?.liked == true{
            TwitterClient.sharedInstance.unlike(self.tweetId!,
                success: { () -> () in
                    self.likeImageView.image = UIImage(named: "like")
                    //self.liked = false
                    self.tweet?.liked = false
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
                    //self.liked = true
                    self.tweet?.liked = true
                    self.tweet?.likes_count += 1
                    if let likes_count = self.tweet?.likes_count{
                        self.likesCountLabel.text = "\(likes_count)"
                    }
                }, failure: { (error: NSError) -> () in
                    print("Tweet Like error: \(error.localizedDescription)")
            })
            
        }
    }
    
    func tappedReply(sender: AnyObject){
        performSegueWithIdentifier("replySegue", sender: sender)
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "replySegue" {
            let destinationViewController = segue.destinationViewController as? ComposeTweetViewController
            destinationViewController?.tweetId = String(self.tweet?.tweetId!)
            destinationViewController?.replyTo = String((self.tweet?.user_screenname)!)
        }
    }
    
    func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
        if let destinationViewController = viewController as? TweetsViewController{
            destinationViewController.tweets![row!] = self.tweet!
        }
    }
    

}
