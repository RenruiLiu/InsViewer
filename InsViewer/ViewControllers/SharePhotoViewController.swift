//
//  SharePhotoViewController.swift
//  InsViewer
//
//  Created by Renrui Liu on 13/9/18.
//  Copyright © 2018 Renrui Liu. All rights reserved.
//

import UIKit

class SharePhotoViewController: UIViewController {
    
    var selectedImg: UIImage?{
        didSet{
            self.imgView.image = selectedImg
        }
    }
    
    let imgView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.backgroundColor = .red
        iv.clipsToBounds = true
        return iv
    }()
    let textView: UITextView = {
        let tv = UITextView()
        tv.font = UIFont.systemFont(ofSize: 14)
        return tv
    }()
    
    fileprivate func setupImageAndTextViews(){
        let containerView = UIView()
        containerView.backgroundColor = .white
        //
        view.addSubview(containerView)
        containerView.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 0, bottom: nil, paddingBottom: 0, left: view.leftAnchor, paddingLeft: 0, right: view.rightAnchor, paddingRight: 0, width: 0, height: 100)
        //
        containerView.addSubview(imgView)
        imgView.anchor(top: containerView.topAnchor, paddingTop: 8, bottom: containerView.bottomAnchor, paddingBottom: 8, left: containerView.leftAnchor, paddingLeft: 8, right: nil, paddingRight: 0, width: 84, height: 0)
        //
        containerView.addSubview(textView)
        textView.anchor(top: containerView.topAnchor, paddingTop: 0, bottom: containerView.bottomAnchor, paddingBottom: 0, left: imgView.rightAnchor, paddingLeft: 4, right: containerView.rightAnchor, paddingRight: 0, width: 0, height: 0)
    }
    
    //____________________________________________________________________________________
    @objc func handleShare(){
        print("share")
    }

    //____________________________________________________________________________________
    override var prefersStatusBarHidden: Bool {return true}
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.rgb(red: 240, green: 240, blue: 240)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Share", style: .plain, target: self, action: #selector(handleShare))
        setupImageAndTextViews()
    }

}
