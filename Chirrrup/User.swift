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
    var user_profile_image_url: URL?
    var tagline: NSString?
    var profile_banner_url: URL?
    var tweetsCount: String?
    var followersCount: String?
    var followingCount: String?
    
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
                //defaults.arrayForKey(<#T##defaultName: String##String#>)
            }
            else{
                defaults.removeObject(forKey: "currentUser")
            }
            
            defaults.synchronize()
        }
    }
    
    init(user_dictionary: NSDictionary) {
        
        self.dictionary = user_dictionary
        
        name = user_dictionary["name"] as? String as NSString?
        
        screen_name = user_dictionary["screen_name"] as? String as NSString?
        
        if let user_profile_image_url_String = user_dictionary["profile_image_url_https"] as? String{
            user_profile_image_url = URL(string: user_profile_image_url_String)
        }
        
        tagline = user_dictionary["description"] as? String as NSString?
        
        if let profile_banner_url = user_dictionary["profile_banner_url"] as? String{
            self.profile_banner_url = URL(string: profile_banner_url)
        }
        
        if let tweets_count = user_dictionary["statuses_count"]{
            self.tweetsCount = "\(tweets_count)"
        }
        
        if let followers_count = user_dictionary["followers_count"]{
            self.followersCount = "\(followers_count)"
        }
        
        if let following_count = user_dictionary["friends_count"]{
            self.followingCount = "\(following_count )"
        }
    }
    

}
