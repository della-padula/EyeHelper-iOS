//
//  MorsePlayer.swift
//  EyeHelper
//
//  Created by 김태인 on 2020/05/31.
//  Copyright © 2020 TaeinKim. All rights reserved.
//

import Foundation
import UIKit
import AudioToolbox
import AVFoundation

public class MorsePlayer {
    
    private static let shortDuration = 0.1
    private static let longDuration = 0.3
    private static let breakDuration = 0.6
    
    class func vibrate(morseText: String) {
        // isVibrate : isLong
        var dict: [(Bool, Bool)] = [(Bool, Bool)]()
        
        var encodedText = ""
        
        for character in morseText {
            encodedText += characterToMorse[String(character)] ?? ""
        }
        
        print("encoded Text : \(encodedText)")
        
        
        var isLong: Bool = false
        for (index, morse) in encodedText.enumerated() {
            
            if morse == Character("-") {
                isLong = true
                dict.append((true, true))
            } else if morse == Character(".") {
                isLong = false
                dict.append((true, false))
            } else {
                dict.append((false, false))
            }
        }
        
        DispatchQueue.main.async {
            AudioServicesPlaySystemSound(4095)
        }
    }
    
    private class func vibrateAction(dict: [(Bool, Bool)]) {
        var isVibrate = false
        var isLong = false
        var totalTime = 0.0
        
        var vibrateDuration = 0.0
        
        for item in dict {
            isVibrate = item.0
            isLong = item.1
            vibrateDuration = isLong ? longDuration : shortDuration
            
            totalTime += breakDuration
            totalTime += vibrateDuration
            
            DispatchQueue.main.asyncAfter(deadline: .now() + totalTime, execute: {
                
            })
        }
    }
}
