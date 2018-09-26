//
//  PhotoSelectorCollectionViewController.swift
//  InsViewer
//
//  Created by Renrui Liu on 12/9/18.
//  Copyright © 2018 Renrui Liu. All rights reserved.
//

import UIKit
import Photos
import Sharaku

private let reuseIdentifier = "Cell"
private let headerId = "headerId"

class PhotoSelectorCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, SHViewControllerDelegate {

    //____________________________________________________________________________________
    // navigation bar buttons
    fileprivate func setupNavigationButtons(){
        navigationController?.navigationBar.tintColor = .black
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(handleNext))
    }
    
    // filter photo
    @objc func handleNext(){
        guard let imgTobeFiltered = header?.photoImgView.image else {return}
        let filterVC = SHViewController(image: imgTobeFiltered)
        filterVC.delegate = self
        self.present(filterVC, animated: true)
    }
    
    //move to next: share photo
    func shViewControllerImageDidFilter(image: UIImage) {

        let sharePhotoVC = SharePhotoViewController()
        // pass the selected image to share photo page
        sharePhotoVC.selectedImg = image
        navigationController?.pushViewController(sharePhotoVC, animated: true)
    }
    
    func shViewControllerDidCancel() {}
    
    
    @objc func handleCancel(){
        dismiss(animated: true, completion: nil)
    }
    
    override var prefersStatusBarHidden: Bool { return true }
    
    //____________________________________________________________________________________
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView?.backgroundColor = .white
        setupNavigationButtons()

        // Register cell classes
        self.collectionView!.register(PhotoSelectorCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // header
        self.collectionView?.register(PhotoSelectorHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerId)
        
        fetchPhotos()
    }
    
    //____________________________________________________________________________________
    // fetch images
    var images = [UIImage]()
    var assets = [PHAsset]()
    
    fileprivate func assetFetchOptions() -> PHFetchOptions{
        let fetchOptions = PHFetchOptions()
        fetchOptions.fetchLimit = 15 //fetch number of photos in library
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchOptions.sortDescriptors = [sortDescriptor]
        return fetchOptions
    }
    
    fileprivate func fetchPhotos(){
        let allPhotos = PHAsset.fetchAssets(with: .image, options: assetFetchOptions())
        
        // load the images in background thread
        DispatchQueue.global(qos: .background).async {
            allPhotos.enumerateObjects { (asset, count, stop) in
                let imageManager = PHImageManager.default()
                // the resolution(quality) of image
                let targetSize = CGSize(width: 200, height: 200)
                let options = PHImageRequestOptions()
                options.isSynchronous = true
                imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFit, options: options, resultHandler: { (image, info) in
                    if let image = image{
                        self.images.append(image)
                        self.assets.append(asset)
                        
                        // select a default image for header
                        if self.selectedImg == nil{
                            self.selectedImg = image
                        }
                    }
                    if count == allPhotos.count - 1 {
                        //
                        DispatchQueue.main.async {
                            self.collectionView?.reloadData()
                        }
                    }
                })
            }
        }

    }
    
    //____________________________________________________________________________________
    // custom cells
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PhotoSelectorCell
        
        cell.photoImgView.image = images[indexPath.item]
        return cell
    }
    // the gaps between vertical and horizontical cells
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    // the size of cells
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.width - 3) / 4
        return CGSize(width: width, height: width)
    }
    // custom header
    var header: PhotoSelectorHeader?
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerId, for: indexPath) as! PhotoSelectorHeader
        
        self.header = header
        header.photoImgView.image = selectedImg
        
        let imageManager = PHImageManager.default()
        if let selectedImg = selectedImg{
            if let index = self.images.index(of: selectedImg) {
                let selectedAsset = self.assets[index]
                let targetSize = CGSize(width: 600, height: 600)
                imageManager.requestImage(for: selectedAsset, targetSize: targetSize, contentMode: .default, options: nil) { (image, info) in
                    header.photoImgView.image = image
                }
            }
        }

        return header
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let width = view.frame.width
        return CGSize(width: width, height: width)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 1, left: 0, bottom: 0, right: 0)
    }
    // select a image
    var selectedImg: UIImage?
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedImg = images[indexPath.item]
        collectionView.reloadData()
        // after an item is selected, scroll to the top
        let indexPath = IndexPath(item: 0, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .bottom, animated: true)
    }
    
}
