//
//  PlayerStats.swift
//  GettingOverAd
//
//  Created by Benjamin Hao on 2018-04-10.
//  Copyright © 2018 Benjamin Hao. All rights reserved.
//

import Foundation
import SpriteKit

let kBackgroundMusicName = "BackgroundMusic"
let kBackgroundMusicExtension = "mp3"
let kSoundState = "kSoundState"
let kNoBannerAds = "kNoBannerAds"
let kNoEndGameAds = "kNoEndGameAds"
let kScore = "kScore"
let kBestScore = "kBestScore"
let kPlatformScore = "kPlatformScore"
let kBestPlatformScore = "kBestPlatformScore"
let kMusicVolume = "kMusicVolume"

enum SoundFileName: String {
    case TapFile = "Tap.mp3"
}

class PlayerStats {
    
    private init() {}
    static let shared = PlayerStats()
    
    func setScore(_ value: Int) {
        if value > getBestScore() {
            setBestScore(value)
        }
        UserDefaults.standard.set(value, forKey: kScore)
        UserDefaults.standard.synchronize()
    }
    
    func getScore() -> Int {
        return  UserDefaults.standard.integer(forKey: kScore)
    }
    
    func setBestScore(_ value: Int) {
        UserDefaults.standard.set(value, forKey: kBestScore)
        UserDefaults.standard.synchronize()
    }
    
    func getBestScore() -> Int {
        return  UserDefaults.standard.integer(forKey: kBestScore)
    }
    
    func setPlatformScore(_ value: Int) {
        if value > getBestPlatformScore() {
            setBestPlatformScore(value)
        }
        UserDefaults.standard.set(value, forKey: kPlatformScore)
        UserDefaults.standard.synchronize()
    }
    
    func getPlatformScore() -> Int {
        return  UserDefaults.standard.integer(forKey: kPlatformScore)
    }
    
    func setBestPlatformScore(_ value: Int) {
        UserDefaults.standard.set(value, forKey: kBestPlatformScore)
        UserDefaults.standard.synchronize()
    }
    
    func getBestPlatformScore() -> Int {
        return  UserDefaults.standard.integer(forKey: kBestPlatformScore)
    }
    
    func setSounds(_ state: Bool) {
        UserDefaults.standard.set(state, forKey: kSoundState)
        UserDefaults.standard.synchronize()
    }
    
    func getSound() -> Bool {
        return UserDefaults.standard.bool(forKey: kSoundState)
    }
    
    func saveMusicVolume(_ value: Float) {
        UserDefaults.standard.set(value, forKey: kMusicVolume)
        UserDefaults.standard.synchronize()
    }
    
    func getMusicVolume() -> Float {
        return UserDefaults.standard.float(forKey: kMusicVolume)
    }
    
    func setNoBannerAds(_ state: Bool) {
        UserDefaults.standard.set(state, forKey: kNoBannerAds)
        UserDefaults.standard.synchronize()
    }
    
    func getNoBannerAds() -> Bool {
        return UserDefaults.standard.bool(forKey: kNoBannerAds)
    }
    
    func setNoEndGameAds(_ state: Bool) {
        UserDefaults.standard.set(state, forKey: kNoEndGameAds)
        UserDefaults.standard.synchronize()
    }
    
    func getNoEndGameAds() -> Bool {
        return UserDefaults.standard.bool(forKey: kNoEndGameAds)
    }
}
