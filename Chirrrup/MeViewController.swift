//
//  MeViewController.swift
//  Twitter
//
//  Created by Satyam Jaiswal on 2/27/16.
//  Copyright © 2016 Satyam Jaiswal. All rights reserved.
//

import UIKit
import MBProgressHUD

class MeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CellDelegate, UIScrollViewDelegate {
    
    @IBOutlet weak var coverImageView: UIImageView!
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var screennameLabel: UILabel!
    
    @IBOutlet weak var tweetsCountLabel: UILabel!
    
    @IBOutlet weak var followingCountLabel: UILabel!
    
    @IBOutlet weak var followersCount: UILabel!
    
    @IBOutlet weak var userTweetsTableView: UITableView!
    
    var user: User?
    var myTweets: [Tweet]?
    var loadingMoreView:InfiniteScrollActivityView?
    var moreDataRequested: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    
    fileprivate func setupUI(){
        self.setupUIElements()
        self.requestNetworkData()
        self.setupInfiniteScrollView()
        self.setupRefreshControl()
    }

    fileprivate func setupRefreshControl(){
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), for: UIControlEvents.valueChanged)
        userTweetsTableView.insertSubview(refreshControl, at: 0)
    }
    
    func refreshControlAction(_ refreshControl: UIRefreshControl){
        requestNetworkData()
        refreshControl.endRefreshing()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func setupInfiniteScrollView(){
        // Set up Infinite Scroll loading indicator
        let frame = CGRect(x: 0, y: userTweetsTableView.contentSize.height, width: userTweetsTableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
        loadingMoreView = InfiniteScrollActivityView(frame: frame)
        loadingMoreView!.isHidden = true
        userTweetsTableView.addSubview(loadingMoreView!)
        
        var insets = userTweetsTableView.contentInset;
        insets.bottom += InfiniteScrollActivityView.defaultHeight;
        userTweetsTableView.contentInset = insets
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (!moreDataRequested){
            
            let scrollViewContentHeight = self.userTweetsTableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - self.userTweetsTableView.bounds.size.height
            
            if scrollView.contentOffset.y > scrollOffsetThreshold && userTweetsTableView.isDragging {
                moreDataRequested = true
                loadMoreData()
            }
            
        }
    }
    
    fileprivate func loadMoreData(){
        self.showProgressView()
        TwitterClient.sharedInstance?.userTimelineBefore(self.getEarliestTweetId(), self.user?.screen_name,success: { (moreTweets: [Tweet]) in
            
            if moreTweets.count > 0 {
                self.myTweets?.append(contentsOf: moreTweets)
                self.userTweetsTableView.reloadData()
            }
            self.loadingMoreView?.stopAnimating()
            self.moreDataRequested = false
        }) { (error: NSError) in
            self.loadingMoreView?.stopAnimating()
            print("Error in loading more feeds: \(error.localizedDescription)")
        }
    }
    
    fileprivate func getEarliestTweetId() -> Int? {
        var id:Int?
        
        if let tweets = self.myTweets{
            if tweets.count > 0{
                if let strId = tweets[tweets.count-1].tweetId{
                    id = Int(strId)
                }
            }
        }
        return id
    }
    
    fileprivate func showProgressView(){
        // Update position of loadingMoreView, and start loading indicator
        let frame = CGRect(x: 0, y: userTweetsTableView.contentSize.height, width: userTweetsTableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
        self.loadingMoreView?.frame = frame
        self.loadingMoreView?.startAnimating()
    }
    
    fileprivate func setupTableView(){
        self.userTweetsTableView.delegate = self
        self.userTweetsTableView.dataSource = self
        self.userTweetsTableView.estimatedRowHeight = 120
        self.userTweetsTableView.rowHeight = UITableViewAutomaticDimension
    }
    
    fileprivate func setupMenuBarButton(){
        let menuButton = UIButton(type: UIButtonType.system)
        menuButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        menuButton.setImage(UIImage(named: "menu"), for: UIControlState.normal)
        menuButton.isUserInteractionEnabled = true
        menuButton.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        menuButton.addTarget(self.revealViewController(), action: #selector(SWRevealViewController.revealToggle(_:)), for: UIControlEvents.touchDown)
        
        let menuBarButton = UIBarButtonItem()
        menuBarButton.customView = menuButton
        navigationItem.leftBarButtonItem = menuBarButton
    }
    
    fileprivate func setupUIElements(){
        self.setupTableView()
        
        var showingUser: User
        if let user = self.user{
            showingUser = user
        }else{
            self.setupMenuBarButton()
            showingUser = User.currentUser!
            self.user = User.currentUser!
        }
        
        if let profileImageUrl = showingUser.user_profile_image_url{
            self.profileImageView.setImageWith(profileImageUrl as URL)
            self.loadHigherResolutionImage(url: profileImageUrl, imageView: profileImageView)
            self.profileImageView.layer.cornerRadius = 5
            self.profileImageView.layer.masksToBounds = true
            self.profileImageView.layer.borderWidth = 2
            self.profileImageView.layer.borderColor = UIColor.white.cgColor
        }
        
        if let name = showingUser.name{
            self.usernameLabel.text = name
            self.title = name
        }
        
        if let handle = showingUser.screen_name{
            self.screennameLabel.text = "@\(handle)"
        }
        
        if let bannerUrl = showingUser.profile_banner_url{
            self.coverImageView.setImageWith(bannerUrl as URL)
            
            let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            blurEffectView.frame = self.coverImageView.bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            self.coverImageView.addSubview(blurEffectView)
        }
        
        if let tweetCount = showingUser.tweetsCount{
            self.tweetsCountLabel.text = self.formatNumber(number: tweetCount)
        }
        
        if let followersCount = showingUser.followersCount{
            self.followingCountLabel.text = self.formatNumber(number: followersCount)
        }
        
        if let followingCount = showingUser.followingCount{
            self.followingCountLabel.text = self.formatNumber(number: followingCount)
        }
    }
    
    fileprivate func loadHigherResolutionImage(url: URL, imageView: UIImageView) -> Void{
        let hrStringUrl = url.absoluteString.replacingOccurrences(of: "_normal", with: "")
        if let hRUrl = URL(string: hrStringUrl){
            imageView.setImageWith(hRUrl)
        }
    }
    
    fileprivate func formatNumber(number: Int) -> String{
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
        cell.delegate = self
        cell.accessoryType = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.userTweetsTableView.deselectRow(at: indexPath, animated: true)
    }
    
    fileprivate func requestNetworkData(){
        MBProgressHUD.showAdded(to: self.view, animated: true)
        TwitterClient.sharedInstance?.userTimeline((self.user?.screen_name)!, success: { (tweets: [Tweet]) in
            self.myTweets = tweets
            self.userTweetsTableView.reloadData()
            MBProgressHUD.hide(for: self.view, animated: true)
            }, failure: { (error: NSError) in
                print("Error: \(error.localizedDescription)")
                MBProgressHUD.hide(for: self.view, animated: true)
        })
    }
    
    func onTapCellRetweet(_ sender: AnyObject?) {
        //print("onTapCellRetweet called")
        if let recognizer = sender as? UITapGestureRecognizer{
            let imageView = recognizer.view
            if let cellView = imageView?.superview?.superview?.superview as? TweetCell {
                if let indexPath = self.userTweetsTableView.indexPath(for: cellView) {
                    if let tweet = self.myTweets?[indexPath.row]{
                        //print("processing tweet id: \(tweet.tweetId!)")
                        if tweet.retweeted == true{
                            TwitterClient.sharedInstance?.unretweet(String(tweet.tweetId!),
                                success: { () -> () in
                                    self.myTweets![indexPath.row].retweeted = false
                                    self.myTweets![indexPath.row].retweet_count -= 1
                                    self.userTweetsTableView.reloadData()
                            }, failure: { (error: NSError) -> () in
                                print("Un-retweet error: \(error.localizedDescription)")
                            })
                        }else{
                            TwitterClient.sharedInstance?.retweet(String(tweet.tweetId!),
                              success: { () -> () in
                                self.myTweets![indexPath.row].retweeted = true
                                self.myTweets![indexPath.row].retweet_count += 1
                                self.userTweetsTableView.reloadData()
                            }, failure: { (error: NSError) -> () in
                                print("Retweet error: \(error.localizedDescription)")
                            })
                        }
                    }
                }
                
            }
        }
    }

    func onTapCellLike(_ sender: AnyObject?) {
        //print("onTapCellLike called")
        if let recognizer = sender as? UITapGestureRecognizer{
            let imageView = recognizer.view
            if let cellView = imageView?.superview?.superview?.superview as? TweetCell {
                if let indexPath = self.userTweetsTableView.indexPath(for: cellView) {
                    if let tweet = self.myTweets?[indexPath.row]{
                        //print("processing tweet id: \(tweet.tweetId)")
                        if tweet.liked == true{
                            //self.tweets![(indexPath?.row)!].liked = false
                            TwitterClient.sharedInstance?.unlike(String(tweet.tweetId!),
                                 success: { () -> () in
                                    self.myTweets![indexPath.row].liked = false
                                    self.myTweets![indexPath.row].likes_count -= 1
                                    self.userTweetsTableView.reloadData()
                            }, failure: { (error: NSError) -> () in
                                print("Tweet Unlike error: \(error.localizedDescription)")
                            })
                        }else{
                            //self.tweets![(indexPath?.row)!].liked = true
                            TwitterClient.sharedInstance?.like(String(tweet.tweetId!),
                                   success: { () -> () in
                                    self.myTweets![indexPath.row].liked = true
                                    self.myTweets![indexPath.row].likes_count += 1
                                    self.userTweetsTableView.reloadData()
                            }, failure: { (error: NSError) -> () in
                                print("Tweet Like error: \(error.localizedDescription)")
                            })
                        }
                    }
                }
            }
        }
    }
    
    func onTapCellReply(_ sender: AnyObject?) {
        performSegue(withIdentifier: "tweetSegue", sender: sender)
    }
    
    func onTapCellProfileImage(_ sender: AnyObject?){
        //print("onTapCellProfileImage")
        if let recog = sender as? UITapGestureRecognizer {
            let view = recog.view
            if let cell = view?.superview?.superview as? TweetCell {
                if let indexPath = userTweetsTableView.indexPath(for: cell) {
                    if let tweet = myTweets?[indexPath.row] {
                        if tweet.user?.screen_name != self.user?.screen_name{
                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                            if let dvc = storyboard.instantiateViewController(withIdentifier: "MeViewController") as? MeViewController{
                                dvc.user = tweet.user
                                self.navigationController?.pushViewController(dvc, animated: true)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func reload(_ sender: TweetCell) {
        if let index = self.userTweetsTableView.indexPath(for: sender){
            self.userTweetsTableView.reloadRows(at: [index], with: UITableViewRowAnimation.none)
        }
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetailsSegue" {
            if let detailsViewController = segue.destination as? TweetDetailsViewController {
                if let cell = sender as? TweetCell{
                    if let index = self.userTweetsTableView.indexPath(for: cell) {
                        detailsViewController.tweet = self.myTweets?[index.row]
                    }
                }   
            }
        }else if segue.identifier == "tweetSegue" {
            if let nc = segue.destination as? UINavigationController {
                if let composeViewController = nc.topViewController as? ComposeTweetViewController {
                    if let recognizer = sender as? UIGestureRecognizer{
                        let view = recognizer.view
                        if let cell = view?.superview?.superview?.superview as? TweetCell{
                            if let indexPath = userTweetsTableView.indexPath(for: cell) {
                                if let tweet = self.myTweets?[indexPath.row]{
                                    composeViewController.recepientTweetId = tweet.tweetId
                                    composeViewController.recepientUser = tweet.user
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
