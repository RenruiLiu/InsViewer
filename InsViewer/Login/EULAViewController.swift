//
//  EULAViewController.swift
//  InsViewer
//
//  Created by Renrui Liu on 27/9/18.
//  Copyright © 2018 Renrui Liu. All rights reserved.
//

import UIKit

class EULAViewController: UIViewController {

    let textView: UITextView = {
        let text = UITextView()
        text.isScrollEnabled = true
        text.isEditable = false
        text.isSelectable = false
        return text
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(handleCancel))
        
        view.addSubview(textView)
        textView.anchor(top: view.topAnchor, paddingTop: 16, bottom: view.bottomAnchor, paddingBottom: 16, left: view.leftAnchor, paddingLeft: 8, right: view.rightAnchor, paddingRight: 8, width: 0, height: 0)
        
        // read file
        if let dir = Bundle.main.path(forResource: "EULA", ofType: "txt") {
            do {
                let plainTxt = try String(contentsOfFile: dir, encoding: .utf8)
                textView.text = plainTxt
            } catch {
                print("some err")
            }
        }
    }
    
    
    @objc func handleCancel(){
        dismiss(animated: true, completion: nil)
    }
}
