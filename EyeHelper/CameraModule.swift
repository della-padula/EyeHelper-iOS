//
//  CameraModule.swift
//  EyeHelper
//
//  Created by 김태인 on 2020/05/31.
//  Copyright © 2020 TaeinKim. All rights reserved.
//

import AVFoundation
import UIKit

// MARK: - CameraModule
extension ViewController {
    func captureDevice(forPosition position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        let discoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInWideAngleCamera],
            mediaType: .video,
            position: .unspecified
        )
        return discoverySession.devices.first { $0.position == position }
    }
    
    func initCaptureSessionOutput() {
        self.sessionQueue.async {
            self.captureSession.beginConfiguration()
            self.captureSession.sessionPreset = .high
            
            let output = AVCaptureVideoDataOutput()
            output.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as String): kCVPixelFormatType_32BGRA]
            output.alwaysDiscardsLateVideoFrames = true
            output.setSampleBufferDelegate(self, queue: self.outputQueue)
            
            guard self.captureSession.canAddOutput(output) else {
                print("Failed to add capture session output.")
                return
            }
            
            self.captureSession.addOutput(output)
            self.captureSession.commitConfiguration()
        }
    }
    
    func initCaptureSessionInput() {
        self.sessionQueue.async {
            let cameraPosition: AVCaptureDevice.Position = self.isFrontCamera ? .front : .back
            guard let device = self.captureDevice(forPosition: cameraPosition) else {
                print("Failed to get capture device for camera position: \(cameraPosition)")
                return
            }
            
            do {
                self.captureSession.beginConfiguration()
                let currentInputs = self.captureSession.inputs
                for input in currentInputs {
                    self.captureSession.removeInput(input)
                }
                
                let input = try AVCaptureDeviceInput(device: device)
                guard self.captureSession.canAddInput(input) else {
                    print("Failed to add capture session input.")
                    return
                }
                
                self.captureSession.addInput(input)
                self.captureSession.commitConfiguration()
                
                self.initCaptureSessionPreview()
            } catch {
                print("Failed to create capture device input: \(error.localizedDescription)")
            }
        }
    }
    
    func initCaptureSessionPreview() {
        DispatchQueue.main.async {
            self.previewLayer.videoGravity = .resizeAspect
            self.previewLayer.frame = CGRect(x: 0, y: 0, width: self.cameraView.layer.bounds.width, height: self.cameraView.layer.bounds.height)
            self.cameraView.layer.addSublayer(self.previewLayer)
        }
    }
}

// MARK: Camera Session
extension ViewController {
    func startSession() {
        self.sessionQueue.async {
            self.captureSession.startRunning()
            
            switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: .video, completionHandler: { granted in
                    if !granted {
                        print("Camera access not granted")
                    } else {
                        print("Camera access granted")
                    }
                })
            case .authorized:
                print("Camera access granted")
            default:
                print("Camera access denied")
            }
            
            self.setRotation()
        }
    }
    
    func stopSession() {
        self.sessionQueue.async {
            self.captureSession.stopRunning()
        }
    }
}

// MARK: - Orientation
extension ViewController {
    func setRotation() {
        guard let connection = previewLayer.connection else {
            return
        }
        DispatchQueue.main.async {
            let orientation = UIApplication.shared.statusBarOrientation
            
            switch orientation {
            case .landscapeLeft:
                connection.videoOrientation = .landscapeLeft
                self.imageOrientation = self.isFrontCamera ? .up : .down
                break
            case .landscapeRight:
                connection.videoOrientation = .landscapeRight
                self.imageOrientation = self.isFrontCamera ? .down : .up
                break
            case .portraitUpsideDown:
                connection.videoOrientation = .portraitUpsideDown
                self.imageOrientation = .left
                break
            default:
                connection.videoOrientation = .portrait
                self.imageOrientation = .right
                break
            }
            
            self.previewLayer.frame = CGRect(x: 0, y: 0, width: self.cameraView.layer.bounds.width, height: self.cameraView.layer.bounds.height)
        }
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
extension ViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            print("Failed to get image buffer from sample buffer.")
            return
        }
        displayImage(imageBuffer)
    }
}

// MARK: - Display Image
extension ViewController {
    func displayImage(_ imageBuffer: CVImageBuffer) {
        guard let orientation = self.imageOrientation else {
            return
        }
        
        let ciImage = CIImage(cvPixelBuffer: imageBuffer)
        
        viewControllerCiImage = ciImage
        
        let context = CIContext(options: nil)
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else {
            return
        }
        
        let imageResult = UIImage(cgImage: cgImage, scale: 1.0, orientation: orientation)
        
        viewControllerUIImage = imageResult
        
        DispatchQueue.main.async {
            if imageResult.size.width > imageResult.size.height {
                self.constraintImageHeight.constant = 128
                self.constraintImageWidth.constant = imageResult.size.width / imageResult.size.height * 128
            }
            
            if imageResult.size.height > imageResult.size.width {
                self.constraintImageWidth.constant = 128
                self.constraintImageHeight.constant = imageResult.size.height / imageResult.size.width * 128

            }
            
//            self.viewResult.image = imageResult
        }
    }
}
