//
//  ChannelCollectionViewCell.swift
//  Entwined
//
//  Created by Kyle Fleming on 11/4/14.
//  Copyright (c) 2014 Kyle Fleming. All rights reserved.
//

import UIKit
import ReactiveSwift

class ChannelCollectionViewCell: UICollectionViewCell {
    
    @objc dynamic var channel: Channel!
    @objc dynamic var currentlySelected = false
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var channelLabel: UILabel!
    @IBOutlet weak var tapAPatternLabel: UILabel!
    @IBOutlet weak var visibilitySlider: UISlider!
    
    @IBOutlet weak var selectedBlueImageView: UIImageView!
    @IBOutlet weak var selectedOrangeImageView: UIImageView!
    @IBOutlet weak var selectedGreenImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.visibilitySlider.transform = CGAffineTransform(rotationAngle: -.pi/2);
        
        SignalProducer.merge([self.reactive.producer(forKeyPath: #keyPath(channel)), DisplayState.sharedInstance.reactive.producer(forKeyPath: #keyPath(DisplayState.selectedChannel))]).startWithValues { [unowned self] (_) in
            self.currentlySelected = self.channel != nil && DisplayState.sharedInstance.selectedChannel != nil && self.channel == DisplayState.sharedInstance.selectedChannel
        }
        
        self.reactive.producer(forKeyPath: #keyPath(channel.index)).startWithValues { [unowned self] (_) in
            if self.channel != nil {
                self.channelLabel.text = "Channel \(self.channel.index + 1)"
            }
        }
        
        SignalProducer.merge([self.reactive.producer(forKeyPath: #keyPath(channel.index)), self.reactive.producer(forKeyPath: #keyPath(channel.currentPattern))]).startWithValues { [unowned self] (_) in
            if self.channel != nil {
                if self.channel.currentPattern == nil {
                    self.visibilitySlider.setThumbImage(UIImage(named: "channelSliderThumbGray"),
                        for: UIControlState());
                    self.visibilitySlider.setThumbImage(UIImage(named: "channelSliderThumbGray"),
                        for: .highlighted);
                    self.visibilitySlider.setMinimumTrackImage(UIImage(named: "channelSliderBarGray"),
                        for: UIControlState());
                    self.visibilitySlider.setMaximumTrackImage(UIImage(named: "channelSliderBarGray"),
                        for: UIControlState());
                } else {
                    switch self.channel.index {
                    case 0:
                        self.visibilitySlider.setThumbImage(UIImage(named: "channelSliderThumbBlue"),
                            for: UIControlState());
                        self.visibilitySlider.setThumbImage(UIImage(named: "channelSliderThumbBlue"),
                            for: .highlighted);
                        self.visibilitySlider.setMinimumTrackImage(UIImage(named: "channelSliderBarBlue"),
                            for: UIControlState());
                        self.visibilitySlider.setMaximumTrackImage(UIImage(named: "channelSliderBarDefault"),
                            for: UIControlState());
                    case 1:
                        self.visibilitySlider.setThumbImage(UIImage(named: "channelSliderThumbOrange"),
                            for: UIControlState());
                        self.visibilitySlider.setThumbImage(UIImage(named: "channelSliderThumbOrange"),
                            for: .highlighted);
                        self.visibilitySlider.setMinimumTrackImage(UIImage(named: "channelSliderBarOrange"),
                            for: UIControlState());
                        self.visibilitySlider.setMaximumTrackImage(UIImage(named: "channelSliderBarDefault"),
                            for: UIControlState());
                    case 2:
                        self.visibilitySlider.setThumbImage(UIImage(named: "channelSliderThumbGreen"),
                            for: UIControlState());
                        self.visibilitySlider.setThumbImage(UIImage(named: "channelSliderThumbGreen"),
                            for: .highlighted);
                        self.visibilitySlider.setMinimumTrackImage(UIImage(named: "channelSliderBarGreen"),
                            for: UIControlState());
                        self.visibilitySlider.setMaximumTrackImage(UIImage(named: "channelSliderBarDefault"),
                            for: UIControlState());
                    default:
                        break;
                    }
                }
            }
        }
        
        self.reactive.producer(forKeyPath: #keyPath(channel.currentPattern.name)).startWithValues { [unowned self] (_) in
            if self.channel != nil {
                self.nameLabel.text = self.channel.currentPattern?.name
            }
        }
        
        self.reactive.producer(forKeyPath: #keyPath(currentlySelected)).startWithValues { [unowned self] (_) in
            if self.channel != nil {
                self.selectedBlueImageView.isHidden = true
                self.selectedOrangeImageView.isHidden = true
                self.selectedGreenImageView.isHidden = true
                if self.currentlySelected {
                    switch self.channel.index {
                    case 0:
                        self.selectedBlueImageView.isHidden = false
                    case 1:
                        self.selectedOrangeImageView.isHidden = false
                    case 2:
                        self.selectedGreenImageView.isHidden = false
                    default:
                        break;
                    }
                }
            }
        }
        
        self.reactive.producer(forKeyPath: #keyPath(channel.visibility)).startWithValues { [unowned self] (_) in
            if self.channel != nil {
                self.visibilitySlider.value = self.channel.visibility
            }
        }
        
        SignalProducer.merge([self.reactive.producer(forKeyPath: #keyPath(channel.currentPattern.name)), self.reactive.producer(forKeyPath: #keyPath(currentlySelected)), self.reactive.producer(forKeyPath: #keyPath(channel.currentPattern))]).startWithValues { [unowned self] (_) in
            if self.channel != nil {
                self.nameLabel.isHidden = true
                self.channelLabel.isHidden = true
                self.tapAPatternLabel.isHidden = true
                self.visibilitySlider.isUserInteractionEnabled = false
                if self.channel.currentPattern != nil {
                    self.nameLabel.isHidden = false
                    self.visibilitySlider.isUserInteractionEnabled = true
                } else if self.currentlySelected {
                    self.tapAPatternLabel.isHidden = false
                } else {
                    self.channelLabel.isHidden = false
                }
            }
        }
    }
    
    @IBAction func channelVisibilityChanged(_ sender: AnyObject) {
        channel.visibility = self.visibilitySlider.value
        if !self.currentlySelected {
            DisplayState.sharedInstance.selectedChannelIndex = channel.index
        }
    }
    
}
