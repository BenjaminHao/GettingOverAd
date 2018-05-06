//
//  AntiBodyTimer.swift
//  GettingOverAd
//
//  Created by Benjamin Hao on 2018-05-02.
//  Copyright © 2018 Benjamin Hao. All rights reserved.
//

import Foundation
import SpriteKit

class AntiBodyTimer: NSObject {
    
    static let shared = AntiBodyTimer()
    var counter = 0
    var counterTimer: Timer?
    var counterStartValue = 600
    var minutesText: String! = "00"
    var secondsText: String! = "00"

    func startTimer(){
        counter = counterStartValue
        self.counterTimer = Timer.scheduledTimer(timeInterval: 1.0 /*seconds*/, target: self, selector: #selector(decrementCounter), userInfo: nil, repeats: true)
        SwiftyAd.shared.isRemoved = true

    }
    
    func stopTimer(){
        self.counterTimer?.invalidate()

    }
    
    @objc func decrementCounter() {
        if counter <= 1 {
            stopTimer()
            SwiftyAd.shared.isRemoved = false
        }
        
        counter -= 1
        
        let minutes = counter / 60
        let seconds = counter % 60
        minutesText = minutes < 10 ? "0\(minutes)" : "\(minutes)"
        secondsText = seconds < 10 ? "0\(seconds)" : "\(seconds)"        
    }
}
