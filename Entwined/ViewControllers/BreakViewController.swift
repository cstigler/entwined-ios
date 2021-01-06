//
//  BreakViewController.swift
//  Entwined-iOS
//
//  Created by Charlie Stigler on 12/11/20.
//  Copyright © 2020 Charles Gadeken. All rights reserved.
//

import Foundation
import UIKit
import ReactiveSwift

class BreakViewController: UIViewController {
    let disposables = CompositeDisposable.init()
    var labelUpdateTimer: Timer? = nil
    
    @IBOutlet weak var timeRemainingLabel: UILabel!
    @IBOutlet weak var stopBreakButton: UIButton!

    deinit {
        disposables.dispose()

        self.labelUpdateTimer?.invalidate()
        self.labelUpdateTimer = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        labelUpdateTimer = Timer.scheduledTimer(timeInterval: 0.25, target: self, selector: #selector(BreakViewController.updateTimeRemaining), userInfo: nil, repeats: true)

        updateTimeRemaining()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        self.labelUpdateTimer?.invalidate()
        self.labelUpdateTimer = nil
    }
    
    @objc func updateTimeRemaining() {
        var secondsRemaining = Model.sharedInstance.secondsToNextStateChange

        // when the break's over, go back to the start screen
        if (secondsRemaining <= 0) {
            DispatchQueue.main.async {
                Model.sharedInstance.autoplay = true
                self.dismiss(animated: true, completion: nil)
            }
        }
        
        timeRemainingLabel.text = "\(formatCountdown(Float(secondsRemaining)))"
    }
    
    @IBAction func stopBreak(_ sender: AnyObject) {
        Model.sharedInstance.autoplay = true
        ServerController.sharedInstance.resetTimerToRun()
    }
}
