//
//  Model.swift
//  Entwined
//
//  Created by Kyle Fleming on 10/27/14.
//  Copyright (c) 2014 Kyle Fleming. All rights reserved.
//

import UIKit

class Model: NSObject {
    static let maxBrightness: Float = 1.0
    
    class var sharedInstance : Model {
        struct Static {
            static let instance = Model()
        }
        return Static.instance
    }
    
    var isIniting = false
    @objc dynamic var loaded = false
    
    var stateChangeTimer:Timer? = nil
    
    deinit {
        self.stateChangeTimer?.invalidate()
        self.stateChangeTimer = nil
    }
    
    @objc dynamic var autoplay: Bool = false {
        didSet {
            if !self.isIniting {
                ServerController.sharedInstance.setAutoplay(autoplay)
                
                // when we switch off autoplay, we should:
                //   1) reload the model since things may have changed since we were last controlling
                //   2) set the selected channel to the first one
                //   3) hide channels indexed 3-7, since we can't control them through the app and that's really confusing
                if (!autoplay) {
                    ServerController.sharedInstance.loadModel()

                    for (index, channel) in self.channels.enumerated() {
                       if index == 0 {
                           DisplayState.sharedInstance.selectedChannel = channel
                       } else if (index >= 3) {
                           channel.visibility = 0.0
                       }
                    }
                }
            }
        }
    }
    
    @objc dynamic var autoplayBrightness: Float = 1.0 {
        didSet {
            if !self.isIniting {
                ServerController.sharedInstance.setAutoplayBrightness(min(autoplayBrightness, Model.maxBrightness))
            } else if (autoplayBrightness > Model.maxBrightness) {
                // if ARE init'ing and the brightness is over max, set it down
                self.autoplayBrightness = Model.maxBrightness
                ServerController.sharedInstance.setAutoplayBrightness(Model.maxBrightness)
            }
        }
    }
    
    @objc dynamic var brightness: Float = Model.maxBrightness {
        didSet {
            if !self.isIniting {
                ServerController.sharedInstance.setBrightness(min(brightness, Model.maxBrightness))
            } else if (brightness > Model.maxBrightness) {
                // if ARE init'ing and the brightness is over max, set it down
                self.brightness = Model.maxBrightness
                ServerController.sharedInstance.setBrightness(Model.maxBrightness)
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
    @objc dynamic var hue: Float = 0 {
        didSet {
            if !self.isIniting {
                ServerController.sharedInstance.setHue(self.hue)
            }
        }
    }
    
    // these vars (related to the timer) should NOT be set from the client
    // only server-set values
    @objc dynamic var runSeconds: Float = 0
    @objc dynamic var pauseSeconds: Float = 0
    @objc dynamic var state: String = "run"
    
    @objc dynamic var timeRemaining: Float = 0 {
        didSet {
            // we need to store WHEN we fetched the timeRemaining
            // so we can interpolate the break end date and know when it's over
            timeRemainingFetched = Date()
            
            // reset the state change timer so we remember to check when the state's supposed to change next
            stateChangeTimer?.invalidate()
            if (breakTimerEnabled) {
                stateChangeTimer = Timer.scheduledTimer(withTimeInterval: secondsToNextStateChange, repeats: false) {_ in
                    ServerController.sharedInstance.loadPauseTimer()
                }
            }
        }
    }
    @objc dynamic var timeRemainingFetched: Date?;
    @objc dynamic var nextStateChangeDate: Date {
        let fetchedDate = timeRemainingFetched ?? Date()
        
        // if there is no break timer,
        // the state change will happen... never
        if (!breakTimerEnabled) {
            return Date.distantFuture
        }

        return fetchedDate.addingTimeInterval(TimeInterval(timeRemaining))
    }
    @objc dynamic var secondsToNextStateChange: Double {
        let endDate = nextStateChangeDate
                
        return endDate.timeIntervalSince(Date())
    }
    @objc dynamic var breakTimerEnabled: Bool {
        // if we haven't loaded the timer from the server yet,
        // or we aren't running with breaks,
        // there is no break timer.
        return timeRemainingFetched != nil && runSeconds != 0 && pauseSeconds != 0
    }
}
