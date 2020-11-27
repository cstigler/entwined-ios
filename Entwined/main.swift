//
//  main.swift
//  Entwined
//
//  Created by Avtar on 29/04/19.
//  Copyright © 2019 Kyle Fleming. All rights reserved.
//

import Foundation
import UIKit


CommandLine.unsafeArgv.withMemoryRebound(to: UnsafeMutablePointer<Int8>.self, capacity: Int(CommandLine.argc))
{    argv in
    _ = UIApplicationMain(CommandLine.argc, argv, NSStringFromClass(TimerApplication.self), NSStringFromClass(AppDelegate.self))
}
