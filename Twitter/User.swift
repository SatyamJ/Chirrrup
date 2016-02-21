//
//  User.swift
//  Twitter
//
//  Created by Satyam Jaiswal on 2/20/16.
//  Copyright © 2016 Satyam Jaiswal. All rights reserved.
//

import UIKit

class User: NSObject {
    var name: NSString?
    var screen_name: NSString?
    var user_profile_image_url: NSURL?
    var tagline: NSString?
    
    var dictionary: NSDictionary?
    
    static var _currentUser: User?
    
    class var currentUser: User?{
        get{
            if(_currentUser == nil){
                let defaults = NSUserDefaults.standardUserDefaults()
                let userData = defaults.objectForKey("currentUser") as? NSData
                if let userData = userData{
                    let dictionary = try! NSJSONSerialization.JSONObjectWithData(userData, options: []) as! NSDictionary
                    _currentUser = User(user_dictionary: dictionary)
                }
            }
            return _currentUser
        }
        set(user){
            _currentUser = user
            let defaults = NSUserDefaults.standardUserDefaults()
            if let user = user {
                let data = try! NSJSONSerialization.dataWithJSONObject(user.dictionary!, options: [])
                defaults.setObject(data, forKey: "currentUser")
            }
            else{
                defaults.setObject(nil, forKey: "currentUser")
            }
            
            defaults.synchronize()
        }
    }
    
    init(user_dictionary: NSDictionary) {
        self.dictionary = user_dictionary
        
        name = user_dictionary["name"] as? String
        screen_name = user_dictionary["screen_name"] as? String
        if let user_profile_image_url_String = user_dictionary["profile_image_url_https"] as? String{
            user_profile_image_url = NSURL(string: user_profile_image_url_String)
        }
        tagline = user_dictionary["description"] as? String
    }
    

}
