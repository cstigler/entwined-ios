//
//  PatternCollectionViewCell.swift
//  Minitrees
//
//  Created by Kyle Fleming on 10/28/14.
//  Copyright (c) 2014 Kyle Fleming. All rights reserved.
//

import UIKit
import ReactiveCocoa

class PatternCollectionViewCell: UICollectionViewCell {
    
    @objc var pattern: Pattern!
    var currentlySelected = false
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var deseletedImageView: UIImageView!
    @IBOutlet weak var selectedBlueImageView: UIImageView!
    @IBOutlet weak var selectedGreenImageView: UIImageView!
    @IBOutlet weak var selectedOrangeImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.reactive.producer(forKeyPath: #keyPath(pattern.name)).startWithValues { [unowned self] (name: Any?) in
            if let name = name as? String {
                self.nameLabel.text! = name
            }
        }
        
        self.reactive.producer(forKeyPath: #keyPath(pattern.channelSelectedOn.index)).startWithValues { [unowned self] (_) in
            if self.pattern != nil {
                self.deseletedImageView.isHidden = true
                self.selectedBlueImageView.isHidden = true
                self.selectedGreenImageView.isHidden = true
                self.selectedOrangeImageView.isHidden = true
                
                if let channel = self.pattern.channelSelectedOn {
                    switch channel.index {
                    case 0:
                        self.selectedBlueImageView.isHidden = false
                    case 1:
                        self.selectedOrangeImageView.isHidden = false
                    case 2:
                        self.selectedGreenImageView.isHidden = false
                    default:
                        break;
                    }
                } else {
                    self.deseletedImageView.isHidden = false
                }
            }
        }
    }
    
}
