//
//  Constants.swift
//  Fastalk
//
//  Created by Dan Xu on 2/25/18.
//  Copyright © 2018 IOSGroup7. All rights reserved.
//

import Foundation
import Firebase

struct Constants
{
    struct refs
    {
        static let databaseRoot = Database.database().reference()
        static let databaseMessages = databaseRoot.child("messages")
        static let databaseUsers = databaseRoot.child("users")
        static let databaseChats = databaseUsers.child("chats")
        //static let databaseChannels = databaseRoot.child("groups")
    }
}
