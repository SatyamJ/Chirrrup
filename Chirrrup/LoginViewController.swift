//
//  LoginViewController.swift
//  Twitter
//
//  Created by Satyam Jaiswal on 2/20/16.
//  Copyright © 2016 Satyam Jaiswal. All rights reserved.
//

import UIKit
import BDBOAuth1Manager

class LoginViewController: UIViewController {

    var authorizationUrl: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
  
    @IBAction func onClickLoginButton(_ sender: AnyObject) {
        
        self.setupCallbacks()
        
        TwitterClient.sharedInstance?.getRequestToken(success: { (requestToken: BDBOAuth1Credential) in
            if let oauth_token = requestToken.token{
                if let authorizeUrl = URL(string: "https://api.twitter.com/oauth/authorize?oauth_token=\(oauth_token)"){
                    self.authorizationUrl = authorizeUrl
                    self.performSegue(withIdentifier: "authorizationSegue", sender: sender)
                }else{
                    print("Can't open web view! Invalid authorization url.")
                }
            }
        }, failure: { (error: Error) in
            print("Error fetching request token: \(error.localizedDescription)")
        })
    }
    
    func setupCallbacks(){
        TwitterClient.sharedInstance?.setupLoginCallbacks(success: {
            self.performSegue(withIdentifier: "loginSegue", sender: self)
            
        }, failure: { (error: Error) in
            print(error.localizedDescription)
        })
    }

    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "authorizationSegue"{
            if let nc = segue.destination as? UINavigationController{
                if let vc = nc.topViewController as? AuthorizationViewController{
                    vc.loadUrl = self.authorizationUrl
                }
            }
        }
    }
}
