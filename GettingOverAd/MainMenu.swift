//
//  MainMenu.swift
//  GettingOverAd
//
//  Created by Benjamin Hao on 2018-04-11.
//  Copyright © 2018 Benjamin Hao. All rights reserved.
//

import Foundation
import SpriteKit

class MainMenu: SKScene {
    var background_Texture = SKTexture(imageNamed: "backgroundX_1")
    var CastleTexture = SKTexture(imageNamed: "castleX")
    var logoTexture = SKTexture(imageNamed: "logo")
    var BestScoreLabel:SKLabelNode!;
    var BestPlatformLabel:SKLabelNode!;
    
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
    
    override func didMove(to view: SKView) {
        NotificationCenter.default.addObserver(self, selector: #selector(self.startGameplayNotification(_:)), name: startGameplayNotificationName, object: nil)
        
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        playButton.position = CGPoint.zero
        addChild(playButton)
        
        settingsButton.position = CGPoint(x: ScreenSize.width * 0.0, y: ScreenSize.height * -0.1)
        addChild(settingsButton)
        
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
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //    for touch in touches {
        //      if touch == touches.first {
        //        print("Going to Gameplay scene")
        //        //ACTManager.shared.transition(self, toScene: .Gameplay)
        //
        //
        //        enumerateChildNodes(withName: "//*", using: { (node, stop) in
        //          if node.name == "playButton" {
        //            if node.contains(touch.location(in: self)) {
        //              ACTManager.shared.transition(self, toScene: .Gameplay, transition: SKTransition.moveIn(with: .right, duration: 0.5))
        //            }
        //          }
        //        })
        //
        //      }
        //    }
    }
    
    //  func addPlayButton() {
    //    let playButton = SKSpriteNode(imageNamed: "ButtonPlay")
    //    playButton.name = "playButton"
    //    playButton.position = CGPoint.zero
    //    addChild(playButton)
    //  }
    
    @objc func startGameplayNotification(_ info:Notification) {
        startGameplay()
    }
    
    func startGameplay() {
        GameManager.shared.transition(self, toScene: .Gameplay, transition: SKTransition.moveIn(with: .up, duration: 0.5))
    }
}






