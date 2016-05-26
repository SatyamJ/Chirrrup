//
//  SlideoutMenuViewController.swift
//  Twitter
//
//  Created by Satyam Jaiswal on 5/23/16.
//  Copyright © 2016 Satyam Jaiswal. All rights reserved.
//

import UIKit

class SlideoutMenuViewController: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var userProfileImageView: UIImageView!
    
    @IBOutlet weak var usernameLabel: UILabel!

    @IBOutlet weak var userHandleLabel: UILabel!
    
    @IBOutlet weak var signoutButton: UIButton!
    
    @IBOutlet weak var visitProfileView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let imageUrl = User.currentUser?.user_profile_image_url{
            self.userProfileImageView.setImageWithURL(imageUrl)
        }
        
        if let name = User.currentUser?.name as? String{
            self.usernameLabel.text = name
        }
        
        if let handle = User.currentUser?.screen_name as? String{
            self.userHandleLabel.text = handle
        }
        /*
        let tap = UITapGestureRecognizer(target: self, action: #selector(SlideoutMenuViewController.showMyProfile()))
        tap.delegate = self
        self.visitProfileView.addGestureRecognizer(tap)
        */
        //let goToProfile = UITapGestureRecognizer(target: self, action: #selector(SlideoutMenuViewController))
        //self.retweetImage.addGestureRecognizer(tapRetweet)
        //self.retweetImage.userInteractionEnabled = true
        
        
    }
    /*
    override func viewDidAppear(animated: Bool) {
        let goToProfile = UITapGestureRecognizer(target: self, action: #selector(SlideoutMenuViewController.showMyProfile()))
    }
    */
    
    
    @IBAction func showMyProfile(sender: AnyObject) {
        performSegueWithIdentifier("showMyProfileSegue", sender: nil)
    }
    
    
    @IBAction func goToHome(sender: AnyObject) {
        performSegueWithIdentifier("homeSegue", sender: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onSignOut(sender: AnyObject) {
        TwitterClient.sharedInstance.logout()
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "showMyProfileSegue" {
            let destinationNavigationController = segue.destinationViewController as? UINavigationController
            let target = destinationNavigationController?.topViewController as? MeViewController
            if let vc = target {
                vc.user = User.currentUser
            }
        }
    }
    

}
