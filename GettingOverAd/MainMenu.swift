//
//  MainMenu.swift
//  GettingOverAd
//
//  Created by Benjamin Hao on 2018-04-11.
//  Copyright © 2018 Benjamin Hao. All rights reserved.
//

import Foundation
import SpriteKit
import GoogleMobileAds

class MainMenu: SKScene {
    var background_Texture = SKTexture(imageNamed: "backgroundX_1")
    var CastleTexture = SKTexture(imageNamed: "castleX")
    var logoTexture = SKTexture(imageNamed: "logo")
    var antibodySprite = SKSpriteNode(imageNamed: "antibody_9")
    var infoSprite = SKSpriteNode(imageNamed: "information")
    var BestScoreLabel:SKLabelNode!;
    var BestPlatformLabel:SKLabelNode!;
    var AntigensLabel:SKLabelNode!;
    var popupMenu = SKSpriteNode(imageNamed:"antibodyPanel")
    
    var BestPlatform: Int = PlayerStats.shared.getBestPlatformScore(){
        didSet{
            BestPlatformLabel.text = "Best Platforms: \(PlayerStats.shared.getBestPlatformScore())";
        }
    }
    var BestScore:Int = PlayerStats.shared.getBestPlatformScore(){
        didSet{
            BestScoreLabel.text = "Best Score: \(PlayerStats.shared.getBestScore())";
        }
    }
    
    var Antigens:Int = PlayerStats.shared.getAntigens() {
        didSet{
            PlayerStats.shared.setAntigens(Antigens)
            AntigensLabel.text = "X\(PlayerStats.shared.getAntigens())";
        }
    }
    
    lazy var countdownLabel: SKLabelNode = {
        var label = SKLabelNode(fontNamed: "GamjaFlower-Regular")
        label.fontSize = CGFloat.universalFont(size: 24)
        label.zPosition = 1
        label.color = SKColor.white
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = .center
        label.text = "00:00"
        return label
    }()
    
    lazy var playButton: BDButton = {
        var button = BDButton(imageNamed: "TEXT_START", buttonAction: {
            self.startGameplay()
        })
        button.scaleTo(screenWithPercentage: 0.5)
        button.zPosition = 1
        return button
    }()
    
    lazy var settingsButton: BDButton = {
        var button = BDButton(imageNamed: "SYMB_SETTINGS", buttonAction: {
            GameManager.shared.transition(self, toScene: .Settings, transition: SKTransition.moveIn(with: .down, duration: 0.5))
        })
        
        button.scaleTo(screenWithPercentage: 0.15)
        button.zPosition = 1
        return button
    }()
    
    lazy var antibodyButton: BDButton = {
        var button = BDButton(imageNamed: "antibody_1", buttonAction: {
            self.infoButton.setScale(0)
            self.popupMenu.bounce()
        })
        button.scaleTo(screenWithPercentage: 0.05)
        button.zPosition = 1
        return button
    }()

    lazy var yesButton: BDButton = {
        var button = BDButton(imageNamed: "BTN_PLAIN (6)", title:"Sure", buttonAction: {
            if PlayerStats.shared.getAntigens() >= 5 {
                self.popupMenu.setScale(0)
                if let viewController = self.view?.window?.rootViewController {
                    SwiftyAd.shared.showRewardedVideo(from: viewController)
                }
            } else if PlayerStats.shared.getAntigens() >= 300 {
                self.noAdsAlert()
            } else {
                self.showAlert()
            }
        })
        
        button.scaleTo(screenWithPercentage: 0.3)
        button.zPosition = 5
        button.titleLabel?.fontSize = CGFloat.universalFont(size: 32)
        return button
    }()
    
    lazy var noButton: BDButton = {
        var button = BDButton(imageNamed: "BTN_PLAIN (6)", title:"Nope", buttonAction: {
            self.popupMenu.setScale(0)
        })
        
        button.scaleTo(screenWithPercentage: 0.3)
        button.zPosition = 5
        button.titleLabel?.fontSize = CGFloat.universalFont(size: 32)
        return button
    }()

    lazy var infoButton: BDButton = {
        var button = BDButton(imageNamed: "information", buttonAction: {
            self.infoButton.setScale(0)
        })
        //button.scaleTo(screenWithPercentage: 0.8)
        button.zPosition = 5
        return button
    }()
    
    override func didMove(to view: SKView) {
        SwiftyAd.shared.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(self.startGameplayNotification(_:)), name: startGameplayNotificationName, object: nil)
        
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        playButton.position = CGPoint.zero
        addChild(playButton)
        settingsButton.position = CGPoint(x: 0, y: ScreenSize.height * -0.1)
        addChild(settingsButton)
        
        antibodyButton.position = CGPoint(x: ScreenSize.width * 0.33, y: ScreenSize.height * 0.45)
        addChild(antibodyButton)
        if PlayerStats.shared.getNoAds() {antibodyButton.isHidden = true} else {antibodyButton.isHidden = false}

        playButton.button.popUp()
        settingsButton.button.popUp(after: 0.5, sequenceNumber: 2)
        
        //BG
        let background = SKSpriteNode(texture: background_Texture)
        background.zPosition = -15
        background.position = CGPoint(x: 0 , y: 0)
        background.setScale(0.5)
        background.size.width = ScreenSize.width
        let castle = SKSpriteNode(texture: CastleTexture)
        castle.zPosition = -10
        castle.position = CGPoint(x: 0, y: 0)
        castle.setScale(0.5)
        castle.size.width = ScreenSize.width * 0.75
        let logo = SKSpriteNode(texture:logoTexture)
        logo.zPosition = -5
        logo.position = CGPoint(x: 0, y: ScreenSize.height * 0.25)
        logo.setScale(0.5)

