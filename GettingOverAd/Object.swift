//
//  Objects.swift
//  GettingOverAd
//
//  Created by Benjamin Hao on 2018-02-27.
//  Copyright © 2018 Benjamin Hao. All rights reserved.
//

import Foundation
import SpriteKit

class Object: SKNode
{
    var objectSprite:SKSpriteNode = SKSpriteNode()
    var imageName:String = ""
    
    var spreadWidth:CGFloat = 0
    var spreadHeight:CGFloat = 0
    
    var facingRight:CGFloat = 0
    var facingLeft:CGFloat = 0
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(spreadWidth:CGFloat, spreadHeight:CGFloat)
    {
        super.init()
        self.spreadWidth = spreadWidth
        self.spreadHeight = spreadHeight
        createObject();
    }
    
    @objc func rfrogAttact()
    {
        objectSprite.removeAction(forKey: "rFrogIdleKey")
        objectSprite.run(redFrogAttactAction!, completion: {
            self.rfrog_update()
        });
        // make some delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            //if ((thePlayerPosition?.x)! < self.objectSprite.position.x)
            if (self.objectSprite.position.x) > 0
            {
                    self.objectSprite.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width:self.objectSprite.size.width/2.2,height:self.objectSprite.size.height/2.7), center:CGPoint(x: self.objectSprite.size.width * 0.15, y:0.5))
            }else{
                   self.objectSprite.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width:self.objectSprite.size.width/2.2,height:self.objectSprite.size.height/2.7), center:CGPoint(x: self.objectSprite.size.width * 0.15, y:0.5))
            }
        self.objectSprite.physicsBody!.categoryBitMask = BodyType.enemy.rawValue
            self.objectSprite.physicsBody!.collisionBitMask = BodyType.player.rawValue | BodyType.platform.rawValue | BodyType.platformUsed.rawValue
        self.objectSprite.physicsBody!.contactTestBitMask = BodyType.player.rawValue
        
        self.objectSprite.physicsBody!.friction = 1
        self.objectSprite.physicsBody!.isDynamic = true
        self.objectSprite.physicsBody!.affectedByGravity = true
        self.objectSprite.physicsBody!.restitution = 0.0
        self.objectSprite.physicsBody!.allowsRotation = false
        }
    }
    
    @objc func gfrogJump()
    {
        //if ((thePlayerPosition?.x)! < self.objectSprite.position.x)
        if self.objectSprite.position.x > 0
        {
            self.objectFacingRight(right: false)
        }
        else
        {
            self.objectFacingRight(right: true)
        }
        self.objectSprite.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 60))

            self.objectSprite.run(greenFrogJumpAction!, completion: {
                self.objectSprite.run(greenFrogFallAction!)
            })
    }
    
    @objc func birdFly()
    {
//        objectSprite.run(SKAction.move(by: CGVector(dx:400, dy:0), duration: 1.5), completion: {
//            self.objectFacingRight(right: false)
//            self.objectSprite.run(SKAction.move(by: CGVector(dx:-800, dy:0), duration: 3), completion: {
//                self.objectFacingRight(right: true)
//                self.objectSprite.run(SKAction.move(by: CGVector(dx:400, dy:0), duration: 1.5))
//            })
//        })
        
        objectSprite.run(SKAction.move(by: CGVector(dx:400, dy:0), duration: 1.5), completion: {
            self.objectSprite.xScale = self.objectSprite.xScale * -1;
            self.objectSprite.run(SKAction.move(by: CGVector(dx:-800, dy:0), duration: 3), completion: {
                self.objectSprite.xScale = self.objectSprite.xScale * -1;
                self.objectSprite.run(SKAction.move(by: CGVector(dx:400, dy:0), duration: 1.5))
            })
        })
    }
    
    func createObject()
    {
        let rand = arc4random_uniform(3)
        
        if (rand == 0) {
            imageName = "gfrog_idle_1"
        } else if ( rand == 1) {
            imageName = "rfrog_idle_1"
        } else if ( rand == 2) {
            imageName = "bird_fly_1"
        }
        
        objectSprite = SKSpriteNode(imageNamed:imageName)
        self.addChild(objectSprite)
        objectSprite.name = "Enemy"
        self.zPosition = 20
        
        // Direction stuff
        facingRight = self.xScale
        facingLeft = self.xScale * -1
        
        if (imageName == "gfrog_idle_1")
        {
            objectSprite.xScale = 1.5;
            objectSprite.yScale = 1.5;
            objectSprite.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width:objectSprite.size.width/2.2,height:objectSprite.size.height/2.7), center:CGPoint(x: 0, y: -objectSprite.size.height * 0.3))
            objectSprite.physicsBody!.categoryBitMask = BodyType.enemy.rawValue
            objectSprite.physicsBody!.collisionBitMask = BodyType.player.rawValue | BodyType.platform.rawValue | BodyType.platformUsed.rawValue
            objectSprite.physicsBody!.contactTestBitMask = BodyType.player.rawValue
            
            objectSprite.physicsBody!.friction = 1
            objectSprite.physicsBody!.isDynamic = true
            objectSprite.physicsBody!.affectedByGravity = true
            objectSprite.physicsBody!.restitution = 0.0
            objectSprite.physicsBody!.allowsRotation = false

            let randX = arc4random_uniform(UInt32(spreadWidth))
            self.position = CGPoint( x: CGFloat(randX) - (spreadWidth / 2),  y: 30)
            self.objectSprite.removeAction(forKey: "gFrogLandKey")
            objectSprite.run(greenFrogIdleAction!, withKey:"gFrogIdleKey");
            Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(self.gfrogJump), userInfo: 3, repeats: true)
        }
        else if (imageName == "rfrog_idle_1")
        {
            objectSprite.xScale = 1.5;
            objectSprite.yScale = 1.5;
            objectSprite.anchorPoint = CGPoint(x:0.23,y:0.18)
            
            rfrog_update()
            
            let randX = arc4random_uniform(UInt32(spreadWidth))
            self.position = CGPoint( x: CGFloat(randX) - (spreadWidth / 2),  y: 30)
            Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(self.rfrogAttact), userInfo: 3, repeats: true)
        }
        else if (imageName == "bird_fly_1")
        {
            objectSprite.xScale = 1.5;
            objectSprite.yScale = 1.5;
            objectSprite.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width:objectSprite.size.width/1.4,height:objectSprite.size.height/2.7))
            objectSprite.physicsBody!.categoryBitMask = BodyType.enemy.rawValue
            //objectSprite.physicsBody!.contactTestBitMask = BodyType.deathObject.rawValue | BodyType.enemy.rawValue | BodyType.player.rawValue
            objectSprite.physicsBody!.collisionBitMask = BodyType.player.rawValue
            objectSprite.physicsBody!.contactTestBitMask = BodyType.player.rawValue

            objectSprite.zPosition = 11;
            
            objectSprite.physicsBody!.friction = 0;
            objectSprite.physicsBody!.isDynamic = true
            objectSprite.physicsBody!.affectedByGravity = false
            objectSprite.physicsBody!.restitution = 0.0
            objectSprite.physicsBody!.allowsRotation = false
            
            let randY = arc4random_uniform(UInt32(200))
            self.position = CGPoint( x: 0,  y: CGFloat(randY))
            objectSprite.run(birdFlyAction!, withKey:"birdFly");
            birdFly()
            Timer.scheduledTimer(timeInterval: 6, target: self, selector: #selector(self.birdFly), userInfo: 6, repeats: true)
        }
    }

    func rfrog_update()
    {
        //if ((thePlayerPosition?.x)! < self.objectSprite.position.x)
        if self.objectSprite.position.x > 0
        {
            self.objectFacingRight(right: false)
        }
        else
        {
            self.objectFacingRight(right: true)
        }
            objectSprite.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width:objectSprite.size.width/4.2,height:objectSprite.size.height/2.7))//, center:CGPoint(x:objectSprite.size.width * 0.15, y:0.5))
            objectSprite.physicsBody!.categoryBitMask = BodyType.enemy.rawValue
            objectSprite.physicsBody!.collisionBitMask = BodyType.player.rawValue | BodyType.platform.rawValue | BodyType.platformUsed.rawValue
            objectSprite.physicsBody!.contactTestBitMask = BodyType.player.rawValue
            
            objectSprite.physicsBody!.friction = 1
            objectSprite.physicsBody!.isDynamic = true
            objectSprite.physicsBody!.affectedByGravity = true
            objectSprite.physicsBody!.restitution = 0.0
            objectSprite.physicsBody!.allowsRotation = false
            objectSprite.run(redFrogIdleAction!, withKey:"rFrogIdleKey");
    }
    
    func objectFacingRight(right:Bool)
    {
        if right
        {
            self.xScale = facingRight
        }
        else
        {
            self.xScale = facingLeft
        }
    }
}
