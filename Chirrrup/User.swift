//
//  User.swift
//  Twitter
//
//  Created by Satyam Jaiswal on 2/20/16.
//  Copyright © 2016 Satyam Jaiswal. All rights reserved.
//

import UIKit

class User: NSObject {
    var name: String?
    var screen_name: String?
    var user_profile_image_url: URL?
    var tagline: String?
    var profile_banner_url: URL?
    var tweetsCount: Int?
    var followersCount: Int?
    var followingCount: Int?
    
    var dictionary: NSDictionary?
    
    static var _currentUser: User?
    
    class var currentUser: User?{
        get{
            if(_currentUser == nil){
                let defaults = UserDefaults.standard
                let userData = defaults.object(forKey: "currentUser") as? Data
                if let userData = userData{
                    let dictionary = try! JSONSerialization.jsonObject(with: userData, options: []) as! NSDictionary
                    _currentUser = User(user_dictionary: dictionary)
                }
            }
            return _currentUser
        }
        set(user){
            _currentUser = user
            let defaults = UserDefaults.standard
            if let user = user {
                let data = try! JSONSerialization.data(withJSONObject: user.dictionary!, options: [])
                defaults.set(data, forKey: "currentUser")
            }
            else{
                defaults.removeObject(forKey: "currentUser")
            }
            
            defaults.synchronize()
        }
    }
    
    init(user_dictionary: NSDictionary) {
        
        self.dictionary = user_dictionary
        
        name = user_dictionary.value(forKey: "name") as? String
        
        screen_name = user_dictionary.value(forKey: "screen_name") as? String
        
        if let user_profile_image_url_String = user_dictionary["profile_image_url_https"] as? String{
            user_profile_image_url = URL(string: user_profile_image_url_String)
        }
        
        tagline = user_dictionary["description"] as? String
        
        if let profile_banner_url = user_dictionary["profile_banner_url"] as? String{
            self.profile_banner_url = URL(string: profile_banner_url)
        }
        
        if let tweets_count = user_dictionary.value(forKey: "statuses_count") as? Int{
            self.tweetsCount = tweets_count
        }
        
        if let followers_count = user_dictionary.value(forKey: "followers_count") as? Int{
            self.followersCount = followers_count
        }
        
        if let following_count = user_dictionary.value(forKey: "friends_count") as? Int{
            self.followingCount = following_count
        }
    }
    

}
