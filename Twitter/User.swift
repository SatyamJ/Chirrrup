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
    
    init(user_dictionary: NSDictionary) {
        name = user_dictionary["name"] as? String
        screen_name = user_dictionary["screen_name"] as? String
        if let user_profile_image_url_String = user_dictionary["profile_image_url_https"] as? String{
            user_profile_image_url = NSURL(string: user_profile_image_url_String)
        }
        tagline = user_dictionary["description"] as? String
    }

}
