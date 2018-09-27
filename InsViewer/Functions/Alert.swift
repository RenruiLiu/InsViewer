//
//  Alert.swift
//  InsViewer
//
//  Created by Renrui Liu on 23/9/18.
//  Copyright © 2018 Renrui Liu. All rights reserved.
//

import Foundation
import UIKit
import SCLAlertView


let tryLater = "Please try again later"

func showInfo(info: String, subInfo: String, duration: TimeInterval = 3){
    let appearance = SCLAlertView.SCLAppearance(showCloseButton: false)
    let alert = SCLAlertView(appearance: appearance)
    alert.showInfo(info, subTitle: subInfo, timeout: SCLAlertView.SCLTimeoutConfiguration(timeoutValue: duration, timeoutAction: {}))
}
func showErr(info: String, subInfo: String, duration: TimeInterval = 3){
    let appearance = SCLAlertView.SCLAppearance(showCloseButton: false)
    let alert = SCLAlertView(appearance: appearance)
    alert.showError(info, subTitle: subInfo, timeout: SCLAlertView.SCLTimeoutConfiguration(timeoutValue: duration, timeoutAction: {}))
}
func showNotice(info: String, subInfo: String, duration: TimeInterval = 3){
    let appearance = SCLAlertView.SCLAppearance(showCloseButton: false)
    let alert = SCLAlertView(appearance: appearance)
    alert.showNotice(info, subTitle: subInfo, timeout: SCLAlertView.SCLTimeoutConfiguration(timeoutValue: duration, timeoutAction: {}))
}
func showWarning(info: String, subInfo: String, duration: TimeInterval = 3){
    let appearance = SCLAlertView.SCLAppearance(showCloseButton: false)
    let alert = SCLAlertView(appearance: appearance)
    alert.showWarning(info, subTitle: subInfo, timeout: SCLAlertView.SCLTimeoutConfiguration(timeoutValue: duration, timeoutAction: {}))
}
func showSuccess(info: String, subInfo: String, duration: TimeInterval = 3){
    let appearance = SCLAlertView.SCLAppearance(showCloseButton: false)
    let alert = SCLAlertView(appearance: appearance)
    alert.showSuccess(info, subTitle: subInfo, timeout: SCLAlertView.SCLTimeoutConfiguration(timeoutValue: duration, timeoutAction: {}))
}
