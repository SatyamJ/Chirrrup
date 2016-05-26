//
//  ComposeTweetViewController.swift
//  Twitter
//
//  Created by Satyam Jaiswal on 2/29/16.
//  Copyright © 2016 Satyam Jaiswal. All rights reserved.
//

import UIKit

class ComposeTweetViewController: UIViewController {

    
    @IBOutlet weak var newTweetTextField: UITextField!
    
    @IBOutlet weak var userProfileImageView: UIImageView!
    
    var newStatus: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.userProfileImageView.setImageWithURL((User.currentUser?.user_profile_image_url)!)

        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func onClickTweetButton(sender: AnyObject) {
        /*
        self.newStatus = self.newTweetTextField.text! as String
        print(status)
        TwitterClient.sharedInstance.replyToTweet("", status: status ,success: { () -> () in
            
            self.newTweetTextField.resignFirstResponder()
            }) { (error: NSError) -> () in
                print("Error in tweet reply: \(error.localizedDescription)")
        }*/
        
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
