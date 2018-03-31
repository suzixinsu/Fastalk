//
//  Message.swift
//  Fastalk
//
//  Created by Dan Xu on 3/31/18.
//  Copyright © 2018 IOSGroup7. All rights reserved.
//

import Foundation

internal class Message {
    internal let id: String
    internal let text: String
    
    init(id: String, text: String) {
        self.id = id
        self.text = text
    }
}
