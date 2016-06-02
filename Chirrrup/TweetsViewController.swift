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

class TweetsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CellDelegate, UIScrollViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var menuBarButton: UIBarButtonItem!
    @IBOutlet weak var composeBarButton: UIBarButtonItem!
    @IBOutlet weak var logoView: UIView!
    
    var tweets: [Tweet]?
    var user: User?
    var moreDataRequested: Bool = false
    var loadingMoreView:InfiniteScrollActivityView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.menuBarButton.target = self.revealViewController()
        self.menuBarButton.action = #selector(SWRevealViewController.revealToggle(_:))
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        
        self.composeBarButton.image = UIImage(named: "twitter_quill_30")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        //navigationController?.navigationBar.barTintColor = UIColor(red: 0.2118, green: 0.549, blue: 0.7098, alpha: 1.0)
        navigationController?.navigationBar.barTintColor = UIColor(red: 0.2, green: 0.5, blue: 0.7, alpha: 1.0)
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 120
        
        requestNetworkData()
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(TweetsViewController.refreshControlAction(_:)), forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)
        
        setupInfiniteScrollView()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        self.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let tweets = tweets {
            return tweets.count
        }else{
            return 0
        }
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TweetCell", forIndexPath: indexPath) as! TweetCell
        cell.tweet = self.tweets![indexPath.row]
        cell.delegate = self
        return cell
    }
    
    func setupInfiniteScrollView(){
        // Set up Infinite Scroll loading indicator
        let frame = CGRectMake(0, tableView.contentSize.height, tableView.bounds.size.width, InfiniteScrollActivityView.defaultHeight)
        loadingMoreView = InfiniteScrollActivityView(frame: frame)
        loadingMoreView!.hidden = true
        tableView.addSubview(loadingMoreView!)
        
        var insets = tableView.contentInset;
        insets.bottom += InfiniteScrollActivityView.defaultHeight;
        tableView.contentInset = insets
    }
    
    func refreshControlAction(refreshControl: UIRefreshControl){
        requestNetworkData()
        refreshControl.endRefreshing()
    }
    
    func requestNetworkData(){
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        TwitterClient.sharedInstance.homeTimeline({ (tweets:[Tweet]) -> () in
            self.tweets = tweets
            self.tableView.reloadData()
            MBProgressHUD.hideHUDForView(self.view, animated: true)
        }) { (error: NSError) -> () in
            print("Error: \(error.localizedDescription)")
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if (!moreDataRequested){
            
            let scrollViewContentHeight = self.tableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - self.tableView.bounds.size.height
            
            if scrollView.contentOffset.y > scrollOffsetThreshold && tableView.dragging {
                moreDataRequested = true
                
                // Update position of loadingMoreView, and start loading indicator
                let frame = CGRectMake(0, tableView.contentSize.height, tableView.bounds.size.width, InfiniteScrollActivityView.defaultHeight)
                loadingMoreView?.frame = frame
                loadingMoreView!.startAnimating()
                
                loadMoreData()
            }
            
        }
    }
    
    func loadMoreData(){
        if let lastTweetId = Int((self.tweets?.last?.tweetId)! as String){
            TwitterClient.sharedInstance.homeTimelineOnScroll(lastTweetId-1, success: { (moreTweets: [Tweet]) in
                self.tweets?.appendContentsOf(moreTweets)
                self.loadingMoreView!.stopAnimating()
                self.tableView.reloadData()
                self.moreDataRequested = false
            }) { (error: NSError) in
                print("Error in loading more feeds: \(error.localizedDescription)")
            }
        }
    }
    
    func onTapCellProfileImage(sender: AnyObject?){
        //print("onTapCellProfileImage")
        let recog = sender as! UITapGestureRecognizer
        let view = recog.view
        let cell = view!.superview?.superview as! TweetCell
        let indexPath = tableView.indexPathForCell(cell)
        self.user = tweets![indexPath!.row].user
        performSegueWithIdentifier("showUserProfileSegue", sender: nil)
    }
    
    func onTapCellLike(sender: AnyObject?) {
        //print("onTapCellLike called")
        if let recognizer = sender as? UITapGestureRecognizer{
            let imageView = recognizer.view
            if let cellView = imageView?.superview?.superview as? TweetCell {
                let indexPath = self.tableView.indexPathForCell(cellView)
                if let row = indexPath?.row{
                    if let tweet = self.tweets?[row]{
                        //print("processing tweet id: \(tweet.tweetId)")
                        if tweet.liked == true{
                            //self.tweets![(indexPath?.row)!].liked = false
                            TwitterClient.sharedInstance.unlike(String(tweet.tweetId!),
                                success: { () -> () in
                                    self.tweets![(indexPath?.row)!].liked = false
                                    self.tweets![(indexPath?.row)!].likes_count -= 1
                                    self.tableView.reloadData()
                                }, failure: { (error: NSError) -> () in
                                    print("Tweet Unlike error: \(error.localizedDescription)")
                            })
                        }else{
                            //self.tweets![(indexPath?.row)!].liked = true
                            TwitterClient.sharedInstance.like(String(tweet.tweetId!),
                                success: { () -> () in
                                    self.tweets![(indexPath?.row)!].liked = true
                                    self.tweets![(indexPath?.row)!].likes_count += 1
                                    self.tableView.reloadData()
                                }, failure: { (error: NSError) -> () in
                                    print("Tweet Like error: \(error.localizedDescription)")
                            })
                        }
                    }
                }
            }
        }
    }
    
    func onTapCellReply(sender: AnyObject?) {
        performSegueWithIdentifier("tweetSegue", sender: sender)
    }
    
    func onTapCellRetweet(sender: AnyObject?) {
        //print("onTapCellRetweet called")
        if let recognizer = sender as? UITapGestureRecognizer{
            let imageView = recognizer.view
            if let cellView = imageView?.superview?.superview as? TweetCell {
                let indexPath = self.tableView.indexPathForCell(cellView)
                if let row = indexPath?.row{
                    if let tweet = self.tweets?[row]{
                        //print("processing tweet id: \(tweet.tweetId!)")
                        if tweet.retweeted == true{
                            TwitterClient.sharedInstance.unretweet(String(tweet.tweetId!),
                                success: { () -> () in
                                    self.tweets![(indexPath?.row)!].retweeted = false
                                    self.tweets![(indexPath?.row)!].retweet_count -= 1
                                    self.tableView.reloadData()
                                }, failure: { (error: NSError) -> () in
                                    print("Un-retweet error: \(error.localizedDescription)")
                            })
                        }else{
                            TwitterClient.sharedInstance.retweet(String(tweet.tweetId!),
                              success: { () -> () in
                                self.tweets![(indexPath?.row)!].retweeted = true
                                self.tweets![(indexPath?.row)!].retweet_count += 1
                                self.tableView.reloadData()
                                }, failure: { (error: NSError) -> () in
                                    print("Retweet error: \(error.localizedDescription)")
                            })
                        }
                    }
                }
            }
        }
    }
    

        // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "TweetDetailsSegue"{
            if let cell = sender as? TweetCell{
                let indexPath = tableView.indexPathForCell(cell)
                if let destinationViewController = segue.destinationViewController as? TweetDetailsViewController{
                    destinationViewController.tweet = self.tweets![indexPath!.row] as Tweet
                    destinationViewController.row = indexPath!.row
                    let bgView = UIView()
                    bgView.backgroundColor = UIColor.grayColor()
                    cell.selectedBackgroundView = bgView
                    
                    tableView.deselectRowAtIndexPath(indexPath!, animated: true)
                }
            }
        } else if segue.identifier == "showUserProfileSegue" {
            if let destinationViewController = segue.destinationViewController as? MeViewController {
                destinationViewController.user = self.user
            }
        } else if segue.identifier == "tweetSegue" {
            if let recognizer = sender as? UIGestureRecognizer{
                let view = recognizer.view
                if let cell = view?.superview?.superview as? TweetCell{
                    let indexPath = tableView.indexPathForCell(cell)
                    if let destinationViewController = segue.destinationViewController as? ComposeTweetViewController{
                        destinationViewController.tweetId = String(tweets![(indexPath?.row)!].tweetId!)
                        destinationViewController.replyTo = String(tweets![(indexPath?.row)!].user_screenname!)
                        destinationViewController.tweets = self.tweets
                    }
                }
            }else{
                if let destinationViewController = segue.destinationViewController as? ComposeTweetViewController{
                    //print("segue for new tweet")
                    destinationViewController.tweetId = ""
                    destinationViewController.replyTo = ""
                    destinationViewController.temp = self.tweets![0]
                }
            }
        }
    }
}
