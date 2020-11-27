//
//  Model.swift
//  Entwined
//
//  Created by Kyle Fleming on 10/27/14.
//  Copyright (c) 2014 Kyle Fleming. All rights reserved.
//

import UIKit

class Model: NSObject {
    
    class var sharedInstance : Model {
        struct Static {
            static let instance = Model()
        }
        return Static.instance
    }
    
    var isIniting = false
    @objc dynamic var loaded = true
    
    @objc dynamic var autoplay: Bool = false {
        didSet {
            if !self.isIniting {
                ServerController.sharedInstance.setAutoplay(autoplay)
            }
        }
    }
    
    @objc dynamic var brightness: Float = 100 {
        didSet {
            if !self.isIniting {
                ServerController.sharedInstance.setBrightness(brightness)
            }
        }
    }
    
    @objc dynamic var channels: [Channel] = []
    @objc dynamic var patterns: [Pattern] = []
    
    @objc dynamic var colorEffects: [Effect] = []
    var activeColorEffectIndex: Int = -1 {
        didSet {
            self.activeColorEffect = activeColorEffectIndex == -1 ? nil : colorEffects[self.activeColorEffectIndex]
            if !self.isIniting {
                ServerController.sharedInstance.setActiveColorEffect(self.activeColorEffectIndex)
            }
        }
    }
    @objc dynamic var activeColorEffect: Effect?
    
    @objc dynamic var speed: Float = 0 {
        didSet {
            if !self.isIniting {
                ServerController.sharedInstance.setSpeed(self.speed)
            }
        }
    }
    @objc dynamic var spin: Float = 0 {
        didSet {
            if !self.isIniting {
                ServerController.sharedInstance.setSpin(self.spin)
            }
        }
    }
    @objc dynamic var blur: Float = 0 {
        didSet {
            if !self.isIniting {
                ServerController.sharedInstance.setBlur(self.blur)
            }
        }
    }
   
}
