//
//  TweetsViewController.swift
//  Twitter
//
//  Created by Satyam Jaiswal on 2/20/16.
//  Copyright © 2016 Satyam Jaiswal. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD

class TweetsViewController: UIViewController, BaseController, UITableViewDelegate, UIScrollViewDelegate, ComposeTweetDelegate {

    @IBOutlet weak var tweetsTableView: UITableView!
    @IBOutlet weak var menuBarButton: UIBarButtonItem!
    @IBOutlet weak var logoView: UIView!
    @IBOutlet weak var networkErrorImageView: UIImageView!
    @IBOutlet weak var ntwkErrStackView: UIStackView!
    
    
    var tweets: [Tweet]?
    var moreDataRequested: Bool = false
    var loadingMoreView:InfiniteScrollActivityView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.tweetsTableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupNetworkErrorView(){
        self.networkErrorImageView.alpha = 0
    }
    
    internal func setupGestureRecognizers(){
        let networkGesture = UITapGestureRecognizer()
        networkGesture.addTarget(self, action: #selector(onTapNetworkError))
        self.ntwkErrStackView.addGestureRecognizer(networkGesture)
        self.ntwkErrStackView.isUserInteractionEnabled = true
    }
    
    func onTapNetworkError(_ sender: AnyObject){
//        print("onTapNetworkError called")
        hideNetworkError()
        self.requestNetworkData()
    }
    
    func setupTableView(){
        tweetsTableView.dataSource = self
        tweetsTableView.delegate = self
        tweetsTableView.rowHeight = UITableViewAutomaticDimension
        tweetsTableView.estimatedRowHeight = 120
        self.tweetsTableView.tableFooterView = UIView()
    }
    
    internal func setupRefreshControl(){
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), for: UIControlEvents.valueChanged)
        tweetsTableView.insertSubview(refreshControl, at: 0)
    }
    
    func setupNavigationBar(){
        self.menuBarButton.target = self.revealViewController()
        self.menuBarButton.action = #selector(SWRevealViewController.revealToggle(_:))
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
    }
    
    func requestNetworkData(){
        self.showProgress()
        TwitterClient.sharedInstance?.homeTimeline({ (tweets:[Tweet]) -> () in
            if tweets.count > 0 {
                self.tweets = tweets
                self.updateTableView()
                self.hideProgress()
                
            }
            self.hideProgress()
            
        }) { (error: NSError) -> () in
            print("Error: \(error.localizedDescription)")
            self.hideProgress()
            if error.localizedDescription.contains("429"){
                self.requestCountExceeded()
            }else{
                self.showNetworkError()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.tweets == nil {
            return 0
        }else{
            return self.tweets!.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TweetCell", for: indexPath) as! TweetCell
        cell.tweet = self.tweets![indexPath.row]
        cell.delegate = self
        cell.accessoryType = .none
        return cell
    }
    
    internal func setupInfiniteScrollView(){
        // Set up Infinite Scroll loading indicator
        let frame = CGRect(x: 0, y: tweetsTableView.contentSize.height, width: tweetsTableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
        loadingMoreView = InfiniteScrollActivityView(frame: frame)
        loadingMoreView!.isHidden = true
        tweetsTableView.addSubview(loadingMoreView!)
        
        var insets = tweetsTableView.contentInset;
        insets.bottom += InfiniteScrollActivityView.defaultHeight;
        tweetsTableView.contentInset = insets
    }
    
    func refreshControlAction(_ refreshControl: UIRefreshControl){
        requestNetworkData()
        refreshControl.endRefreshing()
    }
    
    
    
    func showNetworkError(){
        UIView.animate(withDuration: 2, animations: {
            self.networkErrorImageView.alpha = 1.0
        })
    }
    
    func hideNetworkError(){
        UIView.animate(withDuration: 1, animations: {
            self.networkErrorImageView.alpha = 0.0
        })
    }
    
    func showProgress(){
        MBProgressHUD.showAdded(to: self.view, animated: true)
    }
    
    func hideProgress(){
        MBProgressHUD.hide(for: self.view, animated: true)
    }
    
    func requestCountExceeded(){
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud?.show(animated: true, whileExecuting: {
            hud?.labelText = "Request limit exceeded. Try again later."
        })
        hud?.hide(true, afterDelay: 1)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (!moreDataRequested){
            
            let scrollViewContentHeight = self.tweetsTableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - self.tweetsTableView.bounds.size.height
            
            if scrollView.contentOffset.y > scrollOffsetThreshold && tweetsTableView.isDragging {
                moreDataRequested = true
                
                // Update position of loadingMoreView, and start loading indicator
                let frame = CGRect(x: 0, y: tweetsTableView.contentSize.height, width: tweetsTableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
                if let progressView = self.loadingMoreView{
                    progressView.frame = frame
                    progressView.startAnimating()
                }
                loadMoreData()
            }
            
        }
    }
    
    func loadMoreData(){
        TwitterClient.sharedInstance?.homeTimelineOnScroll(self.getEarliestTweetId(), success: { (moreTweets: [Tweet]) in
            if moreTweets.count > 0 {
                self.tweets?.append(contentsOf: moreTweets)
                self.tweetsTableView.reloadData()
            }
            self.loadingMoreView?.stopAnimating()
            self.moreDataRequested = false
        }) { (error: NSError) in
            self.loadingMoreView?.stopAnimating()
            print("Error in loading more feeds: \(error.localizedDescription)")
        }

    }
    
    func onTapCellProfileImage(_ sender: AnyObject?){
        //print("onTapCellProfileImage")
        performSegue(withIdentifier: "showUserProfileSegue", sender: sender)
    }
    
    func onTapCellReply(_ sender: AnyObject?) {
        performSegue(withIdentifier: "tweetSegue", sender: sender)
    }
    
    func updateRetweetCount(of index: Int, when retweeted: Bool){
        if let tweets = self.tweets{
            if retweeted{
                tweets[index].retweeted = false
                tweets[index].retweet_count -= 1
                
            }else{
                tweets[index].retweeted = true
                tweets[index].retweet_count += 1
            }
            
            self.tweetsTableView.reloadData()
        }
    }
    
    func getCellIndex(of view: UIView) -> Int?{
        let pointInTable = view.convert(view.bounds.origin, to: self.tweetsTableView)
        let index = self.tweetsTableView.indexPathForRow(at: pointInTable)?.row
        return index
    }
    
    
    @IBAction func onComposeTapped(_ sender: Any) {
        performSegue(withIdentifier: "tweetSegue", sender: sender)
    }

    func onNewTweet(status: Tweet) {
        self.tweets?.insert(status, at: 0)
        self.tweetsTableView.reloadData()
    }
    
    func reload(_ sender: TweetCell) {
        if let indexPath = self.tweetsTableView.indexPath(for: sender){
            self.tweetsTableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.none)
        }
    }
    
    func updateTableView(){
        self.tweetsTableView.reloadData()
    }
    
        // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "TweetDetailsSegue"{
            if let detailsViewController = segue.destination as? TweetDetailsViewController {
                if let cell = sender as? TweetCell{
                    if let indexPath = tweetsTableView.indexPath(for: cell) {
                        detailsViewController.tweet = tweets![indexPath.row] as Tweet
                        detailsViewController.row = indexPath.row
                        let bgView = UIView()
                        bgView.backgroundColor = UIColor.gray
                        cell.selectedBackgroundView = bgView
                        tweetsTableView.deselectRow(at: indexPath, animated: true)
                    }
                }
            }
        } else if segue.identifier == "showUserProfileSegue" {
            if let profileViewController = segue.destination as? MeViewController {
                if let recog = sender as? UITapGestureRecognizer {
                    let view = recog.view
                    if let cell = view?.superview?.superview as? TweetCell {
                        if let indexPath = tweetsTableView.indexPath(for: cell) {
                            if let tweet = tweets?[indexPath.row] {
                                profileViewController.user = tweet.user
                            }
                        }
                    }
                }
            }
        } else if segue.identifier == "tweetSegue" {
            if let nc = segue.destination as? UINavigationController {
                if let composeViewController = nc.topViewController as? ComposeTweetViewController {
                    composeViewController.delegate = self
                    if let recognizer = sender as? UIGestureRecognizer{
                        let view = recognizer.view
                        if let cell = view?.superview?.superview?.superview as? TweetCell{
                            if let indexPath = tweetsTableView.indexPath(for: cell) {
                                if let tweet = tweets?[indexPath.row]{
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
