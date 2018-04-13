//
//  GameplayScene.swift
//  GettingOverAd
//
//  Created by Benjamin Hao on 2018-02-05.
//  Copyright © 2018 Benjamin Hao. All rights reserved.
//
import Foundation
import SpriteKit

enum BodyType:UInt32 {
    case player = 1
    case platform = 2
    case platformUsed = 4
    case enemy = 8
    case nothing = 16
}

var redFrogIdleAction:SKAction?
var redFrogAttactAction:SKAction?
var greenFrogIdleAction:SKAction?
var greenFrogJumpAction:SKAction?
var greenFrogFallAction:SKAction?
var birdFlyAction:SKAction?
var VirusAction:SKAction?
var enemyDiedAction:SKAction?
var diedAction:SKAction?
var chargeAction: SKAction?
var chargeDoneAction: SKAction?
var shakeAction:SKAction?
var feverAction:SKAction?

var thePlayerPosition:CGPoint? = CGPoint(x: 0, y: 0)

class GameplayScene: SKScene,SKPhysicsContactDelegate
{
    var countdownTimer: Timer!
    var bonus:Int = 0
    
    let worldNode:SKNode = SKNode();
    var virusSprite:SKSpriteNode = SKSpriteNode()
    var statusSprite:SKSpriteNode = SKSpriteNode()
    var background_Texture = SKTexture(imageNamed: "background_1")
    var backgroundTexture = SKTexture(imageNamed: "background_2")
    var CastleTexture = SKTexture(imageNamed: "castle")
    let thePlayer:Player = Player(imageNamed:"player_idle_1");
    var scoreLabel:SKLabelNode!;
    var timerLabel:SKLabelNode!;
    var platformLabel:SKLabelNode!;
    var fingerLocation:CGPoint = CGPoint();

    var PlatformsCounter:CGFloat = 1
    var PlatformWidth:CGFloat = 0
    var PlatformHeight:CGFloat = 0
    var initialUnits:Int = 6
    var screenWidth:CGFloat = 0
    var screenHeight:CGFloat = 0
    var screenBottomY:CGFloat = 0
    var screenTopY:CGFloat = 0
    var isDead:Bool = false
    var usedPlatform:Bool = false
    var currentPlatform:SKSpriteNode?
    
    var touched:Bool = false;
    var runOnce:Bool = true;
    var statusChanged = 0
    var jumpPressure:CGFloat = 0;
    var MinJumpPressure:CGFloat = 10;
    var MaxJumpPressure:CGFloat = 150;
    
    let playerStartingPos:CGPoint = CGPoint(x: 0, y: -400)
    
    var jumpedPlatform: Int = 0 {
        didSet{
            PlayerStats.shared.setPlatformScore(jumpedPlatform)
            platformLabel.text = "Platforms: \(PlayerStats.shared.getPlatformScore())";
        }
    }
    var score:Int = 0 {
        didSet{
            PlayerStats.shared.setScore(score)
            scoreLabel.text = "Score: \(PlayerStats.shared.getScore())";
        }
    }
    
    var feverTimeDuration = 10 {
        didSet{
            timerLabel.text = "\(feverTimeDuration)";
        }
    }
    
