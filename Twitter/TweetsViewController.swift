//
//  TweetsViewController.swift
//  Twitter
//
//  Created by Satyam Jaiswal on 2/20/16.
//  Copyright © 2016 Satyam Jaiswal. All rights reserved.
//

import UIKit
import AFNetworking

class TweetsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CellDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var menuBarButton: UIBarButtonItem!
    @IBOutlet weak var composeBarButton: UIBarButtonItem!
    
    var tweets: [Tweet]?
    var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.menuBarButton.target = self.revealViewController()
        self.menuBarButton.action = #selector(SWRevealViewController.revealToggle(_:))
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        
       self.composeBarButton.image = UIImage(named: "twitter_quill_30")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        navigationController?.navigationBar.barTintColor = UIColor(red: 0.2118, green: 0.549, blue: 0.7098, alpha: 1.0)
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
        print("onTapCellLike called")
        if let recognizer = sender as? UITapGestureRecognizer{
            let imageView = recognizer.view
            if let cellView = imageView?.superview?.superview as? TweetCell {
                let indexPath = self.tableView.indexPathForCell(cellView)
                if let row = indexPath?.row{
                    if let tweet = self.tweets?[row]{
                        if tweet.liked == true{
                            self.tweets![(indexPath?.row)!].liked = false
                        }else{
                            self.tweets![(indexPath?.row)!].liked = true
                        }
                        self.tableView.reloadData()
                    }
                }
                /*
                if ((self.tweets![(indexPath?.row)!].liked) != nil) {
                    self.tweets[indexPath.row].liked = false
                }else{
                    self.tweets[indexPath.row].liked = true
                }
                */
                
            }
        }
    }
    
    func onTapCellReply(sender: AnyObject?) {
    }
    
    func onTapCellRetweet(sender: AnyObject?) {
        
    }
    
    func refreshControlAction(refreshControl: UIRefreshControl){
        requestNetworkData()
        refreshControl.endRefreshing()
    }
    
    func requestNetworkData(){
        TwitterClient.sharedInstance.homeTimeline({ (tweets:[Tweet]) -> () in
            self.tweets = tweets
            self.tableView.reloadData()
            /*
            for tweet in tweets{
            print("Tweet: \(tweet.text)")
            print("Retweet count: \(tweet.retweet_count)")
            print("Likes: \(tweet.likes_count)")
            print("Date-Time: \(tweet.timestamp)")
            
            }*/
            }) { (error: NSError) -> () in
                print("Error: \(error.localizedDescription)")
        }
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
    

        // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "TweetDetailsSegue"{
            if let cell = sender as? TweetCell{
                let indexPath = tableView.indexPathForCell(cell)
                if let destinationViewController = segue.destinationViewController as? TweetDetailsViewController{
                    destinationViewController.tweet = self.tweets![indexPath!.row] as Tweet
                    
                    let bgView = UIView()
                    bgView.backgroundColor = UIColor.grayColor()
                    cell.selectedBackgroundView = bgView
                    
                    tableView.deselectRowAtIndexPath(indexPath!, animated: true)
                }
            }
        }
        
        if segue.identifier == "showUserProfileSegue" {
            if let destinationViewController = segue.destinationViewController as? MeViewController {
                destinationViewController.user = self.user
            }
        }
    }
    
    
    @IBAction func unwindToHomeTimeline(sender: UIStoryboardSegue) {
        print("inside unwindToHomeTimeline")
        let sourceViewController = sender.sourceViewController as? ComposeTweetViewController
        let newStatus = sourceViewController!.tweetTextView.text! as String
        print(newStatus)
        TwitterClient.sharedInstance.tweet("", status: newStatus ,success: { () -> () in
            
            sourceViewController!.tweetTextView.resignFirstResponder()
            }) { (error: NSError) -> () in
                print("Error in tweet reply: \(error.localizedDescription)")
        }
    }

}
