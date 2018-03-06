//
//  User.swift
//  Fastalk
//
//  Created by Dan Xu on 3/6/18.
//  Copyright © 2018 IOSGroup7. All rights reserved.
//

import Foundation

internal class User {
    internal let username: String
    internal let userId: String
    
    init(username: String, userId: String) {
        self.username = username
        self.userId = userId
    }
}
