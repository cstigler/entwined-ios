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
    @IBOutlet weak var timerLabel: UILabel!

    @IBOutlet weak var speedSlider: UISlider!
    @IBOutlet weak var spinSlider: UISlider!
    @IBOutlet weak var blurSlider: UISlider!
    @IBOutlet weak var brightnessSlider: UISlider!
    
    @IBOutlet var sliders: [UISlider]!
    
    var labelUpdateTimer: Timer? = nil
    let disposables = CompositeDisposable.init()
    
    var breakPromptShown:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // they made the choice to start during this period willingly - don't prompt them again
        breakPromptShown = true

        disposables.add(Model.sharedInstance.reactive.producer(forKeyPath: #keyPath(Model.loaded)).startWithValues { [unowned self] (_) in
            if (!Model.sharedInstance.loaded) {
                Model.sharedInstance.autoplay = true
            }
        })
        
        disposables.add(Model.sharedInstance.reactive.producer(forKeyPath: #keyPath(Model.breakTimerEnabled)).startWithValues { [unowned self] (_) in
            DispatchQueue.main.async {
                self.timerLabel.isHidden = !(Model.sharedInstance.breakTimerEnabled && Model.sharedInstance.loaded)
            }
        })
        
        disposables.add(Model.sharedInstance.reactive.producer(forKeyPath: #keyPath(Model.autoplay)).startWithValues { [unowned self] (_) in
            if (Model.sharedInstance.autoplay) {
                breakPromptShown = false
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: nil)
                }
            }
        })
        
        disposables.add(Model.sharedInstance.reactive.producer(forKeyPath: #keyPath(Model.state)).startWithValues { [unowned self] (_) in
            if (Model.sharedInstance.state == "run") {
                breakPromptShown = false
            } else if (Model.sharedInstance.state == "pause" && !breakPromptShown) {
                promptForBreak()
            }
        })
        
        disposables.add(Model.sharedInstance.reactive.producer(forKeyPath: #keyPath(Model.brightness)).startWithValues { [unowned self] (_) in
            DispatchQueue.main.async {
                self.brightnessSlider.value = Model.sharedInstance.brightness
            }
        })
        
        disposables.add(Model.sharedInstance.reactive.producer(forKeyPath: #keyPath(Model.speed)).startWithValues { [unowned self] (_) in
            DispatchQueue.main.async {
                self.speedSlider.value = Model.sharedInstance.speed
            }
        })
        
        disposables.add(Model.sharedInstance.reactive.producer(forKeyPath: #keyPath(Model.spin)).startWithValues { [unowned self] (_) in
            DispatchQueue.main.async {
                self.spinSlider.value = Model.sharedInstance.spin
            }
        })
        
        disposables.add(Model.sharedInstance.reactive.producer(forKeyPath: #keyPath(Model.blur)).startWithValues { [unowned self] (_) in
            DispatchQueue.main.async {
                self.blurSlider.value = Model.sharedInstance.blur
            }
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
        updateBreakTimerLabel(
            label: self.timerLabel,
            compactFormatting: (self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClass.compact),
            useLineBreaks: false
        )
    }
    
    @objc func promptForBreak(){
        breakPromptShown = true
        let breakLengthMins = Int(round(Model.sharedInstance.pauseSeconds / 60.0))
        
        let confirmationAlert = UIAlertController(title: "Time for a Break", message: "It's time for our scheduled \(breakLengthMins)-minute lighting break. Would you like to stop controlling and start the break now?", preferredStyle: .alert)
        
        let ok = UIAlertAction(title: "Start Break", style: .default, handler: { (action) -> Void in
            Model.sharedInstance.autoplay = true
            ServerController.sharedInstance.resetTimerToPause()
        })
        
        let cancel = UIAlertAction(title: "Keep Controlling", style: UIAlertAction.Style.default, handler: {
            (action : UIAlertAction!) -> Void in })

        confirmationAlert.addAction(ok)
        confirmationAlert.addAction(cancel)
        
        // Present dialog message to user
        DispatchQueue.main.async {
            self.present(confirmationAlert, animated: true, completion: nil)
        }
    }
    
    @objc func userActivityTimeout(notification: NSNotification){
        print("User inactive, setting autoplay to true")
        Model.sharedInstance.autoplay = true
    }
    
    @IBAction func enableAutoplay(_ sender: AnyObject) {
        Model.sharedInstance.autoplay = true
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