        addChild(background)
        addChild(castle)
        addChild(logo)
        
        // Labels
        BestScoreLabel = SKLabelNode(fontNamed :"GamjaFlower-Regular")
        BestScoreLabel.fontColor = SKColor.white;
        BestScoreLabel.fontSize = CGFloat.universalFont(size: 36)
        BestScoreLabel.horizontalAlignmentMode = .center;
        BestScoreLabel.text = "Best Score: \(PlayerStats.shared.getBestScore())";
        BestScoreLabel.position = CGPoint(x: 0, y: ScreenSize.height * -0.3);
        self.addChild(BestScoreLabel);
        
        BestPlatformLabel = SKLabelNode(fontNamed :"GamjaFlower-Regular")
        BestPlatformLabel.fontColor = SKColor.white;
        BestPlatformLabel.fontSize = CGFloat.universalFont(size: 36)
        BestPlatformLabel.horizontalAlignmentMode = .center;
        BestPlatformLabel.text = "Best Platforms: \(PlayerStats.shared.getBestPlatformScore())";
        BestPlatformLabel.position = CGPoint(x: 0, y: ScreenSize.height * -0.4);
        self.addChild(BestPlatformLabel);
        
        countdownLabel.position = CGPoint(x: ScreenSize.width * 0.4, y: ScreenSize.height * 0.41)
        addChild(countdownLabel)
        
        AntigensLabel = SKLabelNode(fontNamed :"GamjaFlower-Regular")
        AntigensLabel.fontColor = SKColor.white;
        AntigensLabel.fontSize = CGFloat.universalFont(size: 24)
        AntigensLabel.horizontalAlignmentMode = .center;
        AntigensLabel.text = "X\(PlayerStats.shared.getAntigens())";
        AntigensLabel.position = CGPoint(x: ScreenSize.width * 0.42, y: ScreenSize.height * 0.43)
        self.addChild(AntigensLabel);
        self.addChild(antibodySprite)
        antibodySprite.position = CGPoint(x: ScreenSize.width * 0.33, y: ScreenSize.height * 0.45)
        
        // popup menu
        addChild(popupMenu)
        popupMenu.position = CGPoint.zero
        //popupMenu.setScale(1)
        popupMenu.zPosition = 5
        popupMenu.setScale(0)
        popupMenu.addChild(yesButton)
        yesButton.position = CGPoint(x: -80, y: -100);
        popupMenu.addChild(noButton)
        noButton.position = CGPoint(x: 80, y: -100);

        addChild(infoButton)
        infoButton.position = CGPoint.zero
        if PlayerStats.shared.getAntigens() == 0
        {
            infoButton.scaleTo(screenWithPercentage: 0.8)
        } else {
            infoButton.setScale(0)
        }
    }

    override func update(_ currentTime: TimeInterval) {
        if !PlayerStats.shared.getNoAds() {
            countdownLabel.text = "\(AntiBodyTimer.shared.minutesText!):\(AntiBodyTimer.shared.secondsText!)"
            if AntiBodyTimer.shared.minutesText == "00" && AntiBodyTimer.shared.secondsText == "00"{
                countdownLabel.isHidden = true
                antibodyButton.isHidden = false
            } else {
                countdownLabel.isHidden = false
                antibodyButton.isHidden = true
            }
        }
        if antibodyButton.isHidden == true {antibodySprite.isHidden = false} else {antibodySprite.isHidden = true}
    }
    
    func showAlert() {
        let okAction = UIAlertAction(title: "Ok", style: .default) { (result) in
            self.popupMenu.setScale(0)
        }
        GameManager.shared.showAlert(on: self, title: "Prohibited", message: "Not Enough Antigens! Need 5 to get short effect antibody, 300 to get permanent antibody!", preferredStyle: .alert, actions: [okAction], animated: true, delay: 0.1) {
        }
    }

    func noAdsAlert() {
        let okAction = UIAlertAction(title: "Cool!", style: .default) { (result) in
            PlayerStats.shared.setNoAds(true)
        }
        GameManager.shared.showAlert(on: self, title: "Permanent Antibody", message: "You got the permanent antibody, you will no longer get infected!", preferredStyle: .alert, actions: [okAction], animated: true, delay: 0.1) {
        }
    }
    
    @objc func startGameplayNotification(_ info:Notification) {
        startGameplay()
    }
    
    func startGameplay() {
        GameManager.shared.transition(self, toScene: .Gameplay, transition: SKTransition.moveIn(with: .up, duration: 0.5))
    }
}

extension MainMenu: SwiftyAdDelegate {
    func swiftyAd(_ swiftyAd: SwiftyAd, didRewardUserWithAmount rewardAmount: Int) {
    }
    
    func swiftyAdDidOpen(_ swiftyAd: SwiftyAd) {
        NotificationCenter.default.post(name: stopBackgroundMusicNotificationName, object: nil, userInfo: nil)
    }
    func swiftyAdDidClose(_ swiftyAd: SwiftyAd) {
        NotificationCenter.default.post(name: startBackgroundMusicNotificationName, object: nil, userInfo: nil)
        //NotificationCenter.default.post(name: startGameplayNotificationName, object: nil, userInfo: nil)
        AntiBodyTimer.shared.startTimer()
        self.Antigens -= 5
    }
}
