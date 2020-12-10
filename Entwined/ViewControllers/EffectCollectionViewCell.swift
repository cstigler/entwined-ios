//
//  EffectCollectionViewCell.swift
//  Entwined
//
//  Created by Kyle Fleming on 10/31/14.
//  Copyright (c) 2014 Kyle Fleming. All rights reserved.
//

import UIKit
import ReactiveSwift

class EffectCollectionViewCell: UICollectionViewCell {
    let disposables = CompositeDisposable.init()
    @objc dynamic var effect: Effect!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var enabledIndicatorView: UIView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        disposables.add(self.reactive.producer(forKeyPath: #keyPath(effect.name)).startWithValues { [unowned self] (name: Any?) in
            if let name = name as? String {
                self.nameLabel.text! = name
            }
        })
        disposables.add(SignalProducer.merge([self.reactive.producer(forKeyPath: #keyPath(effect)), Model.sharedInstance.reactive.producer(forKeyPath: #keyPath(Model.activeColorEffect))]).startWithValues { [unowned self] (_) in
            if self.effect != nil {
                self.enabledIndicatorView.alpha = Model.sharedInstance.activeColorEffect == self.effect ? 1 : 0
            }
        })
    }
    
    deinit {
        disposables.dispose()
    }    
}
