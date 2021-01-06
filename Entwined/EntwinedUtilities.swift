//
//  EntwinedUtilities.swift
//  Entwined-iOS
//
//  Created by Charlie Stigler on 1/5/21.
//  Copyright © 2021 Charles Gadeken. All rights reserved.
//

import Foundation

// taken from StackOverflow: https://stackoverflow.com/a/35215847/1206009
func formatCountdown(_ duration: Float) -> String {
//    let hours = Int(duration) / 3600
    var roundedDuration: Int = Int(round(duration))
    let minutes = roundedDuration / 60
    let seconds = roundedDuration % 60
    return String(format:"%02i:%02i", minutes, seconds)
}
