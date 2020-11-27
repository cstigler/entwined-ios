//
//  Effect.swift
//  Entwined
//
//  Created by Kyle Fleming on 10/28/14.
//  Copyright (c) 2014 Kyle Fleming. All rights reserved.
//

import UIKit

class Effect: NSObject {
    
    init(index: Int, name: String) {
        self.index = index
        self.name = name
    }
    
    let index: Int
    @objc dynamic let name: String
   
}
