//
//  Settings.swift
//  GettingOverAd
//
//  Created by Benjamin Hao on 2018-04-11.
//  Copyright © 2018 Benjamin Hao. All rights reserved.
//

import SpriteKit

class Settings:SKScene {
    
    lazy var rateButton: BDButton = {
        //    var button = BDButton(imageNamed: "ButtonBlue", buttonAction: {
        //      ACTManager.shared.transition(self, toScene: .MainMenu, transition: SKTransition.moveIn(with: .left, duration: 0.5))
        //    })
        var button = BDButton(imageNamed: "ButtonBlue", title: "Rate Me", buttonAction: {
            self.handleRateMeButton()
        })
        button.zPosition = 1
        button.scaleTo(screenWithPercentage: 0.25)
        button.titleLabel?.fontSize = CGFloat.universalFont(size: 18)
        return button
    }()
    
    func handleRateMeButton() {
        if let url = URL(string: "https://itunes.apple.com/") {
            UIApplication.shared.open(url, options: [:], completionHandler: { (result) in
                if result {
                    print("Success")
                } else {
                    print("Failed")
                }
            })
            
        }
    }
    
    lazy var shareButton: BDButton = {
        //    var button = BDButton(imageNamed: "ButtonBlue", buttonAction: {
        //      ACTManager.shared.transition(self, toScene: .MainMenu, transition: SKTransition.moveIn(with: .left, duration: 0.5))
        //    })
        var button = BDButton(imageNamed: "ButtonBlue", title: "Share", buttonAction: {
            self.handleShareButton()
        })
        button.zPosition = 1
        button.scaleTo(screenWithPercentage: 0.25)
        button.titleLabel?.fontSize = CGFloat.universalFont(size: 18)
        return button
    }()
    
    func handleShareButton() {
        GameManager.shared.share(on: self, text: "I got \(PlayerStats.shared.getBestScore()) in Getting Over Ad, I bet u can't even get 1 point if you play it!", image: UIImage(named: "ButtonPlay"), exculdeActivityTypes: [.airDrop, .postToFacebook])
    }
    
    lazy var backButton: BDButton = {
        //    var button = BDButton(imageNamed: "ButtonBlue", buttonAction: {
        //      ACTManager.shared.transition(self, toScene: .MainMenu, transition: SKTransition.moveIn(with: .left, duration: 0.5))
        //    })
        var button = BDButton(imageNamed: "ButtonBlue", title: "Back", buttonAction: {
            GameManager.shared.transition(self, toScene: .MainMenu, transition: SKTransition.moveIn(with: .left, duration: 0.5))
        })
        button.zPosition = 1
        button.scaleTo(screenWithPercentage: 0.25)
        return button
    }()
    
    var volumeLabel: SKLabelNode = {
        var label = SKLabelNode(fontNamed: "BubbleGum")
        label.fontSize = CGFloat.universalFont(size: 36)
        label.zPosition = 1
        label.text = "\(Int(PlayerStats.shared.getMusicVolume() * 100))%"
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = .center
        return label
    }()
    
    lazy var minusVolumeButton: BDButton = {
        //    var button = BDButton(imageNamed: "ButtonBlue", buttonAction: {
        //      ACTManager.shared.transition(self, toScene: .MainMenu, transition: SKTransition.moveIn(with: .left, duration: 0.5))
        //    })
        var button = BDButton(imageNamed: "ButtonVolume", title: "-", buttonAction: {
            self.handleMinusVolumeButton()
        })
        button.zPosition = 1
        button.titleLabel?.fontSize = CGFloat.universalFont(size: 28)
        button.scaleTo(screenWithPercentage: 0.12)
        return button
    }()
    
    func handleMinusVolumeButton() {
        setMusicBackground(by: -0.1)
    }
    
    lazy var plusVolumeButton: BDButton = {
        //    var button = BDButton(imageNamed: "ButtonBlue", buttonAction: {
        //      ACTManager.shared.transition(self, toScene: .MainMenu, transition: SKTransition.moveIn(with: .left, duration: 0.5))
        //    })
        var button = BDButton(imageNamed: "ButtonVolume", title: "+", buttonAction: {
            self.handlePlusVolumeButton()
        })
        button.zPosition = 1
        button.titleLabel?.fontSize = CGFloat.universalFont(size: 28)
        button.scaleTo(screenWithPercentage: 0.12)
        return button
    }()
    
    func handlePlusVolumeButton() {
        setMusicBackground(by: 0.1)
    }
    
    override func didMove(to view: SKView) {
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        backgroundColor = .orange
        
        rateButton.position = CGPoint(x: ScreenSize.width * 0.0, y: ScreenSize.height * -0.2)
        addChild(rateButton)
        
        shareButton.position = CGPoint(x: ScreenSize.width * 0.0, y: ScreenSize.height * -0.3)
        addChild(shareButton)
        
        backButton.position = CGPoint(x: ScreenSize.width * -0.3, y: ScreenSize.height * 0.35)
        addChild(backButton)
        
        volumeLabel.position = CGPoint.zero
        addChild(volumeLabel)
        
        minusVolumeButton.position = CGPoint(x: ScreenSize.width * -0.2, y: ScreenSize.height * 0.0)
        addChild(minusVolumeButton)
        
        plusVolumeButton.position = CGPoint(x: ScreenSize.width * 0.2, y: ScreenSize.height * 0.0)
        addChild(plusVolumeButton)
    }
    
    func setMusicBackground(by volume: Float) {
        let currentVolume = PlayerStats.shared.getMusicVolume()
        var volume = currentVolume + volume
        if volume >= 1.0 {
            volume = 1.0
        }
        if volume <= 0.0 {
            volume = 0.0
        }
        
        volumeLabel.text = "\(Int(volume * 100))%"
        
        PlayerStats.shared.saveMusicVolume(volume)
        
        let info = ["volume": PlayerStats.shared.getMusicVolume()]
        NotificationCenter.default.post(name: setMusicVolumeNotificationName, object: nil, userInfo: info)
    }
}