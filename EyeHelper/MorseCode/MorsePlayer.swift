//
//  MorsePlayer.swift
//  EyeHelper
//
//  Created by 김태인 on 2020/05/31.
//  Copyright © 2020 TaeinKim. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

public class MorsePlayer {
    
    class func vibrate(morseText: String) {
        
        var encodedText = ""
        
        for character in morseText {
            encodedText += characterToMorse[String(character)] ?? ""
        }
        
        print("encoded Text : \(encodedText)")
        
        DispatchQueue.main.async {
            var isLong: Bool = false
            for (index, morse) in encodedText.enumerated() {
                
                if morse == Character("-") {
                    isLong = true
                } else if morse == Character(".") {
                    isLong = false
                }
                
//                AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
                
                if isLong {
                    vibrateAction(.heavy)
                } else {
                    vibrateAction(.light)
                }
                sleep(1)
                
                //            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(Double(index) * duration * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
                //                AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
                //                self.processVibration(isLong: isLong)
                //            })
            }
        }
    }
    
    private class func vibrateAction(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .heavy) {
        let impactFeedbackgenerator = UIImpactFeedbackGenerator(style: style)
        impactFeedbackgenerator.prepare()
        impactFeedbackgenerator.impactOccurred()
    }
}