    override func didMove(to view: SKView)
    {
        print(ScreenSize.height, screenWidth)
        print(self.frame.size)

        self.backgroundColor = SKColor.white

        screenWidth = self.view!.bounds.width
        screenHeight = self.view!.bounds.height
        screenTopY = self.frame.maxY;
        screenBottomY = self.frame.minY;
        setUpText()
        setUpRedFrogIdle()
        setUpRedFrogAttact()
        setUpGreenFrogIdle()
        setUpGreenFrogJump()
        setUpGreenFrogFall()
        setUpBirdFly()
        setUpVirusAnimation()
        setUpenemyDiedAnimation()
        setUpDeathAnimation()
        setUpChargeAnimation()
        setUpShakeAction()
        setUpFeverAnimation()
        
        //BG
        let background = SKSpriteNode(texture: background_Texture)
        background.zPosition = -21
        background.position = CGPoint(x: 0 , y: 0)
        let castle = SKSpriteNode(texture: CastleTexture)
        castle.zPosition = -11
        castle.position = CGPoint(x: 0, y: 0)
        addChild(background)
        addChild(castle)
        
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVector(dx:0, dy:-10)
        
        // Move origin to center
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        // Add Virus
        virusSprite = SKSpriteNode(imageNamed:"virus_1")
        addChild(virusSprite)
        virusSprite.xScale = 3
        virusSprite.yScale = 2.5
        virusSprite.zPosition = 30
        virusSprite.run(VirusAction!)
        virusSprite.position = CGPoint(x:0, y:screenBottomY + 80)
        
        // Add fancy stuff
        addChild(statusSprite)
        statusSprite.position = CGPoint(x: 0, y: screenTopY - 50);
        statusSprite.zPosition = 50
        
        // Add world node
        addChild(worldNode)

        // Add the player
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.worldNode.addChild(self.thePlayer)
            self.thePlayer.position = self.playerStartingPos
            self.thePlayer.zPosition = 10
        }
        populatePlatforms()

    }
    
    func setUpText() {
        platformLabel = SKLabelNode(fontNamed :"GamjaFlower-Regular")
        platformLabel.text = "Platforms: 0";
        platformLabel.fontColor = SKColor.white;
        platformLabel.horizontalAlignmentMode = .right;
        
        //scoreLabel.position = worldNode.convertPoint(CGPointMake(-100, 50), fromNode: self)
        platformLabel.position = CGPoint(x: frame.minX + 215, y: screenTopY - 100);
        
        //print(scoreLabel.position);
        
        //let nodeLocation:CGPoint = self.convertPoint(node.position, fromNode: self.worldNode)
        self.addChild(platformLabel);
        platformLabel.zPosition = 50
        
        scoreLabel = SKLabelNode(fontNamed :"GamjaFlower-Regular")
        scoreLabel.text = "Score: 0";
        scoreLabel.fontColor = SKColor.white;
        scoreLabel.horizontalAlignmentMode = .right;
        
        //scoreLabel.position = worldNode.convertPoint(CGPointMake(-100, 50), fromNode: self)
        scoreLabel.position = CGPoint(x: frame.minX + 150, y: screenTopY - 50);
        
        //print(scoreLabel.position);
        
        //let nodeLocation:CGPoint = self.convertPoint(node.position, fromNode: self.worldNode)
        self.addChild(scoreLabel);
        scoreLabel.zPosition = 50
        
        timerLabel = SKLabelNode(fontNamed :"GamjaFlower-Regular")
        timerLabel.fontSize = CGFloat.universalFont(size: 10)
        timerLabel.text = "";
        timerLabel.fontColor = SKColor.white;
        timerLabel.horizontalAlignmentMode = .right;
        
        //scoreLabel.position = worldNode.convertPoint(CGPointMake(-100, 50), fromNode: self)
        timerLabel.position = CGPoint(x: 0, y: screenTopY - 100);
        
        //print(scoreLabel.position);
        
        //let nodeLocation:CGPoint = self.convertPoint(node.position, fromNode: self.worldNode)
        self.addChild(timerLabel);
        timerLabel.zPosition = 50
    }
    
    func setUpRedFrogIdle()
    {
        let atlas = SKTextureAtlas(named: "Enemy")
        var atlasTextures:[SKTexture] = []
        
        for i in 1...12
        {
            let textureName = "rfrog_idle_\(i)"
            let texture = atlas.textureNamed(textureName)
            atlasTextures.append(texture)
        }
        
        let atlasAnimation = SKAction.animate(with: atlasTextures, timePerFrame: 1.0/10, resize: true , restore:false )
        redFrogIdleAction = SKAction.repeatForever(atlasAnimation)
    }
    
    func setUpRedFrogAttact()
    {
        let atlas = SKTextureAtlas(named: "Enemy")
        var atlasTextures:[SKTexture] = []
        
        for i in 1...10
        {
            let textureName = "rfrog_attack_\(i)"
            let texture = atlas.textureNamed(textureName)
            atlasTextures.append(texture)
        }
        
        let atlasAnimation = SKAction.animate(with: atlasTextures, timePerFrame: 1.0/15, resize: true , restore:true )
        redFrogAttactAction = SKAction.repeat(atlasAnimation, count: 1)
    }
    
    func setUpGreenFrogIdle()
    {
        let atlas = SKTextureAtlas(named: "Enemy")
        var atlasTextures:[SKTexture] = []
        
        for i in 1...12
        {
            let textureName = "gfrog_idle_\(i)"
            let texture = atlas.textureNamed(textureName)
            atlasTextures.append(texture)
        }
        
        let atlasAnimation = SKAction.animate(with: atlasTextures, timePerFrame: 1.0/10, resize: true , restore:false )
        greenFrogIdleAction = SKAction.repeatForever(atlasAnimation)
    }
    
    func setUpGreenFrogJump()
    {
        let atlas = SKTextureAtlas(named: "Enemy")
        var atlasTextures:[SKTexture] = []
        
        for i in 1...5
        {
            let textureName = "gfrog_jump_\(i)"
            let texture = atlas.textureNamed(textureName)
            atlasTextures.append(texture)
        }
        
        let atlasAnimation = SKAction.animate(with: atlasTextures, timePerFrame: 1.0/30, resize: true , restore:false )
        greenFrogJumpAction = SKAction.repeat(atlasAnimation, count:1)
    }
    
    func setUpGreenFrogFall()
    {
        let atlas = SKTextureAtlas(named: "Enemy")
        var atlasTextures:[SKTexture] = []
        
        for i in 1...8
        {
            let textureName = "gfrog_fall_\(i)"
            let texture = atlas.textureNamed(textureName)
            atlasTextures.append(texture)
        }
        
        let atlasAnimation = SKAction.animate(with: atlasTextures, timePerFrame: 1.0/8, resize: true , restore:false )
        greenFrogFallAction = SKAction.repeat(atlasAnimation, count:1)
    }
    
    func setUpBirdFly()
    {
        let atlas = SKTextureAtlas(named: "Enemy")
        var atlasTextures:[SKTexture] = []
        
        for i in 1...4
        {
            let textureName = "bird_fly_\(i)"
            let texture = atlas.textureNamed(textureName)
            atlasTextures.append(texture)
        }
        
        let atlasAnimation = SKAction.animate(with: atlasTextures, timePerFrame: 1.0/15, resize: true , restore:false )
        birdFlyAction = SKAction.repeatForever(atlasAnimation)
    }
    
    func setUpVirusAnimation()
    {
        let atlas = SKTextureAtlas(named: "Virus")
        var atlasTextures:[SKTexture] = []
        
        for i in 1...3
        {
            let textureName = "virus_\(i)"
            let texture = atlas.textureNamed(textureName)
            atlasTextures.append(texture)
        }
        
        let atlasAnimation = SKAction.animate(with: atlasTextures, timePerFrame: 1.0/5, resize: true , restore:false )
        VirusAction = SKAction.repeatForever(atlasAnimation)
    }
    
    func setUpenemyDiedAnimation()
    {
        let atlas = SKTextureAtlas (named: "FX")
        var atlasTextures:[SKTexture] = []
        
        for i in 1...10
        {
            let textureName = "explosion_\(i)"
            let texture = atlas.textureNamed(textureName)
            atlasTextures.append(texture)
        }
        
        let atlasAnimation = SKAction.animate(with: atlasTextures, timePerFrame: 1.0/40, resize: true , restore:true )
        enemyDiedAction =  SKAction.repeat(atlasAnimation, count:1)
    }
    
    func setUpDeathAnimation()
    {
        let atlas = SKTextureAtlas(named: "FX")
        var atlasTextures:[SKTexture] = []
        
        for i in 1...7
        {
            let textureName = "bling_\(i)"
            let texture = atlas.textureNamed(textureName)
            atlasTextures.append(texture)
        }
        
        let atlasAnimation = SKAction.animate(with: atlasTextures, timePerFrame: 1.0/20, resize: true, restore: false)
        diedAction = SKAction.repeat(atlasAnimation, count:1)
    }
    
    func setUpChargeAnimation()
    {
        let atlas = SKTextureAtlas(named: "FX")
        var atlasTextures:[SKTexture] = []
        
        for i in 1...14
        {
            let textureName = "charge_\(i)"
            let texture = atlas.textureNamed(textureName)
            atlasTextures.append(texture)
        }
        
        let atlasAnimation = SKAction.animate(with: atlasTextures, timePerFrame: 1.0/10, resize: true, restore: false)
        chargeAction = SKAction.repeat(atlasAnimation, count:1)
        
        let chargedoneAnimation = SKAction.animate(with: [SKTexture(imageNamed:"charge_1")], timePerFrame: 1, resize: true, restore: true)
        chargeDoneAction = SKAction.repeatForever(chargedoneAnimation)
    }
    
    func setUpShakeAction() {
        let amplitudeX:Float = 10;
        let amplitudeY:Float = 6;
        let numberOfShakes = 0.75 / 0.04; //duration: 0.75s
        var actionsArray:[SKAction] = [];
        for _ in 1...Int(numberOfShakes) {
            // build a new random shake and add it to the list
            let moveX = Float(arc4random_uniform(UInt32(amplitudeX))) - amplitudeX / 2;
            let moveY = Float(arc4random_uniform(UInt32(amplitudeY))) - amplitudeY / 2;
            let shakeAction = SKAction.moveBy(x: CGFloat(moveX), y: CGFloat(moveY), duration: 0.02);
            shakeAction.timingMode = SKActionTimingMode.easeOut;
            actionsArray.append(shakeAction);
            actionsArray.append(shakeAction.reversed());
        }
        shakeAction = SKAction.sequence(actionsArray);
    }
    
    func setUpFeverAnimation()
    {
        let atlas = SKTextureAtlas(named: "FX")
        var atlasTextures:[SKTexture] = []
        
        for i in 1...20
        {
            let textureName = "fever_\(i)"
            let texture = atlas.textureNamed(textureName)
            atlasTextures.append(texture)
        }
        
        let atlasAnimation = SKAction.animate(with: atlasTextures, timePerFrame: 1.0/10, resize: true , restore:true )
        feverAction = SKAction.repeatForever(atlasAnimation)
    }
    
    // TODO: REMOVE THIS
