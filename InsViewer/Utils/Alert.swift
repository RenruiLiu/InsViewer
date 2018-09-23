//
//  Alert.swift
//  InsViewer
//
//  Created by Renrui Liu on 23/9/18.
//  Copyright © 2018 Renrui Liu. All rights reserved.
//

import Foundation
import UIKit

func showAlert(title: String, text: String, button: String = "Cancel") -> UIAlertController{
    let alert = UIAlertController(title: title, message: text, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: button, style: .cancel, handler: nil))
    return alert
}
