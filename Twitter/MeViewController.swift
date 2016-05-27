//
//  MeViewController.swift
//  Twitter
//
//  Created by Satyam Jaiswal on 2/27/16.
//  Copyright © 2016 Satyam Jaiswal. All rights reserved.
//

import UIKit

class MeViewController: UIViewController {
    
    var user: User?
    
    @IBOutlet weak var coverImageView: UIImageView!
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var screennameLabel: UILabel!
    
    @IBOutlet weak var tweetsCountLabel: UILabel!
    
    @IBOutlet weak var followingCountLabel: UILabel!
    
    @IBOutlet weak var followersCount: UILabel!
    
    @IBOutlet weak var menuBarButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let user = self.user{
            
            if let profileImageUrl = user.user_profile_image_url{
                self.profileImageView.setImageWithURL(profileImageUrl)
            }
            
            if let name = user.name as? String{
                self.usernameLabel.text = name
                self.title = name
            }
            
            if let handle = user.screen_name as? String{
                self.screennameLabel.text = "@\(handle)"
            }
            
            if let bannerUrl = user.profile_banner_url{
                self.coverImageView.setImageWithURL(bannerUrl)
            }
            
            if let tweetCount = user.tweetsCount{
                let count = Int(tweetCount)
                if count >= 1000000 {
                    let million = Float(count!)/1000000
                    self.tweetsCountLabel.text = String(format: "%.1f M", million)
                }else if count >= 1000{
                    let grand = Float(count!)/1000
                    self.tweetsCountLabel.text = String(format: "%.1f K", grand)
                }else{
                    self.tweetsCountLabel.text = tweetCount
                }
            }
            
            //self.tweetsCountLabel.text = user.tweetsCount
            //self.followersCount.text = user.followersCount
            if let followersCount = user.followersCount{
                let count = Int(followersCount)
                if count >= 1000000 {
                    let million = Float(count!)/1000000
                    self.followersCount.text = String(format: "%.1f M", million)
                }else if count >= 1000{
                    let grand = Float(count!)/1000
                    self.followersCount.text = String(format: "%.1f K", grand)
                }else{
                    self.followersCount.text = followersCount
                }
            }
            
            //self.followingCountLabel.text = user.followingCount
            if let followingCount = user.followingCount{
                let count = Int(followingCount)
                if count >= 1000000 {
                    let million = Float(count!)/1000000
                    self.followingCountLabel.text = String(format: "%.1f M", million)
                }else if count >= 1000{
                    let grand = Float(count!)/1000
                    self.followingCountLabel.text = String(format: "%.1f K", grand)
                }else{
                    self.followingCountLabel.text = followingCount
                }
            }
        }
        
        self.menuBarButton.target = self.revealViewController()
        self.menuBarButton.action = #selector(SWRevealViewController.revealToggle(_:))
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
