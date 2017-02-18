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
            self.userProfileImageView.setImageWith(imageUrl as URL)
        }
        
        if let name = User.currentUser?.name as? String{
            self.usernameLabel.text = name
        }
        
        if let handle = User.currentUser?.screen_name as? String{
            self.userHandleLabel.text = "@\(handle)"
        }
    }
    /*
    override func viewDidAppear(animated: Bool) {
        let goToProfile = UITapGestureRecognizer(target: self, action: #selector(SlideoutMenuViewController.showMyProfile()))
    }
    */
    
    
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
    

}
