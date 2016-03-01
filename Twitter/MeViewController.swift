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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.title = "Me"
        
        if let user = self.user{
            //self.user = user
            
            self.profileImageView.setImageWithURL(user.user_profile_image_url!)
            self.usernameLabel.text = user.name as? String
            self.screennameLabel.text = user.screen_name as? String
            self.coverImageView.setImageWithURL(user.user_background_image_url!)
            self.tweetsCountLabel.text = user.tweetsCount
            self.followersCount.text = user.followersCount
            self.followingCountLabel.text = user.followingCount
            
            
        }
        // Do any additional setup after loading the view.
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
