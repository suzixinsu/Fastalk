//
//  Chat.swift
//  Fastalk
//
//  Created by Dan Xu on 3/3/18.
//  Copyright © 2018 IOSGroup7. All rights reserved.
//

import Foundation

internal class Chat {
    internal let id: String
    internal let receiverId: String
    internal let receiverName: String
    internal var timeStamp: String
    internal var lastMessage: String
    
    init(id: String, receiverId: String, receiverName: String, lastMessage: String, timeStamp: String) {
        self.id = id
        self.receiverId = receiverId
        self.receiverName = receiverName
        self.lastMessage = lastMessage
        self.timeStamp = timeStamp
    }
    
    func setLastMessage(_ lastMessage: String) {
        self.lastMessage = lastMessage
    }
    
    func setTimeStamp(_ timeStamp: String) {
        self.timeStamp = timeStamp
    }
}
