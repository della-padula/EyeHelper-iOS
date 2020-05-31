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

public var generator = UIImpactFeedbackGenerator(style: .medium)

public class MorsePlayer {
    
    public static let shared = MorsePlayer()
    
    private let breakDuration = 0.3
    
    private init() { }
    
    public func vibrate(morseText: String) {
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
            self.vibrateAction(dict: dict)
        }
    }
    
    public func vibrateAction(dict: [(Bool, Bool)]) {
        var isVibrate = false
        var isLong = false
        
        for item in dict {
            isVibrate = item.0
            isLong = item.1
            
            sleep(1)
            // 1 second * breakDuration
            // usleep(UInt32(1000000 * breakDuration))
            
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            
            if isVibrate {
                if isLong {
                    print("Long Vibrate!!!")
//                    generator.impactOccurred()
//                    let generator = UINotificationFeedbackGenerator()
//                    generator.notificationOccurred(.success)

//                    usleep(UInt32(1000000 * 0.1))
//                    generator.impactOccurred()
//                    AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
//
//                    let second: Double = 1000000
//                    usleep(useconds_t(0.5 * second))
//
//                    AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
                } else {
                    print("Vibrate!!!")
//                    generator.impactOccurred()
//                    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
                    
//                    let generator = UINotificationFeedbackGenerator()
//                    generator.notificationOccurred(.error)
                }
            }
        }
    }
}
