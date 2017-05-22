//
//  ProfileViewController.swift
//  Chirrrup
//
//  Created by Satyam Jaiswal on 5/19/17.
//  Copyright © 2017 Satyam Jaiswal. All rights reserved.
//

import UIKit

class ProfileViewController: TweetsViewController {

    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.tweetsTableView = UITableView(frame: UIScreen.main.bounds, style: UITableViewStyle.plain)
        tweetsTableView = self.tableView
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func setupNavigationBar(){
        
    }
    
    /*
    override func setupTableView(){
        tweetsTableView.dataSource = self
        tweetsTableView.delegate = self
        tweetsTableView.rowHeight = UITableViewAutomaticDimension
        tweetsTableView.estimatedRowHeight = 120
        self.tweetsTableView.tableFooterView = UIView()
    }
    */
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
