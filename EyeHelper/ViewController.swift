//
//  ViewController.swift
//  EyeHelper
//
//  Created by 김태인 on 2020/05/29.
//  Copyright © 2020 TaeinKim. All rights reserved.
//

import UIKit
import Firebase
import AVFoundation

class ViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var constraintImageHeight: NSLayoutConstraint!
    @IBOutlet weak var constraintImageWidth: NSLayoutConstraint!
    
    var mTimer : Timer?
    var textRecognizer: VisionTextRecognizer?
    
    // MARK: Camera
    var isFrontCamera = false
    lazy var captureSession = AVCaptureSession()
    lazy var previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
    lazy var sessionQueue = DispatchQueue(label: "SessionQueue")
    lazy var outputQueue = DispatchQueue(label: "OutputQueue")

    var cvImageBuffer: CVImageBuffer?
    var viewControllerCiImage: CIImage?
    var viewControllerUIImage: UIImage?
    
    var imageOrientation: UIImage.Orientation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let vision = Vision.vision()
        textRecognizer = vision.onDeviceTextRecognizer()
        
        initCaptureSessionOutput()
        initCaptureSessionInput()
        
        let rotate: (Notification) -> Void = { _ in self.setRotation() }
        NotificationCenter.default.addObserver(forName: UIDevice.orientationDidChangeNotification, object: nil, queue: .main, using: rotate)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.stopTimer()
        stopSession()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.startTimer()
        startSession()
    }
    
    private func startTimer() {
        if let timer = mTimer {
            //timer 객체가 nil 이 아닌경우에는 invalid 상태에만 시작한다
            if !timer.isValid {
                /** 1초마다 timerCallback함수를 호출하는 타이머 */
                mTimer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(timerCallback), userInfo: nil, repeats: true)
            }
        } else {
            mTimer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(timerCallback), userInfo: nil, repeats: true)
        }
    }
    
    private func stopTimer() {
        if let timer = mTimer {
            timer.invalidate()
            mTimer = nil
        }
    }
    
    @objc
    private func timerCallback() {
        if let image = viewControllerUIImage {
            self.imageView.image = image
            self.requestFirebaseTextDetection(image: image)
        }
    }
    
    private func requestFirebaseTextDetection(image: UIImage) {
        let visionImage = VisionImage(image: image)
        self.textRecognizer?.process(visionImage) { result, error in
            guard error == nil, let result = result else {
                print("error error error")
                return
            }
            
            // Recognized text
            print("🗣 RESULT : \(result)")
        }
    }
    
}
