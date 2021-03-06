//
//  CustomImageView.swift
//  InsViewer
//
//  Created by Renrui Liu on 14/9/18.
//  Copyright © 2018 Renrui Liu. All rights reserved.
//

import UIKit

var imageCache = [String: UIImage]()

class CustomImageView: UIImageView {
    
    var lastUrlUsedToLoadImage: String?
    
    func loadImage(urlString: String){
        self.image = nil
        
        lastUrlUsedToLoadImage = urlString
        // check cache
        // if this url is in the cache dictionary, then return in order to prevent fetch it againa
        if let cachedImage = imageCache[urlString] {
            self.image = cachedImage
            return
        }
        
        guard let url = URL(string: urlString) else {return}
        //URLSession will open a background thread to download whatever in the url
        // and can do something after the response is returned
        URLSession.shared.dataTask(with: url) { (data, response, err) in
            if let err = err {
                print("Failed to fetch post image:", err)
                return
            }
            // successfully got the data (HTTP Code 200)
            
            // prevent from repeatly reloading cells
            // ? 如果传入本cell的url不同于post的url 则跳出
            if url.absoluteString != self.lastUrlUsedToLoadImage {return}
            
            
            // cast the data to UIImage
            guard let imageData = data else {return}
            let photoImg = UIImage(data: imageData)
            // store the image into cache
            imageCache[url.absoluteString] = photoImg
            // get back onto the main UI thread, otherwise it stays on URLSession background thread
            DispatchQueue.main.async {
                // set the image to the view
                self.image = photoImg
            }
            }.resume() // never forget to resume to main thread after dataTast
    }
}
