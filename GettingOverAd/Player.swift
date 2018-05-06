//
//  Player.swift
//  GettingOverAd
//
//  Created by Benjamin Hao on 2018-02-26.
//  Copyright © 2018 Benjamin Hao. All rights reserved.
//

import Foundation
import SpriteKit

class Player: SKSpriteNode
{
    var directionArrow:SKSpriteNode = SKSpriteNode(imageNamed:"arrow")
    var chargeSprite:SKSpriteNode = SKSpriteNode()
    var chargingSprite:SKSpriteNode = SKSpriteNode()

    var runAction: SKAction?
    var idleAction: SKAction?
    var jumpAction: SKAction?
    var fallAction: SKAction?
    //var grabAction: SKAction?
    var diedAction: SKAction?
    
    var isIdling:Bool = false
    var isJumping:Bool = false
    var isFalling:Bool = false
    //var isGrabbing:Bool = false
    var isRunning:Bool = false
    var isDead:Bool = false
    
    var jumpAmount:CGFloat = 0
    var fallTime:TimeInterval = 2
    var slideTime:TimeInterval = 0.5
    
    var initialDY:CGFloat = 0

    var facingRight:CGFloat = 0
    var facingLeft:CGFloat = 0
    var arrowStuff:CGFloat = 0
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init (imageNamed: String)
    {
        let imageTexture = SKTexture(imageNamed: imageNamed)
        super.init(texture:imageTexture, color:SKColor.clear, size:(imageTexture.size()))
        // resize the player node
        // TODO: may need to change physicasbody later
        super.setScale(2.5)
        
        let body:SKPhysicsBody = SKPhysicsBody(rectangleOf: CGSize(width:imageTexture.size().width*2.3,height:imageTexture.size().height*2));
        //SKPhysicsBody(circleOfRadius: imageTexture.size().width/2);
        body.isDynamic = true
        body.affectedByGravity = true
        body.allowsRotation = false
        //body.restitution = 0.0
        body.categoryBitMask = BodyType.player.rawValue
        body.contactTestBitMask = BodyType.platform.rawValue | BodyType.platformUsed.rawValue | BodyType.enemy.rawValue
        body.collisionBitMask = BodyType.enemy.rawValue | BodyType.platform.rawValue | BodyType.platformUsed.rawValue
        body.usesPreciseCollisionDetection = true
        self.physicsBody = body;
        self.zPosition = 10;

        // handle direction arrow
        directionArrow.isHidden = true
        directionArrow.setScale(0.08)
        directionArrow.colorBlendFactor = 1
        directionArrow.color = .white
        //directionArrow.color = UIColor(red:0.53, green:0.81, blue:0.92, alpha:1.0)
        directionArrow.zPosition = 10
        directionArrow.position = CGPoint(x:self.position.x, y:self.position.y + 20)
        self.addChild(directionArrow)
        
        //charge
        chargeSprite = SKSpriteNode(imageNamed:"charge_1")
        chargeSprite.setScale(0.5)
        self.addChild(chargeSprite)
        chargeSprite.zPosition = 15
        chargingSprite = SKSpriteNode(imageNamed:"charge_1")
        //chargingSprite.setScale(0.5)
        self.addChild(chargingSprite)
        chargingSprite.zPosition = 16
        
        // Direction stuff
        facingRight = self.xScale
        facingLeft = self.xScale * -1
        arrowStuff = self.directionArrow.xScale * -1
        
        // Set up action for animations
        setUpRun()
        setUpIdle()
        setUpJump()
        setUpFall()
        //setUpGrab()
    }
    
//    func _update()
//    {
//        initialDY = self.physicsBody!.velocity.dy;
//    }
    
    func setUpIdle()
    {
        let atlas = SKTextureAtlas(named: "Player")
        var atlasTextures:[SKTexture] = []
        
        for i in 1...12
        {
            let textureName = "player_idle_\(i)"
            let texture = atlas.textureNamed(textureName)
            atlasTextures.append(texture)
        }
        
        let atlasAnimation = SKAction.animate(with: atlasTextures, timePerFrame: 1.0/20, resize: true, restore: false)
        idleAction = SKAction.repeatForever(atlasAnimation)
    }
    
