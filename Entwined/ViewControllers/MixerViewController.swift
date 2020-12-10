//
//  MixerViewController.swift
//  Entwined
//
//  Created by Kyle Fleming on 11/1/14.
//  Copyright (c) 2014 Kyle Fleming. All rights reserved.
//

import UIKit

class MixerViewController: UIViewController {    
    @IBOutlet weak var autoplaySwitch: UISwitch!

    @IBOutlet weak var speedSlider: UISlider!
    @IBOutlet weak var spinSlider: UISlider!
    @IBOutlet weak var blurSlider: UISlider!
    @IBOutlet weak var brightnessEffectSlider: UISlider!
    
    @IBOutlet var sliders: [UISlider]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Model.sharedInstance.reactive.producer(forKeyPath: #keyPath(Model.loaded)).startWithValues { [unowned self] (_) in
            
            if (!Model.sharedInstance.loaded) {
                Model.sharedInstance.autoplay = true
            }
        }
        
        Model.sharedInstance.reactive.producer(forKeyPath: #keyPath(Model.autoplay)).startWithValues { [unowned self] (_) in
            self.autoplaySwitch.isOn = Model.sharedInstance.autoplay
            
            if (Model.sharedInstance.autoplay) {
                performSegue(withIdentifier: "hide-controls-segue", sender: self)
            }
        }
        
        Model.sharedInstance.reactive.producer(forKeyPath: #keyPath(Model.brightness)).startWithValues { [unowned self] (_) in
            self.brightnessEffectSlider.value = Model.sharedInstance.brightness
        }
        
        Model.sharedInstance.reactive.producer(forKeyPath: #keyPath(Model.speed)).startWithValues { [unowned self] (_) in
            self.speedSlider.value = Model.sharedInstance.speed
        }
        
        Model.sharedInstance.reactive.producer(forKeyPath: #keyPath(Model.spin)).startWithValues { [unowned self] (_) in
            self.spinSlider.value = Model.sharedInstance.spin
        }
        
        Model.sharedInstance.reactive.producer(forKeyPath: #keyPath(Model.blur)).startWithValues { [unowned self] (_) in
            self.blurSlider.value = Model.sharedInstance.blur
        }
        
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
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.userActivityTimeout(notification:)),
            name: .appTimeout,
            object: nil)
    }
    
    @objc func userActivityTimeout(notification: NSNotification){
        print("User In active")
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
