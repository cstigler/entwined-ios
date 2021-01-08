//
//  EntwinedUtilities.swift
//  Entwined-iOS
//
//  Created by Charlie Stigler on 1/5/21.
//  Copyright © 2021 Charles Gadeken. All rights reserved.
//

import Foundation
import UIKit

// taken from StackOverflow: https://stackoverflow.com/a/35215847/1206009
func formatCountdown(_ duration: Float) -> String {
//    let hours = Int(duration) / 3600
    let roundedDuration: Int = Int(round(max(duration, 0)))
    let minutes: Int = roundedDuration / 60
    let seconds: Int = roundedDuration % 60
    return String(format:"%02i:%02i", minutes, seconds)
}

func updateBreakTimerLabel(label: UILabel, compactFormatting: Bool, useLineBreaks: Bool) {
    DispatchQueue.main.async {
        let timeRemainingFormatted = formatCountdown(Float(Model.sharedInstance.secondsToNextStateChange))
        
        var periodLengthFormatted: String
        var runState: String
        if (Model.sharedInstance.state == "run") {
            runState = compactFormatting ? "RUN" : "RUNNING"
            periodLengthFormatted = formatCountdown(Model.sharedInstance.runSeconds)
        } else {
            runState = "BREAK"
            periodLengthFormatted = formatCountdown(Model.sharedInstance.pauseSeconds)
        }
        
        let runTextColor = UIColor(red: 11.0  / 255.0, green: 140.0 / 255.0, blue: 31.0 / 255.0, alpha: 1) // green
        let breakTextColor = UIColor(red: 220.0  / 255.0, green: 45.0 / 255.0, blue: 45.0 / 255.0, alpha: 1) // red
        
        var attributedString: NSMutableAttributedString
        if (compactFormatting) {
            attributedString = NSMutableAttributedString.init(string: "\(runState)\(useLineBreaks ? "\n" : ": ")\(timeRemainingFormatted) of \(periodLengthFormatted)")
        } else {
            attributedString = NSMutableAttributedString.init(string: "\(runState)\(useLineBreaks ? "\n" : " - ")\(timeRemainingFormatted) of \(periodLengthFormatted) remaining")
        }

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 10.0
        paragraphStyle.alignment = .center
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range:NSMakeRange(0, attributedString.length))

        let runStateRange = NSMakeRange(0, runState.count)
        attributedString.addAttributes([.foregroundColor: (runState == "BREAK" ? breakTextColor : runTextColor)], range: runStateRange)

        label.attributedText = attributedString
        
        // if the seconds to next state change was negative, we're overdue for a refresh. so do that
        if (Model.sharedInstance.secondsToNextStateChange < 0 && Model.sharedInstance.loaded) {
            ServerController.sharedInstance.loadPauseTimer()
        }
    }
}
