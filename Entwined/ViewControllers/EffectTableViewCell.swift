//
//  EffectTableViewCell.swift
//  Entwined
//
//  Created by Kyle Fleming on 11/5/14.
//  Copyright (c) 2014 Kyle Fleming. All rights reserved.
//

import UIKit
import ReactiveSwift

class EffectTableViewCell: UITableViewCell {
    
    @objc dynamic var effect: Effect!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var enabledIndicatorView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.reactive.producer(forKeyPath: #keyPath(effect.name)).startWithValues { [unowned self] (name: Any?) in
            if let name = name as? String {
                self.nameLabel.text = name
            } else {
                self.nameLabel.text = "None"
            }
        }
        SignalProducer.merge([self.reactive.producer(forKeyPath: #keyPath(effect)), Model.sharedInstance.reactive.producer(forKeyPath: #keyPath(Model.activeColorEffect))]).startWithValues { [unowned self] (_) in
            self.enabledIndicatorView.alpha = Model.sharedInstance.activeColorEffect == self.effect ? 1 : 0
        }
    }

}
