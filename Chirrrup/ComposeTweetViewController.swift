//
//  ComposeTweetViewController.swift
//  Twitter
//
//  Created by Satyam Jaiswal on 2/29/16.
//  Copyright © 2016 Satyam Jaiswal. All rights reserved.
//

import UIKit
import MBProgressHUD

protocol ComposeTweetDelegate{
    func onNewTweet(status: Tweet)
}

class ComposeTweetViewController: UIViewController, UITextViewDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var tweetTextView: UITextView!
    @IBOutlet weak var userProfileImageView: UIImageView!
    @IBOutlet weak var replyInfoLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var handleLabel: UILabel!
    
    let tweetButton = UIButton(type: UIButtonType.system)
    var placeholderLabel : UILabel!
    let characterCountLabel = UILabel()

    var recepientTweetId: String?
    var recepientUser: User?
    var delegate: ComposeTweetDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupNavigationBar()
        self.setupUserFields()
        configureTextView()
    }
    
    override func viewDidAppear(_ animated: Bool) {

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupUserFields(){
        if let user = User.currentUser{
            if let profileImageUrl = user.user_profile_image_url{
                self.userProfileImageView.setImageWith(profileImageUrl)
            }
            self.userProfileImageView.layer.cornerRadius = 5
            self.userProfileImageView.layer.masksToBounds = true
            
            if let name = user.name{
                self.nameLabel.text = name
            }
            
            if let handle = user.screen_name{
                self.handleLabel.text = "@\(handle)"
            }
        }
        
        let tweetCharacterCount = NSString(string: self.tweetTextView.text).length
        self.characterCountLabel.text = "\(140 - tweetCharacterCount)"
    }
    
    func setupNavigationBar(){
        navigationController?.delegate = self
        
        let customView = UIView()
        customView.frame = CGRect(x: 0, y: 0, width: 100, height: 30)
        
        // character count
        self.characterCountLabel.frame = CGRect(x: 0, y: 0, width: 30, height: 25)
        self.characterCountLabel.text = "140"
        self.characterCountLabel.textColor = UIColor.gray
        customView.addSubview(characterCountLabel)
        
        // tweet button
        self.tweetButton.isEnabled = false
        self.tweetButton.setTitle("Tweet", for: UIControlState.normal)
        self.tweetButton.frame = CGRect(x: 45, y: 0, width: 50, height: 25)
        self.tweetButton.addTarget(self, action: #selector(onTweetTapped(_:)), for: UIControlEvents.touchDown)
        self.tweetButton.isUserInteractionEnabled = true
        customView.addSubview(tweetButton)
        
        let rightBarButton = UIBarButtonItem()
        rightBarButton.customView = customView
        
        self.navigationItem.rightBarButtonItem = rightBarButton
    }
    
    func configureTextView(){
        if let listener = self.recepientUser{
            if let handle = listener.screen_name {
                tweetTextView.text = "@\(handle)"
                self.replyInfoLabel.isHidden = false
                self.replyInfoLabel.text = "in reply to @\(handle)"
            }
        }else {
            tweetTextView.text = ""
            self.replyInfoLabel.isHidden = true
        }
        
        tweetTextView.delegate = self
        placeholderLabel = UILabel()
        placeholderLabel.text = "What's happening today?"
        placeholderLabel.font = UIFont.italicSystemFont(ofSize: tweetTextView.font!.pointSize)
        placeholderLabel.sizeToFit()
        tweetTextView.addSubview(placeholderLabel)
        placeholderLabel.frame.origin = CGPoint(x: 5, y: tweetTextView.font!.pointSize / 2)
        placeholderLabel.textColor = UIColor(white: 0, alpha: 0.3)
        
        placeholderLabel.isHidden = !tweetTextView.text.isEmpty
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.isEmpty {
            placeholderLabel.isHidden = false
            self.tweetButton.isEnabled = false
        }else{
            placeholderLabel.isHidden = true
            self.tweetButton.isEnabled = true
        }
        
        let characterleft = 140 - NSString(string: textView.text).length
        self.characterCountLabel.text = "\(characterleft)"
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return NSString(string: textView.text).length + (NSString(string: text).length - range.length) <= 140
    }
    
    func onTweetTapped(_ sender: Any){
        print("tweet tapped")
        self.tweetTextView.resignFirstResponder()
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud?.mode = MBProgressHUDMode.text
        
        
        if let statusText = self.tweetTextView.text{
            if !statusText.isEmpty{
                hud?.labelText = "Posting..."
                if let statusId = self.recepientTweetId{
                    
                    TwitterClient.sharedInstance?.replyToStatus(status: statusText, id: statusId, success: { (dictionary:NSDictionary) in
                        self.delegate?.onNewTweet(status: Tweet(tweet_dictionary: dictionary))
                        self.dismiss(animated: true, completion: nil)
                        hud?.labelText = "Post successful!"
                        MBProgressHUD.hide(for: self.view, animated: true)
                    }, failure: { (error: Error) in
                        print("Error on replying to tweet: \(error.localizedDescription)")
                        hud?.labelText = "Error occured while posting. Try later"
                        MBProgressHUD.hide(for: self.view, animated: true)
                    })
                }else{
                    TwitterClient.sharedInstance?.composeNewTweet(status: statusText, success: { (dictionary: NSDictionary) in
                        self.delegate?.onNewTweet(status: Tweet(tweet_dictionary: dictionary))
                        self.dismiss(animated: true, completion: nil)
                        hud?.labelText = "Post successful!"
                        MBProgressHUD.hide(for: self.view, animated: true)
                    }, failure: { (error: Error) in
                        print("Error on posting new tweet: \(error.localizedDescription)")
                        hud?.labelText = "Error occured while posting. Try later"
                        MBProgressHUD.hide(for: self.view, animated: true)
                    })
                }
            }
        }
    }
    
    @IBAction func onCancelTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("prepare for segue of Compose tweet vc called")
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
 

}
