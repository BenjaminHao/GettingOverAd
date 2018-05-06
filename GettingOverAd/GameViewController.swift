//
//  GameViewController.swift
//  GettingOverAd
//
//  Created by Benjamin Hao on 2018-02-02.
//  Copyright © 2018 Benjamin Hao. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import AVFoundation
import GoogleMobileAds

let stopBackgroundMusicNotificationName = Notification.Name("stopBackgroundMusicNotificationName")
let startBackgroundMusicNotificationName = Notification.Name("startBackgroundMusicNotificationName")
let startGameplayNotificationName = Notification.Name("startGameplayNotificationName")
let setMusicVolumeNotificationName = Notification.Name("setMusicVolumeNotificationName")

class GameViewController: UIViewController {
    
    let skView: SKView = {
        let view = SKView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var backgroundMusic: AVAudioPlayer? = {
        guard let url = Bundle.main.url(forResource: kBackgroundMusicName, withExtension: kBackgroundMusicExtension) else {
            return nil
        }
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.numberOfLoops = -1
            return player
        } catch {
            return nil
        }
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addNotificationObservers()
    
        view.addSubview(skView)

        skView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        skView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
            if #available(iOS 11.0, *) {
                if PlayerStats.shared.getNoAds() == false
                {
                    skView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
                } else {
                    skView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
                }
            } else {
                skView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            }
        skView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true

        let scene = MainMenu(size: CGSize(width: ScreenSize.width, height: ScreenSize.height))
        scene.scaleMode = .aspectFill
        skView.presentScene(scene)
        skView.ignoresSiblingOrder = true

        playStopBackgroundMusic()
        let info = ["volume": PlayerStats.shared.getMusicVolume()]
        NotificationCenter.default.post(name: setMusicVolumeNotificationName, object: nil, userInfo: info)

//        if let view = self.view as! SKView? {
//            // Load the SKScene from 'GameScene.sks'
//            if let scene = GameplayScene(fileNamed: "GameplayScene") {
//                // Set the scale mode to scale to fit the window
//                scene.scaleMode = .aspectFill
//                // Present the scene
//                view.presentScene(scene)
//            }
//
//            view.ignoresSiblingOrder = true
//
////            view.showsFPS = true
////            view.showsNodeCount = true
////             Show physics
////            view.showsPhysics = true
//        }
        SwiftyAd.shared.showBanner(from: self, at: .bottom) // Shows banner at the top
    }


    func addNotificationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.stopBackgroundMusic(_:)), name: stopBackgroundMusicNotificationName, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.startBackgroundMusic(_:)), name: startBackgroundMusicNotificationName, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.setMusicVolume(_:)), name: setMusicVolumeNotificationName, object: nil)
    }

    func playStopBackgroundMusic() {
        if PlayerStats.shared.getSound() {
            backgroundMusic?.play()
        } else {
            backgroundMusic?.stop()
        }
    }
    
    @objc func stopBackgroundMusic(_ info:Notification) {
        if PlayerStats.shared.getSound() {
            backgroundMusic?.stop()
        }
    }
    
    @objc func startBackgroundMusic(_ info:Notification) {
        if PlayerStats.shared.getSound() {
            backgroundMusic?.play()
        }
    }
    
    @objc func setMusicVolume(_ info:Notification) {
        guard let userInfo = info.userInfo else {return}
        let volume = userInfo["volume"] as! Float
        setBackgroundMusicVolume(to: volume)
    }
    
    func setBackgroundMusicVolume(to volume: Float) {
        backgroundMusic?.volume = volume
    }
    
    override var shouldAutorotate: Bool {
        return false
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

}
