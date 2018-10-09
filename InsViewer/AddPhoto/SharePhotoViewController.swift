//
//  SharePhotoViewController.swift
//  InsViewer
//
//  Created by Renrui Liu on 13/9/18.
//  Copyright © 2018 Renrui Liu. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation

class SharePhotoViewController: UIViewController, CLLocationManagerDelegate {
    
    var locationManager = CLLocationManager()

    static let updateFeedNotificationName = NSNotification.Name(rawValue: "UpdateFeed")
    
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
    
    let showLocationLabel: UILabel = {
        let lb = UILabel()
        lb.text = "Location: "
        lb.font = UIFont.systemFont(ofSize: 14)
        lb.textAlignment = .center
        return lb
    }()
    lazy var addLocationSwitch: UISwitch = {
        let sw = UISwitch()
        sw.addTarget(self, action: #selector(handleSwitchValueChanged), for: .valueChanged)
        return sw
    }()
    let locationLabel: UILabel = {
        let lb = UILabel()
        lb.text = ""
        lb.numberOfLines = 2
        lb.font = UIFont.systemFont(ofSize: 12)
        return lb
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
        
        
        view.addSubview(addLocationSwitch)
        addLocationSwitch.anchor(top: containerView.bottomAnchor, paddingTop: 8, bottom: nil, paddingBottom: 0, left: containerView.leftAnchor, paddingLeft: 16, right: nil, paddingRight: 0, width: 0, height: 30)
        view.addSubview(showLocationLabel)
        showLocationLabel.anchor(top: containerView.bottomAnchor, paddingTop: 8, bottom: nil, paddingBottom: 0, left: addLocationSwitch.rightAnchor, paddingLeft: 4, right: nil, paddingRight: 0, width: 0, height: 30)
        view.addSubview(locationLabel)
        locationLabel.anchor(top: containerView.bottomAnchor, paddingTop: 8, bottom: nil, paddingBottom: 0, left: showLocationLabel.rightAnchor, paddingLeft: 4, right: containerView.rightAnchor, paddingRight: 4, width: 0, height: 30)
    }
    
    //____________________________________________________________________________________
    // share photo & save to database
    @objc func handleShare(){
        // unable to share if no caption
        guard let caption = textView.text, caption.count > 0 else {return}
        guard let image = selectedImg else {return}
        guard let uploadData = image.jpegData(compressionQuality: 0.5) else {return}//compression image
        // disable the share button to prevent duplication
        navigationItem.rightBarButtonItem?.isEnabled = false
        
        let filename = NSUUID().uuidString
        Storage.storage().reference().child("posts").child(filename).putData(uploadData, metadata: nil) { (metadata, err) in
            if let _ = err {
                // enable the share button when a error occurs so the user can re-share it
                self.navigationItem.rightBarButtonItem?.isEnabled = true
                
                showErr(info: NSLocalizedString("failtoUploadData", comment: ""), subInfo: tryLater)
                return
            }
            guard let imageUrl = metadata?.downloadURL()?.absoluteString else {return}
            print("Successfully uploaded post image:", imageUrl)
            self.saveToDatabaseWithImageUrl(imageUrl: imageUrl, filename: filename)
        }
    }
    
    // create a child node "posts" which contains all infomation of posts of users
    
    fileprivate func saveToDatabaseWithImageUrl(imageUrl: String, filename: String){
        //
        guard let postImg = selectedImg else {return}
        guard let uid = Auth.auth().currentUser?.uid else {return}
        guard let caption = textView.text else {return}
        //
        let userPostRef = Database.database().reference().child("posts").child(uid)
        let ref = userPostRef.childByAutoId()
        // imgUrl - caption - imgWidth - imgHeight - creationDate
        let values = ["imageUrl": imageUrl, "caption": caption, "imageWidth": postImg.size.width, "imageHeight": postImg.size.height, "creationDate": Date().timeIntervalSince1970, "postImgFileName": filename] as [String: Any]
        ref.updateChildValues(values) { (err, ref) in
            if let _ = err {
                self.navigationItem.rightBarButtonItem?.isEnabled = true
                
                showErr(info: NSLocalizedString("failtoSavePost", comment: ""), subInfo: tryLater)
                return
            }
            print("Successfully saved post to database")
            
            // refresh home page
            NotificationCenter.default.post(name: SharePhotoViewController.updateFeedNotificationName, object: nil)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    var isShowingLocation: Bool = false
    @objc fileprivate func handleSwitchValueChanged(){
        isShowingLocation = !isShowingLocation
        if isShowingLocation == false {
            locationLabel.text = ""
            return
        }
        locationLabel.text = "loading..."
        
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            CLGeocoder().reverseGeocodeLocation(manager.location!) { (placemarks, err) in
            if (err != nil) {
                print("Failed to reverse geocoder:",err!)
                return
            }
            if placemarks?.count ?? 0 > 0 && self.isShowingLocation {
                let pm = placemarks?[0] as! CLPlacemark
                let address = pm.name ?? ""
                let suburb = pm.locality ?? ""
                let city = pm.subLocality ?? ""
                self.locationLabel.text = "\(address) \(suburb) \(city) "
                manager.stopUpdatingLocation()
            }
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to fetch user location:",error.localizedDescription)
    }
    
    
    //____________________________________________________________________________________
    override var prefersStatusBarHidden: Bool {return true}
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.rgb(red: 240, green: 240, blue: 240)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("share", comment: ""), style: .plain, target: self, action: #selector(handleShare))
        setupImageAndTextViews()
        
        self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }

}
