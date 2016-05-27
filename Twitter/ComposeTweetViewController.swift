//
//  ComposeTweetViewController.swift
//  Twitter
//
//  Created by Satyam Jaiswal on 2/29/16.
//  Copyright © 2016 Satyam Jaiswal. All rights reserved.
//

import UIKit

class ComposeTweetViewController: UIViewController, UITextViewDelegate {

    
    
    @IBOutlet weak var tweetTextView: UITextView!
    
    @IBOutlet weak var userProfileImageView: UIImageView!
    
    @IBOutlet weak var characterCountLabel: UILabel!
    
    var placeholderLabel : UILabel!
    
    //var newStatus: String?
    
    var tweetId: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.userProfileImageView.setImageWithURL((User.currentUser?.user_profile_image_url)!)

        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        tweetTextView.delegate = self
        placeholderLabel = UILabel()
        placeholderLabel.text = "What's happening today?"
        placeholderLabel.font = UIFont.italicSystemFontOfSize(tweetTextView.font!.pointSize)
        placeholderLabel.sizeToFit()
        tweetTextView.addSubview(placeholderLabel)
        placeholderLabel.frame.origin = CGPointMake(5, tweetTextView.font!.pointSize / 2)
        placeholderLabel.textColor = UIColor(white: 0, alpha: 0.3)
        
        placeholderLabel.hidden = !tweetTextView.text.isEmpty
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func textViewDidChange(textView: UITextView) {
        placeholderLabel.hidden = !textView.text.isEmpty
    }
    /*
    func textViewDidBeginEditing(textView: UITextView) {
        placeholderLabel.font = UIFont.systemFontOfSize(12)
        placeholderLabel.sizeToFit()
    }
    */
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
    
    @IBAction func onTapTweetButton(sender: AnyObject) {
        let status = self.tweetTextView.text
        print(status)
        
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