//    func setUpSwipeHandlers()
//    {
//        //pressRec.addTarget(self, action:#selector(GameplayScene.longPress))
//        //self.view!.addGestureRecognizer(pressRec);
//        tapRec.addTarget(self, action:#selector(GameplayScene.longPress))
//        self.view!.addGestureRecognizer(tapRec);
//    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            if(thePlayer.isIdling)
            {
                touched = true
                thePlayer.directionArrow.isHidden = false
                thePlayer.chargeSprite.run(chargeAction!)
            }
        
            fingerLocation = touch.location(in: worldNode)
            let radians = -atan2(fingerLocation.x - thePlayer.position.x, abs(fingerLocation.y - thePlayer.position.y))
            
            if (fingerLocation.x > thePlayer.position.x)
            {
                thePlayer.playerFacingRight(right: true)
                thePlayer.directionArrow.zRotation = radians
            }
            else
            {
                thePlayer.playerFacingRight(right: false)
                thePlayer.directionArrow.zRotation = -radians
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            fingerLocation = touch.location(in: worldNode)
            let radians = -atan2(fingerLocation.x - thePlayer.position.x, abs(fingerLocation.y - thePlayer.position.y))
            
            if (fingerLocation.x > thePlayer.position.x)
            {
                thePlayer.playerFacingRight(right: true)
                thePlayer.directionArrow.zRotation = radians
            }
            else
            {
                thePlayer.playerFacingRight(right: false)
                thePlayer.directionArrow.zRotation = -radians
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        thePlayer.directionArrow.isHidden = true
        touched = false
        thePlayer.chargeSprite.run(chargeDoneAction!)
        thePlayer.chargeSprite.removeAllActions()
        if (jumpPressure > 0 && thePlayer.isIdling)
        {   //如果是轻轻按下就松开则把最小蓄力值赋值给当前蓄力值
            //如果是按住不松则把上面递增的值传下来
            jumpPressure += MinJumpPressure;
            //给一个速度
            var xVector = (fingerLocation.x - thePlayer.position.x)
            var yVector = (fingerLocation.y - thePlayer.position.y)
            let magnitude = sqrt(xVector*xVector+yVector*yVector)
            xVector /= magnitude
            yVector /= magnitude
            let vector = CGVector(dx:jumpPressure*xVector, dy:jumpPressure*abs(yVector))

//            let JumpRadians = -atan2((fingerLocation.x - thePlayer.position.x), (fingerLocation.y - thePlayer.position.y))
//            let xForce:CGFloat = (cos(JumpRadians))
//            let yForce:CGFloat = (sin(JumpRadians))
//            thePlayer.physicsBody!.applyForce(CGVector(dx: jumpPressure*xForce, dy:jumpPressure*yForce))
            thePlayer.physicsBody!.applyImpulse(vector)

            jumpPressure = 0; //升空以后把蓄力值重设为0
        }
    }
    
    func createLoopingBG() {
        for i in 0 ... 1 {
            let initBG = SKSpriteNode(texture: background_Texture)
            let loopingBG = SKSpriteNode(texture: backgroundTexture)
            initBG.zPosition = -15
            loopingBG.zPosition = -20
            initBG.position = CGPoint(x: 0, y: 0)
            loopingBG.position = CGPoint(x: 0, y: (backgroundTexture.size().height * CGFloat(i)) - CGFloat(1 * i))
            addChild(initBG)
            addChild(loopingBG)
            
            let MoveDown:SKAction = SKAction.moveBy(x: 0, y: -loopingBG.size.height, duration: 90)
            let MoveReset:SKAction = SKAction.moveBy(x: 0, y: loopingBG.size.height, duration: 0)
            let MoveLoop:SKAction = SKAction.sequence([MoveDown, MoveReset])
            let MoveRepeat:SKAction = SKAction.repeatForever(MoveLoop)
            
            initBG.run(MoveDown)
            loopingBG.run(MoveRepeat)
        }
    }
    
    func createLoopingCastle() {
        for i in 0 ... 1 {
            let loopingCastle = SKSpriteNode(texture: CastleTexture)
            loopingCastle.zPosition = -10
            loopingCastle.position = CGPoint(x: 0, y: (CastleTexture.size().height * CGFloat(i)) - CGFloat(1 * i))
            addChild(loopingCastle)
            
            let MoveDown:SKAction = SKAction.moveBy(x: 0, y: -loopingCastle.size.height, duration: 45)
            let MoveReset:SKAction = SKAction.moveBy(x: 0, y: loopingCastle.size.height, duration: 0)
            let MoveLoop:SKAction = SKAction.sequence([MoveDown, MoveReset])
            let MoveRepeat:SKAction = SKAction.repeatForever(MoveLoop)
            
            loopingCastle.run(MoveRepeat)
        }
    }
    
//    func resetGame(){
//        worldNode.enumerateChildNodes(withName: "Platform" ) {
//            node, stop in
//            node.removeFromParent()
//        }
//        worldNode.position = CGPoint(x:0, y: -screenHeight*1.2)
//        PlatformsCounter = 1
//        score = 0;
//        populatePlatforms()
//        thePlayer.position = playerStartingPos
//    }
    
    func populatePlatforms(){
        for _ in 0 ..< initialUnits {
            createPlatform()
        }
    }
    
    func randomIntFrom(start: Int, to end: Int) -> Int {
        var a = start
        var b = end
        // swap to prevent negative integer crashes
        if a > b {
            swap(&a, &b)
        }
        return Int(arc4random_uniform(UInt32(b - a + 1))) + a
    }
    
    func createPlatform() {
        let platform:Platforms!;
        
        if (PlatformsCounter == 1) {
            platform = Platforms(xPos: 0,
                                  yPos:screenBottomY + 160,
                                  isFirst:true);
        } else if (PlatformsCounter == 2) {
            let randomSecondPlatform = arc4random_uniform(2)
            if randomSecondPlatform == 0
            {
                platform = Platforms(xPos: -200, // prevent stucking on the second platform
                    yPos:PlatformsCounter*(PlatformHeight+200) + screenBottomY - 140 + CGFloat(randomIntFrom(start:-20, to: 120)),
                    isFirst:false);
            } else {
                platform = Platforms(xPos: 200, // prevent stucking on the second platform
                    yPos:PlatformsCounter*(PlatformHeight+200) + screenBottomY - 140 + CGFloat(randomIntFrom(start:-20, to: 120)),
                    isFirst:false);
            }
        } else {
            platform = Platforms(xPos: CGFloat(randomIntFrom(start: -200, to:200)),
                                 yPos:PlatformsCounter*(PlatformHeight+200) + screenBottomY - 140 + CGFloat(randomIntFrom(start:-20, to: 160)),
                                  isFirst:false);
            //xPos:CGFloat(randomIntFrom(start: -200, to:200))
            //yPos:levelUnitCounter*(levelUnitHeight+CGFloat(randomIntFrom(start:200, to: 500))),

        }
        PlatformsCounter += 1
        worldNode.addChild(platform)
    }
    
    func clearNodes(){
        var nodeCount:Int = 0
        
        worldNode.enumerateChildNodes(withName: "Platform") {
            node, stop in
            let nodeLocation:CGPoint = self.convert(node.position, from: self.worldNode)
            
            // ADs AREA
            if ( nodeLocation.y < self.screenBottomY + 140) {
                node.removeFromParent()
            }  else {
                nodeCount += 1
            }
        }
        worldNode.enumerateChildNodes(withName: "Enemy") {
            node, stop in
            let nodeLocation:CGPoint = self.convert(node.position, from: self.worldNode)
            
            // ADs AREA
            if ( nodeLocation.y < self.screenBottomY + 140) {
                node.removeFromParent()
            }  else {
                nodeCount += 1
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // declare where next
        let nextTierPos:CGFloat = (PlatformsCounter * 220) - (CGFloat(initialUnits) * 220)
        // If player position has reached over next tier, create a new level unit
        if (thePlayer.position.y + 800 > nextTierPos) {
            createPlatform()
        }
        
        // todo, might be slow to do this every frame
        clearNodes()
        
        if (touched)
        {
            if (jumpPressure < MaxJumpPressure)
            {  //如果当前蓄力值小于最大值
                jumpPressure += 1.8; //则每帧递增当前蓄力值
            }
            else
            {  //达到最大值时，当前蓄力值就等于最大蓄力值
                jumpPressure = MaxJumpPressure;
            }
        }
        thePlayerPosition = thePlayer.position
        if (!thePlayer.isDead) {self.jumpingAndFalling()}
        if(PlatformsCounter > 8 || thePlayer.position.x != playerStartingPos.x) {
            MoveWorldNode()
            if worldNode.position.y == -1
            {
                createLoopingBG()
                createLoopingCastle()
            }
        }
        if runOnce == true {FeverAndFail()}
    }

    // No longer followed by player
//    func centerOnNode(_ node:SKNode) {
//        // convert to this camera
//        let cameraPositionInScene:CGPoint = self.convert(node.position, from: worldNode)
//        worldNode.position = CGPoint(x: 0 , y: worldNode.position.y - cameraPositionInScene.y - screenHeight/2 + 100 )
//    }
    
    func MoveWorldNode()
    {
        worldNode.position.y -= 0.5
    }
    
    func MoveWorldNodeForPlayer()
    {
        feverTime()
        let moveNodeUp = SKAction.moveBy(x: 0.0,
                                         y: -850.0,
                                         duration: 1)
        worldNode.run(moveNodeUp)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1){self.runOnce = true}

    }
    
    private func jumpingAndFalling()
    {
        if let body = thePlayer.physicsBody
        {
            // stop update when dy == 0
            let dy = body.velocity.dy
            let dx = body.velocity.dx
            if dy > 0 && statusChanged != 1
            {
                // Prevent collisions if the hero is jumping
                thePlayer.startJump()
                body.collisionBitMask &= ~BodyType.platform.rawValue
                body.collisionBitMask &= ~BodyType.platformUsed.rawValue
                statusChanged = 1
            }
            else if dy < 0 && statusChanged != 2
            {
                // Allow collisions if the hero is falling
                thePlayer.startFall()
                body.collisionBitMask |= BodyType.platform.rawValue
                body.collisionBitMask |= BodyType.platformUsed.rawValue
                statusChanged = 2
            }
            else if dy == 0 && dx == 0 && statusChanged != 3
            {
                thePlayer.startIdle()
                if currentPlatform?.physicsBody?.categoryBitMask == BodyType.platform.rawValue
                {
                    score = score + 1 + bonus
                    jumpedPlatform += 1
                    currentPlatform?.physicsBody?.categoryBitMask = BodyType.platformUsed.rawValue
                }
                statusChanged = 3

            }
            else if dy == 0 && dx != 0 && statusChanged != 4
            {
                thePlayer.startRun()
                if currentPlatform?.physicsBody?.categoryBitMask == BodyType.platform.rawValue
                {
                    score = score + 1 + bonus
                    jumpedPlatform += 1
                    currentPlatform?.physicsBody?.categoryBitMask = BodyType.platformUsed.rawValue
                }
                statusChanged = 4
            }
        }
    }
    
    private func FeverAndFail()
    {
        // world: y:-1200.49987792969
        // player:y:1693.88122558594
        let playerInScreenLocation:CGPoint = self.convert(thePlayer.position, from: self.worldNode)
        if (playerInScreenLocation.y) > screenTopY - 200
        {
            MoveWorldNodeForPlayer()
            runOnce = false
        }
        if (playerInScreenLocation.y) < screenBottomY
        {
            thePlayer.isDead = true
            restartGame()
            runOnce = false
        }
    }
    
    private func feverTime()
    {
        bonus = 1
        statusSprite.run(feverAction!, withKey: "fever")
        timerLabel.isHidden = false
        startFeverTimer()
    }
    
    private func endFeverTime()
    {
        bonus = 0
        feverTimeDuration = 10
        timerLabel.isHidden = true
        statusSprite.removeAction(forKey: "fever")
    }
    
    // Time Functions
    func startFeverTimer() {
        countdownTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateFeverTime), userInfo: nil, repeats: true)
    }
    
    @objc func updateFeverTime() {
        if feverTimeDuration != 0 {
            feverTimeDuration -= 1
        } else {
            endTimer()
        }
    }
    func endTimer() {
        countdownTimer.invalidate()
        endFeverTime()
    }
    
    func restartGame(){
        let gameScene:GameplayScene = GameplayScene(size: self.size)
        gameScene.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        let transition = SKTransition.fade(withDuration: 1.0)
        gameScene.scaleMode = self.scaleMode
        self.view!.presentScene(gameScene, transition: transition)
        
        // TODO: Second life
        score = 0
        jumpedPlatform = 0
    }
    
    // Handle all the collision
    func didBegin(_ contact: SKPhysicsContact) {
        if (contact.bodyA.categoryBitMask == BodyType.player.rawValue &&
            contact.bodyB.categoryBitMask == BodyType.platform.rawValue)
        {
            //if thePlayer.position.y > contact.contactPoint.y + thePlayer.size.height/2
            //{
//                score = score + 1 + bonus
//                jumpedPlatform += 1
//                contact.bodyB.node?.physicsBody?.categoryBitMask = BodyType.platformUsed.rawValue
            //}
            currentPlatform =  contact.bodyB.node! as? SKSpriteNode

            if contact.bodyB.node?.frame.size.width == 150
            {
                DispatchQueue.main.asyncAfter(deadline: .now() + 5)
                {
                        contact.bodyB.node?.run(shakeAction!, completion: {
                            contact.bodyB.node?.physicsBody?.categoryBitMask = BodyType.nothing.rawValue
                            contact.bodyB.node?.physicsBody?.isDynamic = true
                        })
                }
            }
        }
        else if (contact.bodyA.categoryBitMask == BodyType.platform.rawValue &&
            contact.bodyB.categoryBitMask == BodyType.player.rawValue)
        {
            //if thePlayer.position.y > contact.contactPoint.y + thePlayer.size.height/2
            //{
//                score = score + 1 + bonus
//                jumpedPlatform += 1
//                contact.bodyA.node?.physicsBody?.categoryBitMask = BodyType.platformUsed.rawValue
            //}
            currentPlatform =  contact.bodyA.node! as? SKSpriteNode

            if contact.bodyA.node?.frame.size.width == 150
            {
                DispatchQueue.main.asyncAfter(deadline: .now() + 5)
                {
                        contact.bodyA.node?.run(shakeAction!, completion: {
                            contact.bodyA.node?.physicsBody?.categoryBitMask = BodyType.nothing.rawValue
                            contact.bodyA.node?.physicsBody?.isDynamic = true
                    })
                }
            }
        }
        
        if (contact.bodyA.categoryBitMask == BodyType.player.rawValue &&
            contact.bodyB.categoryBitMask == BodyType.enemy.rawValue)
        {
            if (thePlayer.isFalling)
            {
                thePlayer.physicsBody?.velocity = CGVector(dx:0, dy:350)
                contact.bodyB.categoryBitMask = BodyType.nothing.rawValue
                contact.bodyB.isDynamic = false
                contact.bodyB.node?.removeAllActions()
                contact.bodyB.node?.run(enemyDiedAction!)
                {
                    contact.bodyB.node?.removeFromParent()
                }
                score = score + 2 + bonus
            }
            else
            {
                if(!thePlayer.isDead){
                    thePlayer.isDead = true
                    thePlayer.removeAllChildren()
                    thePlayer.physicsBody?.isDynamic = false
                    thePlayer.run(diedAction!)
                    {
                        self.restartGame()
                    }
                    self.worldNode.run(shakeAction!)
                }
            }
        }
        else if (contact.bodyA.categoryBitMask == BodyType.enemy.rawValue &&
            contact.bodyB.categoryBitMask == BodyType.player.rawValue)
        {
            if (thePlayer.isFalling)
            {
                thePlayer.physicsBody?.velocity = CGVector(dx:0, dy:350)
                contact.bodyA.categoryBitMask = BodyType.nothing.rawValue
                contact.bodyA.isDynamic = false
                contact.bodyA.node?.removeAllActions()
                contact.bodyA.node?.run(enemyDiedAction!)
                {
                    contact.bodyA.node?.removeFromParent()
                }
                score = score + 2 + bonus
            }
            else
            {
                if(!thePlayer.isDead){
                    thePlayer.isDead = true
                    thePlayer.removeAllChildren()
                    thePlayer.physicsBody?.isDynamic = false
                    thePlayer.run(diedAction!)
                    {
                        self.restartGame()
                    }
                    self.worldNode.run(shakeAction!)
                }
            }
        }
    }
}

