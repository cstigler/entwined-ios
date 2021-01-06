//
//  MixerViewController.swift
//  Entwined
//
//  Created by Kyle Fleming on 11/1/14.
//  Copyright (c) 2014 Kyle Fleming. All rights reserved.
//

import UIKit
import ReactiveSwift

class MixerViewController: UIViewController {    
    @IBOutlet weak var autoplaySwitch: UISwitch!
    @IBOutlet weak var timerLabel: UILabel!

    @IBOutlet weak var speedSlider: UISlider!
    @IBOutlet weak var spinSlider: UISlider!
    @IBOutlet weak var blurSlider: UISlider!
    @IBOutlet weak var brightnessSlider: UISlider!
    
    @IBOutlet var sliders: [UISlider]!
    
    var labelUpdateTimer: Timer? = nil
    let disposables = CompositeDisposable.init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        disposables.add(Model.sharedInstance.reactive.producer(forKeyPath: #keyPath(Model.loaded)).startWithValues { [unowned self] (_) in
            if (!Model.sharedInstance.loaded) {
                print("Model sharedInstance !loaded (\(Model.sharedInstance.loaded), so autoplay = true \(Model.sharedInstance)")
                Model.sharedInstance.autoplay = true
            }
        })
        
        disposables.add(Model.sharedInstance.reactive.producer(forKeyPath: #keyPath(Model.autoplay)).startWithValues { [unowned self] (_) in
            self.autoplaySwitch.isOn = Model.sharedInstance.autoplay
            
            if (Model.sharedInstance.autoplay) {
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: nil)
                    // performSegue(withIdentifier: "hide-controls-segue", sender: self)
                }
            }
        })
        
        disposables.add(Model.sharedInstance.reactive.producer(forKeyPath: #keyPath(Model.brightness)).startWithValues { [unowned self] (_) in
            self.brightnessSlider.value = Model.sharedInstance.brightness
        })
        
        disposables.add(Model.sharedInstance.reactive.producer(forKeyPath: #keyPath(Model.speed)).startWithValues { [unowned self] (_) in
            self.speedSlider.value = Model.sharedInstance.speed
        })
        
        disposables.add(Model.sharedInstance.reactive.producer(forKeyPath: #keyPath(Model.spin)).startWithValues { [unowned self] (_) in
            self.spinSlider.value = Model.sharedInstance.spin
        })
        
        disposables.add(Model.sharedInstance.reactive.producer(forKeyPath: #keyPath(Model.blur)).startWithValues { [unowned self] (_) in
            self.blurSlider.value = Model.sharedInstance.blur
        })
        
        for slider in self.sliders {
            slider.setThumbImage(UIImage(named: "channelSliderThumbNormal"),
                                 for: UIControl.State());
            slider.setThumbImage(UIImage(named: "channelSliderThumbNormal"),
                                 for: .highlighted);
            slider.setMinimumTrackImage(UIImage(named: "channelSliderBarNormalMin"),
                                        for: UIControl.State());
            slider.setMaximumTrackImage(UIImage(named: "channelSliderBarNormalMax"),
                                        for: UIControl.State());
        }
        
        brightnessSlider.maximumValue = Model.maxBrightness
        
        labelUpdateTimer = Timer.scheduledTimer(timeInterval: 0.25, target: self, selector: #selector(MixerViewController.updateTimerLabel), userInfo: nil, repeats: true)
        updateTimerLabel()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.userActivityTimeout(notification:)),
            name: .appTimeout,
            object: nil)
    }
    
    deinit {
        self.labelUpdateTimer?.invalidate()
        self.labelUpdateTimer = nil

        disposables.dispose()
        NotificationCenter.default.removeObserver(self, name: .appTimeout, object: nil)
    }
    
    @objc func updateTimerLabel() {
        let timeRemainingFormatted = formatCountdown(Float(Model.sharedInstance.secondsToNextStateChange))

        var periodLengthFormatted: String
        var runState: String
        if (Model.sharedInstance.state == "run") {
            runState = "RUNNING"
            periodLengthFormatted = formatCountdown(Model.sharedInstance.runSeconds)
        } else {
            runState = "BREAK"
            periodLengthFormatted = formatCountdown(Model.sharedInstance.pauseSeconds)
        }

        timerLabel.text = "\(runState) - \(timeRemainingFormatted) of \(periodLengthFormatted) remaining"
    }
    
    @objc func userActivityTimeout(notification: NSNotification){
        print("User inactive, setting autoplay to true")
        Model.sharedInstance.autoplay = true
    }
    
    @IBAction func autoplayChanged(_ sender: AnyObject) {
        Model.sharedInstance.autoplay = self.autoplaySwitch.isOn
    }
    
    @IBAction func brightnessChanged(_ sender: UISlider) {
        Model.sharedInstance.brightness = sender.value
    }
    
    @IBAction func speedChanged(_ sender: AnyObject) {
        Model.sharedInstance.speed = self.speedSlider.value
    }
    
    @IBAction func spinChanged(_ sender: AnyObject) {
        Model.sharedInstance.spin = self.spinSlider.value
    }
    
    @IBAction func blurChanged(_ sender: AnyObject) {
        Model.sharedInstance.blur = self.blurSlider.value
    }
}
