//
//  RPCController.swift
//  Entwined
//
//  Created by Kyle Fleming on 10/26/14.
//  Copyright (c) 2014 Kyle Fleming. All rights reserved.
//

import UIKit
import PKJSONSocket

class ServerController: NSObject, PKJSONSocketDelegate {
    
    class var sharedInstance : ServerController {
        struct Static {
            static let instance = ServerController()
        }
        return Static.instance
    }
    
    override init() {
        self.socket = PKJSONSocket()
        super.init()
        self.socket.delegate = self
    }
    
    var socket: PKJSONSocket
    var timer: Timer? {
        willSet {
            self.timer?.invalidate()
        }
    }
    var autoconnect = false
    var connected: Bool = false {
        didSet {
            print(connected ? "Connected" : "Disconnected")
        }
    }
    
    @objc func connect() {
        self.autoconnect = true
        self.socket.connect(toHost: "odroid.local", onPort: 5204, error: nil)
    }
    
    func disconnect() {
        self.autoconnect = false
        self.socket.disconnect()
        self.timer = nil
    }
    
    func socket(_ socket: PKJSONSocket!, didConnectToHost host: String!) {
        self.connected = true
        self.timer = nil
        ServerController.sharedInstance.loadModel()
    }
    
    func socket(_ socket: PKJSONSocket!, didDisconnectWithError error: Error!) {
        self.connected = false
        Model.sharedInstance.loaded = false
        if timer == nil {
            if self.autoconnect {
                self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ServerController.connect), userInfo: nil, repeats: true)
                
            }
        }
    }
    
    func socket(_ socket: PKJSONSocket, didReceive dictionary: PKJSONSocketMessage) {
        print(dictionary.dictionaryRepresentation())
        if let method = dictionary.dictionaryRepresentation()["method"] as? String {
            if let params = dictionary.dictionaryRepresentation()["params"] as? Dictionary<String, AnyObject> {
                switch method {
                case "model":
                    Model.sharedInstance.isIniting = true
                    if let autoplay = params["autoplay"] as? Bool {
                        Model.sharedInstance.autoplay = autoplay
                    }
                    if let brightness = params["brightness"] as? Float {
                        Model.sharedInstance.brightness = brightness
                    }
                    if let colorEffectsArray = params["colorEffects"] as? [Dictionary<String, AnyObject>] {
                        Model.sharedInstance.colorEffects = parseEffectsArray(colorEffectsArray)
                    }
                    if let channelsArray = params["channels"] as? [Dictionary<String, AnyObject>] {
                        Model.sharedInstance.channels = parseChannelsArray(channelsArray)
                        Model.sharedInstance.patterns = Model.sharedInstance.channels[0].patterns
                    }
                    if let activeColorEffectIndex = params["activeColorEffectIndex"] as? Int {
                        Model.sharedInstance.activeColorEffectIndex = activeColorEffectIndex
                    }
                    if let speed = params["speed"] as? Float {
                        Model.sharedInstance.speed = speed
                    }
                    if let spin = params["spin"] as? Float {
                        Model.sharedInstance.spin = spin
                    }
                    if let blur = params["blur"] as? Float {
                        Model.sharedInstance.blur = blur
                    }
                    DisplayState.sharedInstance.selectedChannelIndex = 0
                    Model.sharedInstance.isIniting = false
                    Model.sharedInstance.loaded = true
                default:
                    break
                }
            }
        }
    }
    
    func parseEffectsArray(_ effectsArray: [Dictionary<String, AnyObject>]) -> [Effect] {
        var effects = [Effect]()
        for effectParams in effectsArray {
            let index = effectParams["index"] as! Int
            let name = effectParams["name"] as! String
            effects.append(Effect(index: index, name: name))
        }
        return effects
    }
    
    func parseChannelsArray(_ channelsArray: [Dictionary<String, AnyObject>]) -> [Channel] {
        var channels = [Channel]()
        for channelParams in channelsArray {
            let channelIndex = channelParams["index"] as! Int
            let currentPatternIndex = channelParams["currentPatternIndex"] as! Int
            let visibility = channelParams["visibility"] as! Float
            var patterns = [Pattern]()
            for (_, patternParams) in (channelParams["patterns"] as! [Dictionary<String, AnyObject>]).enumerated() {
                let patternIndex = patternParams["index"] as! Int
                let name = patternParams["name"] as! String
                patterns.append(Pattern(index: patternIndex, name: name))
            }
            let currentPattern: Pattern? = currentPatternIndex == -1 ? nil : (channelIndex == 0 ? patterns[currentPatternIndex] : channels[0].patterns[currentPatternIndex])
            channels.append(Channel(index: channelIndex, patterns: patterns, currentPattern: currentPattern, visibility: visibility))
        }
        return channels
    }
    
    func send(_ method: String, params: Dictionary<String, AnyObject>? = nil) {
        if let params = params {
            socket.send(PKJSONSocketMessage(dictionary: ["method": method, "params": params]))
        } else {
            socket.send(PKJSONSocketMessage(dictionary: ["method": method]))
        }
    }
    
    func loadModel() {
        self.send("loadModel")
    }
    
    func setAutoplay(_ autoplay: Bool) {
        self.send("setAutoplay", params: ["autoplay": autoplay as AnyObject])
    }
    
    func setBrightness(_ brightness: Float) {
        self.send("setBrightness", params: ["brightness": brightness as AnyObject])
    }
    
    func setChannelPattern(_ channel: Channel) {
        let currentPatternIndex = channel.currentPattern == nil ? -1 : channel.currentPattern!.index
        self.send("setChannelPattern", params: ["channelIndex": channel.index as AnyObject, "patternIndex": currentPatternIndex as AnyObject])
    }
    
    func setChannelVisibility(_ channel: Channel) {
        self.send("setChannelVisibility", params: ["channelIndex": channel.index as AnyObject, "visibility": channel.visibility as AnyObject])
    }
    
    func setActiveColorEffect(_ activeColorEffectIndex: Int) {
        self.send("setActiveColorEffect", params: ["effectIndex": activeColorEffectIndex as AnyObject])
    }
    
    func setSpeed(_ amount: Float) {
        self.send("setSpeed", params: ["amount": amount as AnyObject])
    }
    
    func setSpin(_ amount: Float) {
        self.send("setSpin", params: ["amount": amount as AnyObject])
    }
    
    func setBlur(_ amount: Float) {
        self.send("setBlur", params: ["amount": amount as AnyObject])
    }
   
}
