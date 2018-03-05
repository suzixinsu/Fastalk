//
//  Config.swift
//  Fastalk
//
//  Created by Dan Xu on 3/4/18.
//  Copyright © 2018 IOSGroup7. All rights reserved.
//

import Foundation

class Config: NSObject {
    fileprivate static let kUserIdKey = "userId"
    fileprivate static let kUsernameKey = "username"
    
    class func setUserId(_ userId:String) {
        UserDefaults.standard.set(userId, forKey: kUserIdKey)
        UserDefaults.standard.synchronize()
    }
    class func setUsername(_ username:String) {
        UserDefaults.standard.set(username, forKey: kUsernameKey)
        UserDefaults.standard.synchronize()
    }
    
    class func userId() -> String {
        return UserDefaults.standard.object(forKey: kUserIdKey) as! String
    }
    class func username() -> String {
        return UserDefaults.standard.object(forKey: kUsernameKey) as! String
    }
}
