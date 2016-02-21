//
//  TweetCell.swift
//  Twitter
//
//  Created by Satyam Jaiswal on 2/20/16.
//  Copyright © 2016 Satyam Jaiswal. All rights reserved.
//

import UIKit

class TweetCell: UITableViewCell {

    @IBOutlet weak var nameLabek: UILabel!
    
    @IBOutlet weak var userHandleLabel: UILabel!
    
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var tweetTextLabel: UILabel!
    
    @IBOutlet weak var retweetCountLabel: UILabel!
    
    @IBOutlet weak var likesCountLabel: UILabel!
    
    @IBOutlet weak var userProfileImageView: UIImageView!
    
    var tweet:Tweets? {
        didSet{
            self.nameLabek.text = tweet!.username as? String
            self.userHandleLabel.text = tweet!.user_screenname! as String
            if let date = tweet!.timestamp {
                let formatter = NSDateFormatter()
                formatter.dateFormat = "MM/dd/yyyy"
                self.timeLabel.text = formatter.stringFromDate(date)
//                self.timeLabel.text = "\(tweet!.timestamp)"
            }
            self.tweetTextLabel.text = tweet!.text! as String
            self.retweetCountLabel.text = "\(tweet!.retweet_count)"
            self.likesCountLabel.text = "\(tweet!.likes_count)"
            
            if let url = tweet!.profile_image_url {
                self.userProfileImageView.setImageWithURL(url)
            }
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
