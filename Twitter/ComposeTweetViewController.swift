//
//  ComposeTweetViewController.swift
//  Twitter
//
//  Created by Satyam Jaiswal on 2/29/16.
//  Copyright © 2016 Satyam Jaiswal. All rights reserved.
//

import UIKit
import MBProgressHUD

class ComposeTweetViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var tweetTextView: UITextView!
    
    @IBOutlet weak var userProfileImageView: UIImageView!
    
    @IBOutlet weak var characterCountLabel: UILabel!
    
    @IBOutlet weak var replyInfoLabel: UILabel!
    
    var placeholderLabel : UILabel!
    
    //var newStatus: String?
    
    var tweetId: String?
    var replyTo: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.userProfileImageView.setImageWithURL((User.currentUser?.user_profile_image_url)!)

        navigationController?.navigationBar.barTintColor = UIColor(red: 0.2, green: 0.5, blue: 0.7, alpha: 1.0)
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        configureTextView()
        
        let tweetCharacterCount = NSString(string: self.tweetTextView.text).length
        self.characterCountLabel.text = "\(140 - tweetCharacterCount)"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configureTextView(){
        if let listener = replyTo{
            if listener.isEmpty{
                tweetTextView.text = ""
                self.replyInfoLabel.hidden = true
            }else{
                tweetTextView.text = "@\(listener)"
                self.replyInfoLabel.hidden = false
                self.replyInfoLabel.text = "in reply to @\(listener)"
            }
        }
        
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
    
    func textViewDidChange(textView: UITextView) {
        placeholderLabel.hidden = !textView.text.isEmpty
        let characterleft = 140 - NSString(string: textView.text).length
        self.characterCountLabel.text = "\(characterleft)"
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        return NSString(string: textView.text).length + (NSString(string: text).length - range.length) <= 140
    }
    
    @IBAction func onTapTweetButton(sender: AnyObject) {
        self.tweetTextView.resignFirstResponder()
        let hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        hud.mode = MBProgressHUDMode.Text
        hud.labelText = "Posting..."
        let status = self.tweetTextView.text
        //print(status)
        TwitterClient.sharedInstance.tweet(self.tweetId!, status: status ,success: { () -> () in
            hud.labelText = "Post successful!"
            self.tweetTextView.text = ""
            self.replyInfoLabel.hidden = true
            self.placeholderLabel.hidden = false
            MBProgressHUD.hideHUDForView(self.view, animated: true)
        }) { (error: NSError) -> () in
            print("Error in tweet reply: \(error.localizedDescription)")
        }
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