    func setUpRun()
    {
        let atlas = SKTextureAtlas(named: "Player")
        var atlasTextures:[SKTexture] = []
        
        for i in 1...8
        {
            let textureName = "player_run_\(i)"
            let texture = atlas.textureNamed(textureName)
            atlasTextures.append(texture)
        }
        
        let atlasAnimation = SKAction.animate(with: atlasTextures, timePerFrame: 1.0/20, resize: true, restore: false)
        runAction = SKAction.repeatForever(atlasAnimation)
    }
    
    func setUpJump()
    {
        let atlas = SKTextureAtlas(named: "Player")
        var atlasTextures:[SKTexture] = []
        
        for i in 1...2
        {
            let textureName = "player_jump_\(i)"
            let texture = atlas.textureNamed(textureName)
            atlasTextures.append(texture)
        }
        
        let atlasAnimation = SKAction.animate(with: atlasTextures, timePerFrame: 1.0/10, resize: true, restore: false)
        jumpAction = SKAction.repeatForever(atlasAnimation)
    }
    
    func setUpFall()
    {
        let atlas = SKTextureAtlas(named: "Player")
        var atlasTextures:[SKTexture] = []
        
        for i in 1...2
        {
            let textureName = "player_land_\(i)"
            let texture = atlas.textureNamed(textureName)
            atlasTextures.append(texture)
        }
        
        let atlasAnimation = SKAction.animate(with: atlasTextures, timePerFrame: 1.0/10, resize: true, restore: false)
        fallAction = SKAction.repeatForever(atlasAnimation)
    }
    
//    func setUpGrab()
//    {
//        let atlas = SKTextureAtlas(named: "Player")
//        var atlasTextures:[SKTexture] = []
//
//        for i in 1...6
//        {
//            let textureName = "player_grab_\(i)"
//            let texture = atlas.textureNamed(textureName)
//            atlasTextures.append(texture)
//        }
//
//        let atlasAnimation = SKAction.animate(with: atlasTextures, timePerFrame: 1.0/10, resize: true, restore: false)
//        grabAction = SKAction.repeatForever(atlasAnimation)
//    }
    
    func startIdle()
    {
        isIdling = true
        //isGrabbing = false
        isJumping = false
        isFalling = false
        isRunning = false

        self.removeAction(forKey: "jumpKey")
        //self.removeAction(forKey: "grabKey")
        self.removeAction(forKey: "fallKey")
        self.removeAction(forKey: "runKey")
        self.run(idleAction!, withKey: "idleKey")
    }
    
    func startRun()
    {
        isIdling = true
        //isGrabbing = false
        isJumping = false
        isFalling = false
        isRunning = true
        
        self.removeAction(forKey: "idleKey")
        self.removeAction(forKey: "jumpKey")
        //self.removeAction(forKey: "grabKey")
        self.removeAction(forKey: "fallKey")
        self.run(runAction!, withKey: "runKey")
    }
    
//    func startGrab()
//    {
//        isIdling = false
//        isGrabbing = true
//        isJumping = false
//        isFalling = false
//        isRunning = false
//
//        self.removeAction(forKey: "idleKey")
//        self.removeAction(forKey: "jumpKey")
//        self.removeAction(forKey: "fallKey")
//        self.removeAction(forKey: "runKey")
//        self.run(grabAction!, withKey: "grabKey")
//    }
    
    func startJump()
    {
        isIdling = false
        //isGrabbing = false
        isJumping = true
        isFalling = false
        isRunning = false

        self.removeAction(forKey: "idleKey")
        //self.removeAction(forKey: "grabKey")
        self.removeAction(forKey: "fallKey")
        self.removeAction(forKey: "runKey")
        self.run(jumpAction!, withKey: "jumpKey")
    }
    
    func startFall()
    {
        isIdling = false
        //isGrabbing = false
        isJumping = false
        isFalling = true
        isRunning = false

        self.removeAction(forKey: "idleKey")
        //self.removeAction(forKey: "grabKey")
        self.removeAction(forKey: "jumpKey")
        self.removeAction(forKey: "runKey")
        self.run(fallAction!, withKey: "fallKey")
    }
    
    func playerFacingRight(right:Bool)
    {
        if right
        {
            self.xScale = facingRight
        }
        else
        {
            self.xScale = facingLeft
            self.directionArrow.xScale = arrowStuff
        }
    }
}
