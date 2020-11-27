//
//  DisplayState.swift
//  Entwined
//
//  Created by Kyle Fleming on 10/31/14.
//  Copyright (c) 2014 Kyle Fleming. All rights reserved.
//

import UIKit

class DisplayState: NSObject {
    
    class var sharedInstance : DisplayState {
        struct Static {
            static let instance = DisplayState()
        }
        return Static.instance
    }
    
    override init() {
        super.init()
        Model.sharedInstance.reactive.producer(forKeyPath: #keyPath(Model.channels)).startWithValues { [unowned self] (_) in
            self.updateSelectedChannel()
        }
    }
    
    var selectedChannelIndex: Int = 0 {
        didSet {
            self.updateSelectedChannel()
        }
    }
    func updateSelectedChannel() {
        if Model.sharedInstance.channels.count > selectedChannelIndex {
            self.selectedChannel = Model.sharedInstance.channels[selectedChannelIndex]
        } else if Model.sharedInstance.channels.count > 0 {
            self.selectedChannel = Model.sharedInstance.channels[0]
        } else {
            self.selectedChannel = nil
        }
    }
    @objc dynamic var selectedChannel: Channel?
   
}
