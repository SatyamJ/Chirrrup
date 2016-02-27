//
//  TweetsViewController.swift
//  Twitter
//
//  Created by Satyam Jaiswal on 2/20/16.
//  Copyright © 2016 Satyam Jaiswal. All rights reserved.
//

import UIKit
import AFNetworking

class TweetsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var tweets: [Tweets]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Twitter Twitz"
        navigationController?.navigationBar.backgroundColor = UIColor.blackColor()
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.grayColor()]
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 120
        
        requestNetworkData()
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refreshControlAction:", forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)
        
        // Do any additional setup after loading the view.
    }
    
    func refreshControlAction(refreshControl: UIRefreshControl){
        requestNetworkData()
        refreshControl.endRefreshing()
    }
    
    func requestNetworkData(){
        TwitterClient.sharedInstance.homeTimeline({ (tweets:[Tweets]) -> () in
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
    

    @IBAction func onClickLogutButton(sender: AnyObject) {
        TwitterClient.sharedInstance.logout()
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
        //cell.table = self.tableView
        //cell.index = indexPath
        //cell.row = indexPath.row
        return cell
    }
    
    
    
    
    
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "TweetDetailsSegue"{
            let cell = sender as! TweetCell
            let indexPath = tableView.indexPathForCell(cell)
            
            let dvc = segue.destinationViewController as! TweetDetailsViewController
            
            //dvc.table = self.tableView
            dvc.tweet = self.tweets![indexPath!.row] as Tweets
            //print(self.tweets![indexPath!.row].username)
            
            let bgView = UIView()
            bgView.backgroundColor = UIColor.grayColor()
            cell.selectedBackgroundView = bgView

            tableView.deselectRowAtIndexPath(indexPath!, animated: true)
        }
    }

}
