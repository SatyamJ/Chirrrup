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
        self.setupUserFields()
    }
    /*
    override func viewDidAppear(animated: Bool) {
        let goToProfile = UITapGestureRecognizer(target: self, action: #selector(SlideoutMenuViewController.showMyProfile()))
    }
    */
    
    fileprivate func setupUserFields(){
        if let user = User.currentUser{
            if let imageUrl = user.user_profile_image_url{
                self.userProfileImageView.setImageWith(imageUrl as URL)
                self.loadHigherResolutionImage(url: imageUrl, imageView: userProfileImageView)
            }
            self.userProfileImageView.layer.cornerRadius = 25
            self.userProfileImageView.layer.masksToBounds = true
            
            if let name = user.name{
                self.usernameLabel.text = name
            }
            
            if let handle = user.screen_name{
                self.userHandleLabel.text = "@\(handle)"
            }
        }
    }
    
    @IBAction func showMyProfile(_ sender: AnyObject) {
        performSegue(withIdentifier: "showMyProfileSegue", sender: nil)
    }
    
    
    @IBAction func goToHome(_ sender: AnyObject) {
        performSegue(withIdentifier: "homeSegue", sender: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onSignOut(_ sender: AnyObject) {
        TwitterClient.sharedInstance?.logout()
        self.dismiss(animated: true, completion: nil)
    }
    
    fileprivate func loadHigherResolutionImage(url: URL, imageView: UIImageView) -> Void{
        let hrStringUrl = url.absoluteString.replacingOccurrences(of: "_normal", with: "")
        if let hRUrl = URL(string: hrStringUrl){
            imageView.setImageWith(hRUrl)
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "showMyProfileSegue" {
            let destinationNavigationController = segue.destination as? UINavigationController
            let target = destinationNavigationController?.topViewController as? MeViewController
            if let vc = target {
                vc.user = User.currentUser
            }
        }
    }
    */

}
