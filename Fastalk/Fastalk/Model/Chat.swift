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
    internal let title: String
    internal let timeStamp: String
    
    init(id: String, title: String, timeStamp: String) {
        self.id = id
        self.title = title
        self.timeStamp = timeStamp
    }
}
