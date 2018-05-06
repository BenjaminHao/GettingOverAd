//
//  Settings.swift
//  GettingOverAd
//
//  Created by Benjamin Hao on 2018-04-11.
//  Copyright © 2018 Benjamin Hao. All rights reserved.
//

import SpriteKit

class Settings:SKScene {
    var background_Texture = SKTexture(imageNamed: "backgroundX_1")
    var CastleTexture = SKTexture(imageNamed: "castleX")
    
    lazy var rateButton: BDButton = {
        //    var button = BDButton(imageNamed: "ButtonBlue", buttonAction: {
        //      ACTManager.shared.transition(self, toScene: .MainMenu, transition: SKTransition.moveIn(with: .left, duration: 0.5))
        //    })
        var button = BDButton(imageNamed: "BTN_PLAIN (6)", title: "Rate Me", buttonAction: {
            self.handleRateMeButton()
        })
        button.zPosition = 1
        button.scaleTo(screenWithPercentage: 0.23)
        button.titleLabel?.fontSize = CGFloat.universalFont(size: 24)
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
        var button = BDButton(imageNamed: "BTN_PLAIN (6)", title: "Share", buttonAction: {
            self.handleShareButton()
        })
        button.zPosition = 1
        button.scaleTo(screenWithPercentage: 0.23)
        button.titleLabel?.fontSize = CGFloat.universalFont(size: 24)
        return button
    }()
    
    func handleShareButton() {
        GameManager.shared.share(on: self, text: "I got \(PlayerStats.shared.getBestScore()) in Getting Over Ad, it is soooo hard to get 100 points!", image: UIImage(named: "logo"), exculdeActivityTypes: [.airDrop, .postToTwitter, .postToFacebook, .message, .postToWeibo, .postToTencentWeibo, .saveToCameraRoll, .mail])
    }
    
    lazy var backButton: BDButton = {
        //    var button = BDButton(imageNamed: "ButtonBlue", buttonAction: {
        //      ACTManager.shared.transition(self, toScene: .MainMenu, transition: SKTransition.moveIn(with: .left, duration: 0.5))
        //    })
        var button = BDButton(imageNamed: "BTN_PLAIN (6)", title: "Back", buttonAction: {
            GameManager.shared.transition(self, toScene: .MainMenu, transition: SKTransition.moveIn(with: .up, duration: 0.5))
        })
        button.zPosition = 1
        button.scaleTo(screenWithPercentage: 0.2)
        button.titleLabel?.fontSize = CGFloat.universalFont(size: 28)
        return button
    }()
    
    var volumeLabel: SKLabelNode = {
        var label = SKLabelNode(fontNamed: "GamjaFlower-Regular")
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
        var button = BDButton(imageNamed: "BTN_HORIZ_SINGLE (18)", buttonAction: {
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
        var button = BDButton(imageNamed: "BTN_HORIZ_SINGLE (24)", buttonAction: {
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
        //BG
        let background = SKSpriteNode(texture: background_Texture)
        background.zPosition = -15
        background.position = CGPoint(x: 0 , y: 0)
        background.setScale(0.5)
        background.size.width = ScreenSize.width
        background.size.height = ScreenSize.height
        let castle = SKSpriteNode(texture: CastleTexture)
        castle.zPosition = -10
        castle.position = CGPoint(x: 0, y: 0)
        castle.setScale(0.5)
        castle.size.width = ScreenSize.width * 0.75
        castle.size.height = ScreenSize.height
        
        addChild(background)
        addChild(castle)
        
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
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
