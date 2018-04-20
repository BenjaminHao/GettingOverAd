//
//  GameManager.swift
//  GettingOverAd
//
//  Created by Benjamin Hao on 2018-04-11.
//  Copyright © 2018 Benjamin Hao. All rights reserved.
//

import Foundation
import SpriteKit

class GameManager {
    
    enum SceneType {
        case MainMenu, Gameplay, Settings
    }
    
    private init() {}
    static let shared = GameManager()
    
    public func launch() {
        firstLaunch()
    }
    
    private func firstLaunch() {
        if !UserDefaults.standard.bool(forKey: "isFirstLaunch") {
            
            PlayerStats.shared.setSounds(true)
            PlayerStats.shared.saveMusicVolume(0.7)
            
            UserDefaults.standard.set(true, forKey: "isFirstLaunch")
            UserDefaults.standard.synchronize()
        }
    }
    
    func transition(_ fromScene: SKScene, toScene: SceneType, transition: SKTransition? = nil ) {
        guard let scene = getScene(toScene) else { return }
        
        if let transition = transition {
            scene.scaleMode = .aspectFit
            fromScene.view?.presentScene(scene, transition: transition)
        } else {
            scene.scaleMode = .aspectFit
            fromScene.view?.presentScene(scene)
        }
        
    }
    
    func getScene(_ sceneType: SceneType) -> SKScene? {
        switch sceneType {
        case SceneType.MainMenu:
            return MainMenu(size: CGSize(width: ScreenSize.width, height: ScreenSize.height))
        case SceneType.Gameplay:
            if DeviceType.isiPhoneX {
                return GameplayScene(size: CGSize(width: 750, height: 1668))
            } else {
                return GameplayScene(size: CGSize(width: 750, height: 1334))
            }
        case SceneType.Settings:
            return Settings(size: CGSize(width: ScreenSize.width, height: ScreenSize.height))
        }
    }
    
    func run(_ fileName: String, onNode: SKNode) {
        if PlayerStats.shared.getSound() {
            onNode.run(SKAction.playSoundFileNamed(fileName, waitForCompletion: false))
        }
    }
    
    func showAlert(on scene: SKScene, title: String, message: String, preferredStyle: UIAlertControllerStyle = .alert, actions: [UIAlertAction], animated: Bool = true, delay: Double = 0.0, completion: (() -> Swift.Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
        
        for action in actions {
            alert.addAction(action)
        }
        
        let wait = DispatchTime.now() + delay
        DispatchQueue.main.asyncAfter(deadline: wait) {
            scene.view?.window?.rootViewController?.present(alert, animated: animated, completion: completion)
        }
        
    }
    
    func share(on scene: SKScene, text: String, image: UIImage?, exculdeActivityTypes: [UIActivityType] ) {
        // text to share
        //let text = "This is some text that I want to share."
        guard let image = image else {return}
        // set up activity view controller
        let shareItems = [ text, image ] as [Any]
        let activityViewController = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = scene.view // so that iPads won't crash
        
        // exclude some activity types from the list (optional)
        activityViewController.excludedActivityTypes = exculdeActivityTypes
        
        // present the view controller
        scene.view?.window?.rootViewController?.present(activityViewController, animated: true, completion: nil)
    }
    
}
