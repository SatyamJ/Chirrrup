//
//  MeViewController.swift
//  Twitter
//
//  Created by Satyam Jaiswal on 2/27/16.
//  Copyright © 2016 Satyam Jaiswal. All rights reserved.
//

import UIKit
import MBProgressHUD
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l >= r
  default:
    return !(lhs < rhs)
  }
}


class MeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var user: User?
    var myTweets: [Tweet]?
    
    @IBOutlet weak var coverImageView: UIImageView!
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var screennameLabel: UILabel!
    
    @IBOutlet weak var tweetsCountLabel: UILabel!
    
    @IBOutlet weak var followingCountLabel: UILabel!
    
    @IBOutlet weak var followersCount: UILabel!
    
    @IBOutlet weak var menuBarButton: UIBarButtonItem!
    
    @IBOutlet weak var userTweetsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUIElements()
        self.requestNetworkData()
        self.setupTableView()
        self.setupNavigationBar()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupTableView(){
        self.userTweetsTableView.delegate = self
        self.userTweetsTableView.dataSource = self
        self.userTweetsTableView.estimatedRowHeight = 120
        self.userTweetsTableView.rowHeight = UITableViewAutomaticDimension
    }
    
    func setupNavigationBar(){
        self.menuBarButton.target = self.revealViewController()
        self.menuBarButton.action = #selector(SWRevealViewController.revealToggle(_:))
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
    }
    
    func setupUIElements(){
        if let user = self.user{
            
            if let profileImageUrl = user.user_profile_image_url{
                self.profileImageView.setImageWith(profileImageUrl as URL)
            }
            
            if let name = user.name{
                self.usernameLabel.text = name
                self.title = name
            }
            
            if let handle = user.screen_name{
                self.screennameLabel.text = "@\(handle)"
            }
            
            if let bannerUrl = user.profile_banner_url{
                self.coverImageView.setImageWith(bannerUrl as URL)
            }
            
            if let tweetCount = user.tweetsCount{
                self.tweetsCountLabel.text = self.formatNumber(number: tweetCount)
            }
            
            if let followersCount = user.followersCount{
                self.followingCountLabel.text = self.formatNumber(number: followersCount)
            }
            
            if let followingCount = user.followingCount{
                self.followingCountLabel.text = self.formatNumber(number: followingCount)
            }
        }
    }
    
    func formatNumber(number: Int) -> String{
        if number >= 1000000 {
            let million = Float(number)/1000000
            return String(format: "%.1f M", million)
        }else if number >= 1000{
            let grand = Float(number)/1000
            return String(format: "%.1f K", grand)
        }else{
            return "\(number)"
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let tweets = myTweets {
            return tweets.count
        }else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TweetCell", for: indexPath) as! TweetCell
        cell.tweet = self.myTweets![indexPath.row]
        //cell.delegate = self
        return cell
    }
    
    func requestNetworkData(){
        MBProgressHUD.showAdded(to: self.view, animated: true)
        TwitterClient.sharedInstance?.userTimeline((self.user?.screen_name)!, success: { (tweets: [Tweet]) in
            self.myTweets = tweets
            self.userTweetsTableView.reloadData()
            MBProgressHUD.hide(for: self.view, animated: true)
            }, failure: { (error: NSError) in
                print("Error: \(error.localizedDescription)")
        })
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
