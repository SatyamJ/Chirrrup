//
//  TweetCell.swift
//  Twitter
//
//  Created by Satyam Jaiswal on 2/20/16.
//  Copyright © 2016 Satyam Jaiswal. All rights reserved.
//

import UIKit
import AFNetworking

protocol CellDelegate {
    func onTapCellProfileImage(sender: AnyObject?)
}

class TweetCell: UITableViewCell {

    @IBOutlet weak var nameLabek: UILabel!
    
    @IBOutlet weak var userHandleLabel: UILabel!
    
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var tweetTextView: UITextView!
    
    @IBOutlet weak var retweetCountLabel: UILabel!
    
    @IBOutlet weak var likesCountLabel: UILabel!
    
    @IBOutlet weak var userProfileImageView: UIImageView!
    
    @IBOutlet weak var retweetedByLabel: UILabel!
    
    @IBOutlet weak var retweetedByImage: UIImageView!
    
    @IBOutlet weak var retweetImage: UIImageView!
    
    @IBOutlet weak var likeImage: UIImageView!
    
    @IBOutlet weak var tweetPosterView: UIImageView!
    
    
    var delegate: CellDelegate?
    let profileImageTapGes = UITapGestureRecognizer()
    
    var retweeted: Bool?
    var liked: Bool?
    var tweetId: String?
    var table: UITableView?
    var index: NSIndexPath?
    var row: Int?
    
    var tweet:Tweets? {
        didSet{
            self.nameLabek.text = tweet!.username as? String
            self.userHandleLabel.text = "@\(tweet!.user_screenname!)" //as String
            
            if let date = tweet!.timestamp {
                self.timeLabel.text = NSDate().offsetFrom(date)
            }
            
            self.tweetTextView.text = tweet!.text! as String
            self.retweetCountLabel.text = "\(tweet!.retweet_count)"
            self.likesCountLabel.text = "\(tweet!.likes_count)"
            
            if let url = tweet!.profile_image_url {
                print("profile: \(url)")
                self.userProfileImageView.setImageWithURL(url)
            }
            
            if let retweetBy = tweet?.retweetedBy{
                self.retweetedByLabel.text = retweetBy as String
            }else{
                self.retweetedByLabel.hidden = true
                self.retweetedByImage.hidden = true
            }
            
            if let retweeted = tweet?.retweeted{
                self.retweeted = retweeted
                if retweeted {
                    self.retweetImage.image = UIImage(named: "retweeted")
                }
            }
            
            if let liked = tweet?.liked{
                self.liked = liked
                if liked {
                    self.likeImage.image = UIImage(named: "liked")
                }
            }
            
            if let tweetId = tweet?.tweetId{
                self.tweetId = tweetId as String
            }
            
            if let tweetMedia = tweet?.tweetMediaUrl{
                //print("media: \(tweetMedia)")
                self.tweetPosterView.hidden = false
                self.tweetPosterView.setImageWithURL(tweetMedia)
            }else{
                //print("No media found")
                
                self.tweetPosterView.hidden = true
                //self.tweetPosterView.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
                
                self.tweetPosterView.frame.size.height = 0
                self.tweetPosterView.frame.size.width = 0
                
            }
            
        }
    }
    
