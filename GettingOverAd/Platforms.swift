//
//  DifficultyUnit.swift
//  GettingOverAd
//
//  Created by Benjamin Hao on 2018-03-15.
//  Copyright © 2018 Benjamin Hao. All rights reserved.
//

import Foundation
import SpriteKit

class Platforms:SKNode
{
    var imageName:String = ""
    var platformSprite:SKSpriteNode = SKSpriteNode()
    var width:CGFloat = 0
    var height:CGFloat = 0
    
    var yAmount:CGFloat = 1  //essentially this is our speed
    var direction:CGFloat = 1 //will be saved as either 1 or -1
    var numberOfObjectsInLevel:UInt32 = 0
    var offscreenCounter:Int = 0 //anytime an object goes offscreen we add to this, for resetting speed purposes
    var maxObjectsInLevelUnit:UInt32 = 2
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init (xPos:CGFloat, yPos:CGFloat, isFirst:Bool) {
        super.init()
        
        zPosition = 0;
        position = CGPoint(x: xPos, y: yPos);
        self.height = 20;
    
        let diceRoll = arc4random_uniform(3)
        
        if (diceRoll == 0) {
            self.width = 150
            imageName = "platform"
        } else if (diceRoll == 1) {
            self.width = 200;
            imageName = "platform_long"
        } else if (diceRoll == 2) {
            self.width = 100
            imageName = "platform_short"
        }
        
        let theSize:CGSize = CGSize(width: width, height: height)
        let tex:SKTexture = SKTexture(imageNamed: imageName)
        platformSprite = SKSpriteNode(texture: tex, color: SKColor.clear, size: theSize)
        self.addChild(platformSprite)
        self.name = "Platform"
        
        platformSprite.physicsBody = SKPhysicsBody(rectangleOf: platformSprite.size)
        //center:CGPoint(x: 0, y: -platformSprite.size.height * 0.88)
        platformSprite.physicsBody!.isDynamic = false
        platformSprite.physicsBody!.affectedByGravity = true
        platformSprite.physicsBody!.allowsRotation = true
        platformSprite.physicsBody!.restitution = 0
        platformSprite.physicsBody!.categoryBitMask = BodyType.platform.rawValue
        //platformSprite.physicsBody!.contactTestBitMask = BodyType.player.rawValue
        platformSprite.physicsBody!.collisionBitMask = BodyType.player.rawValue | BodyType.enemy.rawValue
        if ( isFirst == false ) {
            createObstacle()
        } else {
            platformSprite.physicsBody!.categoryBitMask = BodyType.platformUsed.rawValue
        }
    }
    
    // create obstacles
    func createObstacle() {
//        let randomSpawn = arc4random_uniform(3)
        numberOfObjectsInLevel = arc4random_uniform(maxObjectsInLevelUnit) // 0 or 1
        if platformSprite.size.width != 100   // short platform won't create monsters
        {
            for _ in 0 ..< Int(numberOfObjectsInLevel) {
                
                let obstacle:Object = Object(spreadWidth: width - 10, spreadHeight: height)
                addChild(obstacle)
            }
        }
    }
}
