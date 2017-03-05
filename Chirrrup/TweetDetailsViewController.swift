//
//  TweetDetailsViewController.swift
//  Twitter
//
//  Created by Satyam Jaiswal on 2/27/16.
//  Copyright © 2016 Satyam Jaiswal. All rights reserved.
//

import UIKit

class TweetDetailsViewController: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate, UIScrollViewDelegate {
    
//    var tweetid: String?
    
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
    
    @IBOutlet weak var detailsScrollView: UIScrollView!
    
    @IBOutlet weak var bottommostView: UIView!
    
    var tweet: Tweet?
    var tweetId: String?
    var row: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupScrollView()
        self.setupNavigationBar()
        self.setupUIElements()
        self.addGestures()
    }
    
    override func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        print("willRotate called")
        print(self.bottommostView.frame.maxY)
        let contentWidth = self.detailsScrollView.bounds.width
//        let contentHeight = self.detailsScrollView.bounds.height * 3
        self.detailsScrollView.contentSize = CGSize(width: contentWidth, height: self.bottommostView.frame.maxY)
    }
    
    func setupScrollView(){
        self.detailsScrollView.delegate = self
        let contentWidth = self.detailsScrollView.bounds.width
//        let contentHeight = self.detailsScrollView.bounds.height * 3
        self.detailsScrollView.contentSize = CGSize(width: contentWidth, height: self.bottommostView.frame.maxY)
    }
    
    func setupNavigationBar(){
        navigationController?.delegate = self
        
    }
    
    func setupUIElements(){
        
        if let user = tweet?.user{
            if let profileImageUrl = user.user_profile_image_url{
                self.tweetProfileImageView.setImageWith(profileImageUrl)
            }
            
            if let name = user.name{
                self.tweetUsernameLabel.text = name
            }
            
            
            if let handle = user.screen_name{
                tweetHandleLabel.text = "@\(handle)"
            }
        }
        
        if let text = tweet?.text {
            self.tweetTextLabel.text = text
        }
        
        if let timestamp = tweet?.timestamp{
            var timestampText = ""
            
            let timeFormatter = DateFormatter()
            timeFormatter.dateStyle = .none
            timeFormatter.timeStyle = .short
            timestampText.append(timeFormatter.string(from: timestamp))
            
            timestampText.append(" • ")
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .none
            timestampText.append(dateFormatter.string(from: timestamp))
            
            self.tweetTimestampLabel.text = timestampText
        }
        
        if let retweetCount = tweet?.retweet_count{
            retweetCountLabel.text = "\(retweetCount)"
        }
        
        if let likesCount = tweet?.likes_count{
            likesCountLabel.text = "\(likesCount)"
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
            self.tweetPosterView.isHidden = false
            self.tweetPosterView.setImageWith(tweetPosterUrl as URL)
            self.tweetPosterView.layer.cornerRadius = 10
            self.tweetPosterView.layer.masksToBounds = true
        }else{
            self.tweetPosterView.isHidden = true
        }
        
        if let retweetBy = tweet?.retweetedBy{
            self.retweetedByLabel.isHidden = false
            self.retweetedByImageView.isHidden = false
            self.retweetedByLabel.text = retweetBy as String
        }else{
            self.retweetedByLabel.isHidden = true
            self.retweetedByImageView.isHidden = true
        }
    }
    
    func addGestures(){
        let tapRetweet = UITapGestureRecognizer(target: self, action: #selector(tappedRetweet(_:)))
        self.retweetImageView.addGestureRecognizer(tapRetweet)
        self.retweetImageView.isUserInteractionEnabled = true
        
        let tapLike = UITapGestureRecognizer(target: self, action: #selector(tappedLike(_:)))
        self.likeImageView.addGestureRecognizer(tapLike)
        self.likeImageView.isUserInteractionEnabled = true
        
        let tapReply = UITapGestureRecognizer(target: self, action: #selector(tappedReply(_:)))
        self.replyImageView.addGestureRecognizer(tapReply)
        self.replyImageView.isUserInteractionEnabled = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tappedRetweet(_ sender: AnyObject){
        if self.tweet?.retweeted == true{
            TwitterClient.sharedInstance?.unretweet(self.tweetId!,
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
            TwitterClient.sharedInstance?.retweet(self.tweetId!,
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
    
    func tappedLike(_ sender: AnyObject){
        if self.tweet?.liked == true{
            TwitterClient.sharedInstance?.unlike(self.tweetId!,
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
            TwitterClient.sharedInstance?.like(self.tweetId!,
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
    
    func tappedReply(_ sender: AnyObject){
        performSegue(withIdentifier: "replySegue", sender: sender)
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "replySegue" {
            let destinationViewController = segue.destination as? ComposeTweetViewController
            destinationViewController?.tweetId = self.tweet?.tweetId
            destinationViewController?.replyTo = self.tweet?.user?.screen_name
        }
    }
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if let destinationViewController = viewController as? TweetsViewController{
            destinationViewController.tweets![row!] = self.tweet!
        }
    }
    

}
