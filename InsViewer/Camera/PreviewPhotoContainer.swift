//
//  PreviewPhotoContainer.swift
//  InsViewer
//
//  Created by Renrui Liu on 16/9/18.
//  Copyright © 2018 Renrui Liu. All rights reserved.
//

import UIKit
import Photos

class PreviewPhotoContainer: UIView {
    
    let cancelBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(#imageLiteral(resourceName: "cancel_shadow").withRenderingMode(.alwaysOriginal), for: .normal)
        btn.addTarget(self, action: #selector(handleCancel), for: .touchUpInside)
        return btn
    }()
    
    @objc func handleCancel(){
        self.removeFromSuperview()
    }
    
    let saveBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(#imageLiteral(resourceName: "save_shadow").withRenderingMode(.alwaysOriginal), for: .normal)
        btn.addTarget(self, action: #selector(handleSave), for: .touchUpInside)
        return btn
    }()
    
    @objc func handleSave(){
        guard let previewImage = previewImageView.image else {return}
        let library = PHPhotoLibrary.shared()
        library.performChanges({
            PHAssetChangeRequest.creationRequestForAsset(from: previewImage)
        }) { (success, err) in
            if let _ = err {
                showErr(info: "Failed to save image to photo library", subInfo: tryLater)
                return
            }
            
            print("Successfully saved image to library")
            // saving the photo in backgound thread, now get back to main thread
            // to show the success info
            DispatchQueue.main.async {
                self.showSuccessInfo_dismiss()
            }
        }
    }
    
    fileprivate func showSuccessInfo_dismiss(){
        let savedLabel = UILabel()
        savedLabel.text = "Saved Successfully"
        savedLabel.font = UIFont.boldSystemFont(ofSize: 18)
        savedLabel.textAlignment = .center
        savedLabel.textColor = .white
        savedLabel.numberOfLines = 0
        savedLabel.backgroundColor = UIColor(white: 0, alpha: 0.3)
        self.addSubview(savedLabel)
        savedLabel.frame = CGRect(x: 0, y: 0, width: 150, height: 80)
        savedLabel.center = self.center
        // perform animation:
        savedLabel.layer.transform = CATransform3DMakeScale(0, 0, 0)
        // pop up
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
            savedLabel.layer.transform = CATransform3DMakeScale(1, 1, 1)
        }) { (completed) in
            // fade out
            UIView.animate(withDuration: 0.5, delay: 0.75, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
                savedLabel.layer.transform = CATransform3DMakeScale(0.1, 0.1, 0.1)
            }, completion: { (_) in
                savedLabel.removeFromSuperview()
        
                // dismiss the parent controller (camera)
                let vc = self.parentController(of: CameraViewController.self)
                vc?.dismiss(animated: true, completion: nil)
            })
        }
        
    }
    
    let previewImageView: UIImageView = {
        let iv = UIImageView()
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        setupHUD()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setupHUD(){
        addSubview(previewImageView)
        addSubview(cancelBtn)
        addSubview(saveBtn)
        previewImageView.anchor(top: topAnchor, paddingTop: 0, bottom: bottomAnchor, paddingBottom: 0, left: leftAnchor, paddingLeft: 0, right: rightAnchor, paddingRight: 0, width: 0, height: 0)
        cancelBtn.anchor(top: topAnchor, paddingTop: 12, bottom: nil, paddingBottom: 0, left: leftAnchor, paddingLeft: 12, right: nil, paddingRight: 0, width: 50, height: 50)
        saveBtn.anchor(top: nil, paddingTop: 0, bottom: bottomAnchor, paddingBottom: 24, left: leftAnchor, paddingLeft: 24, right: nil, paddingRight: 0, width: 50, height: 50)
    }
}