    func profileImageTapGestureAction(sender: AnyObject) {
        //print("profileImageTapGestureAction method called")
        delegate?.onTapCellProfileImage(sender)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let tapRetweet = UITapGestureRecognizer(target: self, action: #selector(TweetCell.tappedRetweet))
        self.retweetImage.addGestureRecognizer(tapRetweet)
        self.retweetImage.userInteractionEnabled = true
        
        let tapLike = UITapGestureRecognizer(target: self, action: #selector(TweetCell.tappedLike))
        self.likeImage.addGestureRecognizer(tapLike)
        self.likeImage.userInteractionEnabled = true
        
        profileImageTapGes.addTarget(self, action: #selector(TweetCell.profileImageTapGestureAction(_:)))
        userProfileImageView.addGestureRecognizer(profileImageTapGes)
        userProfileImageView.userInteractionEnabled = true
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func tappedProfileImage(){
        /*
        let destination = UIViewController() as! UserTimelineViewController // Your destination
        let vc = UIViewController as UserTimelineViewController
        let n = UINavigationController(rootViewController: UserTimelineViewController)
        //navigationController?.pushViewController(destination, animated: true)
        */
    }
    
    func tappedRetweet(){
        if self.retweeted == true{
            TwitterClient.sharedInstance.unretweet(self.tweetId!,
                success: { () -> () in
                    self.retweetImage.image = UIImage(named: "retweet")
                    self.retweeted = false
                    self.tweet?.retweet_count -= 1
                    self.retweetCountLabel.text = "\((self.tweet?.retweet_count)!)"
                    
                }, failure: { (error: NSError) -> () in
                    print("Unretweet Error: \(error.localizedDescription)")
            })
        }else{
            TwitterClient.sharedInstance.retweet(self.tweetId!,
                success: { () -> () in
                    self.retweetImage.image = UIImage(named: "retweeted")
                    self.retweeted = true
                    self.tweet?.retweet_count += 1
                    self.retweetCountLabel.text = "\((self.tweet?.retweet_count)!)"
                }, failure: { (error: NSError) -> () in
                    print("Retweet Error: \(error.localizedDescription)")
            })
        }
    }
    
    func tappedLike(){
        if self.liked == true{
            TwitterClient.sharedInstance.unlike(self.tweetId!,
                success: { () -> () in
                    self.likeImage.image = UIImage(named: "like")
                    self.liked = false
                    self.tweet?.likes_count -= 1
                    self.likesCountLabel.text = "\((self.tweet?.likes_count)!)"
                }, failure: { (error: NSError) -> () in
                    print("Tweet Unlike error: \(error.localizedDescription)")
            })
        }else{
            TwitterClient.sharedInstance.like(self.tweetId!,
                success: { () -> () in
                    self.likeImage.image = UIImage(named: "liked")
                    self.liked = true
                    self.tweet?.likes_count += 1
                    self.likesCountLabel.text = "\((self.tweet?.likes_count)!)"
                }, failure: { (error: NSError) -> () in
                    print("Tweet Like error: \(error.localizedDescription)")
            })
            
        }
    }
}

extension NSDate {
    func yearsFrom(date:NSDate) -> Int{
        return NSCalendar.currentCalendar().components(.Year, fromDate: date, toDate: self, options: []).year
    }
    func monthsFrom(date:NSDate) -> Int{
        return NSCalendar.currentCalendar().components(.Month, fromDate: date, toDate: self, options: []).month
    }
    func weeksFrom(date:NSDate) -> Int{
        return NSCalendar.currentCalendar().components(.WeekOfYear, fromDate: date, toDate: self, options: []).weekOfYear
    }
    func daysFrom(date:NSDate) -> Int{
        return NSCalendar.currentCalendar().components(.Day, fromDate: date, toDate: self, options: []).day
    }
    func hoursFrom(date:NSDate) -> Int{
        return NSCalendar.currentCalendar().components(.Hour, fromDate: date, toDate: self, options: []).hour
    }
    func minutesFrom(date:NSDate) -> Int{
        return NSCalendar.currentCalendar().components(.Minute, fromDate: date, toDate: self, options: []).minute
    }
    func secondsFrom(date:NSDate) -> Int{
        return NSCalendar.currentCalendar().components(.Second, fromDate: date, toDate: self, options: []).second
    }
    func offsetFrom(date:NSDate) -> String {
        
        if yearsFrom(date)   > 0 { return "\(yearsFrom(date))y"   }
        if monthsFrom(date)  > 0 { return "\(monthsFrom(date))M"  }
        if weeksFrom(date)   > 0 { return "\(weeksFrom(date))w"   }
        if daysFrom(date)    > 0 { return "\(daysFrom(date))d"    }
        if hoursFrom(date)   > 0 { return "\(hoursFrom(date))h"   }
        if minutesFrom(date) > 0 { return "\(minutesFrom(date))m" }
        if secondsFrom(date) > 0 { return "\(secondsFrom(date))s" }
        return ""
    }
}
