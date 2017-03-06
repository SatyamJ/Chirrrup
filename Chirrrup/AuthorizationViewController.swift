//
//  AuthorizationViewController.swift
//  Chirrrup
//
//  Created by Satyam Jaiswal on 3/1/17.
//  Copyright © 2017 Satyam Jaiswal. All rights reserved.
//

import UIKit

class AuthorizationViewController: UIViewController {

    @IBOutlet weak var authorizationWebView: UIWebView!
    
    var loadUrl: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "Authorization_successful"), object: nil, queue: OperationQueue.main) { (Notification) in
            self.dismiss(animated: true, completion: nil)
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "Authorization_failed"), object: nil, queue: OperationQueue.main) { (Notification) in
            self.dismiss(animated: true, completion: nil)
        }
        
        if let url = self.loadUrl{
            self.authorizationWebView.loadRequest(URLRequest(url: url))
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onCancelTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
