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
    func onTapCellProfileImage(_ sender: AnyObject?)
    func onTapCellLike(_ sender: AnyObject?)
    func onTapCellReply(_ sender: AnyObject?)
    func onTapCellRetweet(_ sender: AnyObject?)
}

class TweetCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    
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
    
    @IBOutlet weak var replyImageView: UIImageView!
    
    var delegate: CellDelegate?
    let profileImageTapGes = UITapGestureRecognizer()
    //var retweeted: Bool?
    //var liked: Bool?
    var tweetId: String?
    var table: UITableView?
    var index: IndexPath?
    var row: Int?
    
    var tweet:Tweet? {
        didSet{
            if let name = tweet?.user?.name{
                self.nameLabel.text = name
            }
            
            if let handle = self.tweet?.user?.screen_name{
                self.userHandleLabel.text = "@\(handle)"
            }
            
            if let date = tweet!.timestamp {
                self.timeLabel.text = Date().offsetFrom(date as Date)
            }
            
            if let text = tweet?.text{
                self.tweetTextView.text = text
            }
            
            if let retweetCount = tweet?.retweet_count{
                if retweetCount == 0{
                    self.retweetCountLabel.isHidden = true
                }else{
                    self.retweetCountLabel.isHidden = false
                    self.retweetCountLabel.text = "\(retweetCount)"
                }
                
            }
            
            if let favouriteCount = tweet?.likes_count{
                if favouriteCount == 0{
                    self.likesCountLabel.isHidden = true
                }else{
                    self.likesCountLabel.isHidden = false
                    self.likesCountLabel.text = "\(favouriteCount)"
                }
                
            }
            
            
            if let url = tweet?.user?.user_profile_image_url{
                self.userProfileImageView.setImageWith(url as URL)
                self.userProfileImageView.layer.cornerRadius = 5
                self.userProfileImageView.layer.masksToBounds = true
            }
            
            if let retweetBy = tweet?.retweetedBy{
                self.retweetedByLabel.isHidden = false
                self.retweetedByImage.isHidden = false
                self.retweetedByLabel.text = retweetBy
            }else{
                self.retweetedByLabel.isHidden = true
                self.retweetedByImage.isHidden = true
            }
            
            if let retweeted = tweet?.retweeted{
                //self.retweeted = retweeted
                if retweeted {
                    self.retweetImage.image = UIImage(named: "retweeted")
                }else{
                    self.retweetImage.image = UIImage(named: "retweet")
                }
            }
            
            if let liked = tweet?.liked{
                //self.liked = liked
                if liked {
                    self.likeImage.image = UIImage(named: "liked")
                }else{
                    self.likeImage.image = UIImage(named: "like")
                }
            }
            
            if let tweetId = tweet?.tweetId{
                self.tweetId = tweetId as String
            }
            
            if let tweetMedia = tweet?.tweetMediaUrl{
                //print("media: \(tweetMedia)")
                self.tweetPosterView.isHidden = false
                self.tweetPosterView.setImageWith(tweetMedia as URL)
            }else{
                //print("No media found")
                self.tweetPosterView.isHidden = true
            }
            
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let tapRetweet = UITapGestureRecognizer(target: self, action: #selector(TweetCell.tappedRetweet(_:)))
        self.retweetImage.addGestureRecognizer(tapRetweet)
        self.retweetImage.isUserInteractionEnabled = true
        
        let tapLike = UITapGestureRecognizer(target: self, action: #selector(TweetCell.tappedLike(_:)))
        self.likeImage.addGestureRecognizer(tapLike)
        self.likeImage.isUserInteractionEnabled = true
        
        let tapReply = UITapGestureRecognizer(target: self, action: #selector(TweetCell.tappedReply(_:)))
        self.replyImageView.addGestureRecognizer(tapReply)
        self.replyImageView.isUserInteractionEnabled = true
        
        profileImageTapGes.addTarget(self, action: #selector(TweetCell.profileImageTapGestureAction(_:)))
        userProfileImageView.addGestureRecognizer(profileImageTapGes)
        userProfileImageView.isUserInteractionEnabled = true
        
    }

    /*
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    */
    
    func profileImageTapGestureAction(_ sender: AnyObject) {
        //print("profileImageTapGestureAction method called")
        delegate?.onTapCellProfileImage(sender)
    }
    
    func tappedRetweet(_ sender: AnyObject){
        delegate?.onTapCellRetweet(sender)
        
    }
    
    func tappedLike(_ sender: AnyObject){
        delegate?.onTapCellLike(sender)
        
    }
    
    func tappedReply(_ sender: AnyObject){
        delegate?.onTapCellReply(sender)
    }
}

extension Date {
    func yearsFrom(_ date:Date) -> Int{
        return (Calendar.current as NSCalendar).components(.year, from: date, to: self, options: []).year!
    }
    func monthsFrom(_ date:Date) -> Int{
        return (Calendar.current as NSCalendar).components(.month, from: date, to: self, options: []).month!
    }
    func weeksFrom(_ date:Date) -> Int{
        return (Calendar.current as NSCalendar).components(.weekOfYear, from: date, to: self, options: []).weekOfYear!
    }
    func daysFrom(_ date:Date) -> Int{
        return (Calendar.current as NSCalendar).components(.day, from: date, to: self, options: []).day!
    }
    func hoursFrom(_ date:Date) -> Int{
        return (Calendar.current as NSCalendar).components(.hour, from: date, to: self, options: []).hour!
    }
    func minutesFrom(_ date:Date) -> Int{
        return (Calendar.current as NSCalendar).components(.minute, from: date, to: self, options: []).minute!
    }
    func secondsFrom(_ date:Date) -> Int{
        return (Calendar.current as NSCalendar).components(.second, from: date, to: self, options: []).second!
    }
    func offsetFrom(_ date:Date) -> String {
        
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
