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
    
    var tweets: [Tweets]?
    var user: User?
    var owner = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.revealViewController() == nil {
            print("revealViewController is nil")
        }
        self.menuBarButton.target = self.revealViewController()
        self.menuBarButton.action = #selector(SWRevealViewController.revealToggle(_:))
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        
       self.composeBarButton.image = UIImage(named: "twitter_quill_30")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        //navigationController?.navigationBar.backgroundColor = UIColor.blueColor()
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
        self.owner = false
        let recog = sender as! UITapGestureRecognizer
        let view = recog.view
        let cell = view!.superview?.superview as! TweetCell
        let indexPath = tableView.indexPathForCell(cell)
        self.user = tweets![indexPath!.row].user
        performSegueWithIdentifier("mePushSegue", sender: nil)
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
        cell.delegate = self
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
        
        if segue.identifier == "mePushSegue" {
            
            let dvc = segue.destinationViewController as! MeViewController
            if owner{
                dvc.user = User.currentUser
                dvc.title = "Me"
            }else{
                dvc.user = self.user
                owner = true
                dvc.title = self.user?.name as? String ?? ""
            }
        }
    }
    
    
    @IBAction func unwindToHomeTimeline(sender: UIStoryboardSegue) {
        print("inside unwindToHomeTimeline")
        /*if let sourceViewController = sender.sourceViewController as? MealViewController, meal = sourceViewController.meal {
            // Add a new meal.
            let newIndexPath = NSIndexPath(forRow: meals.count, inSection: 0)
            meals.append(meal)
            tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Bottom)
        }*/
        let sourceViewController = sender.sourceViewController as? ComposeTweetViewController
        let newStatus = sourceViewController!.newTweetTextField.text! as String
        print(newStatus)
        TwitterClient.sharedInstance.replyToTweet("", status: newStatus ,success: { () -> () in
            
            sourceViewController!.newTweetTextField.resignFirstResponder()
            }) { (error: NSError) -> () in
                print("Error in tweet reply: \(error.localizedDescription)")
        }
    }

}
