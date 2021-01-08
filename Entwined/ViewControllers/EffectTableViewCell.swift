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
    let disposables = CompositeDisposable.init()
    @objc dynamic var effect: Effect!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var enabledIndicatorView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        disposables.add(self.reactive.producer(forKeyPath: #keyPath(effect.name)).startWithValues { [unowned self] (name: Any?) in
            DispatchQueue.main.async {
                if let name = name as? String {
                    self.nameLabel.text = name
                } else {
                    self.nameLabel.text = "None"
                }
            }
        })
        disposables.add(SignalProducer.merge([self.reactive.producer(forKeyPath: #keyPath(effect)), Model.sharedInstance.reactive.producer(forKeyPath: #keyPath(Model.activeColorEffect))]).startWithValues { [unowned self] (_) in
            DispatchQueue.main.async {
                self.enabledIndicatorView.alpha = Model.sharedInstance.activeColorEffect == self.effect ? 1 : 0
            }
        })
    }

    deinit {
        disposables.dispose()
    }
}
