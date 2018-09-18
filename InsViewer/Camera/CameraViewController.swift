//
//  CameraViewController.swift
//  InsViewer
//
//  Created by Renrui Liu on 16/9/18.
//  Copyright © 2018 Renrui Liu. All rights reserved.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController, AVCapturePhotoCaptureDelegate, UIViewControllerTransitioningDelegate {
    
    let dismissBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(#imageLiteral(resourceName: "right_arrow_shadow").withRenderingMode(.alwaysOriginal), for: .normal)
        btn.addTarget(self, action: #selector(handleDismiss), for: .touchUpInside)
        return btn
    }()
    
    let capturePhotoBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(#imageLiteral(resourceName: "capture_photo").withRenderingMode(.alwaysOriginal), for: .normal)
        btn.addTarget(self, action: #selector(handleCapturePhoto), for: .touchUpInside)
        return btn
    }()
    
    @objc func handleDismiss(){
        dismiss(animated: true, completion: nil)
    }
    @objc func handleCapturePhoto(){
        let settings = AVCapturePhotoSettings()
        guard let previewFormatType = settings.availablePreviewPhotoPixelFormatTypes.first else {return}
        settings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: previewFormatType]
        output.capturePhoto(with: settings, delegate: self)
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?, previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {

        let imageData = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: photoSampleBuffer!, previewPhotoSampleBuffer: previewPhotoSampleBuffer!)
        let previewImage = UIImage(data: imageData!)
        
        // set to view
        let container = PreviewPhotoContainer()
        container.previewImageView.image = previewImage
        view.addSubview(container)
        container.anchor(top: view.topAnchor, paddingTop: 0, bottom: view.bottomAnchor, paddingBottom: 0, left: view.leftAnchor, paddingLeft: 0, right: view.rightAnchor, paddingRight: 0, width: 0, height: 0)
    }
    
    //____________________________________________________________________________________
    let output = AVCapturePhotoOutput()

    fileprivate func setupCameraSession(){
        let captureSession = AVCaptureSession()
        
        // 1. setup inputs
        guard let captureDevice = AVCaptureDevice.default(for: AVMediaType.video) else {return}
        do{
            let input = try AVCaptureDeviceInput(device: captureDevice)
            if captureSession.canAddInput(input){
                captureSession.addInput(input)
            }
        }catch let err {
            print("Could not setup camera input:",err)
        }
        
        // 2. setup outputs
        if captureSession.canAddOutput(output){
            captureSession.addOutput(output)
        }
        
        // 3. setup output preview
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        view.layer.addSublayer(previewLayer)
        previewLayer.frame = view.frame
        
        captureSession.startRunning()
    }
    
    fileprivate func setupHUD(){
        view.addSubview(capturePhotoBtn)
        view.addSubview(dismissBtn)
        capturePhotoBtn.anchor(top: nil, paddingTop: 0, bottom: view.bottomAnchor, paddingBottom: 24, left: nil, paddingLeft: 0, right: nil, paddingRight: 0, width: 80, height: 80)
        capturePhotoBtn.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        dismissBtn.anchor(top: view.topAnchor, paddingTop: 12, bottom: nil, paddingBottom: 0, left: nil, paddingLeft: 0, right: view.rightAnchor, paddingRight: 12, width: 50, height: 50)
    }
    
    //____________________________________________________________________________________

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setting the transition style for it to or from any other view controllers
        transitioningDelegate = self
        
        setupCameraSession()
        setupHUD()
    }
    
    override var prefersStatusBarHidden: Bool {return true}
    
    //____________________________________________________________________________________
    // animate present camera animation
    let customAnimationPresentor = CustomAnimationPresentor()
    let customAnimationDismisser = CustomAnimationDismisser()
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        return customAnimationPresentor
    }
    // dismiss animation
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return customAnimationDismisser
    }
    
    
}
