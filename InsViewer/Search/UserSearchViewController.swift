//
//  UserSearchViewController.swift
//  InsViewer
//
//  Created by Renrui Liu on 14/9/18.
//  Copyright © 2018 Renrui Liu. All rights reserved.
//

import UIKit
import Firebase

class UserSearchViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UISearchBarDelegate {
    
    var users = [UserProfile]()
    var userId: String?
    let cellId = "cellId"
    var mode = 0 // 0 = All users, 1 = followers, 2 = followings
    
    // use lazy var to allow accessing searchbar delegate
    lazy var searchBar : UISearchBar = {
        let sb = UISearchBar()
        sb.placeholder = NSLocalizedString("enterUsername", comment: "")
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).backgroundColor = UIColor.rgb(red: 230, green: 230, blue: 230)
        sb.delegate = self
        return sb
    }()
    
    var filteredUsers = [UserProfile]()
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredUsers = users
        }else{
            filteredUsers = self.users.filter { (user) -> Bool in
                return user.username.lowercased().contains(searchText.lowercased())
            }
        }
        self.collectionView?.reloadData()
    }
    
    //____________________________________________________________________________________

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.backgroundColor = .white
        
        
        navigationController?.navigationBar.addSubview(searchBar)
        let navBar = navigationController?.navigationBar
        
        collectionView?.register(UserSearchCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.alwaysBounceVertical = true
        collectionView?.keyboardDismissMode = .onDrag
        
        if mode == 0 {
            searchBar.anchor(top: navBar?.topAnchor, paddingTop: 0, bottom: navBar?.bottomAnchor, paddingBottom: 0, left: navBar?.leftAnchor, paddingLeft: 8, right: navBar?.rightAnchor, paddingRight: 8, width: 0, height: 0)
            fetchUsers()
            
        }
        else if mode == 1 {
            searchBar.anchor(top: navBar?.topAnchor, paddingTop: 0, bottom: navBar?.bottomAnchor, paddingBottom: 0, left: navBar?.leftAnchor, paddingLeft: 75, right: navBar?.rightAnchor, paddingRight: 8, width: 0, height: 0)
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: NSLocalizedString("back", comment: ""), style: .plain, target: self, action: #selector(handleCancel))
            fetchFollowers()
            
        }
        else {
            searchBar.anchor(top: navBar?.topAnchor, paddingTop: 0, bottom: navBar?.bottomAnchor, paddingBottom: 0, left: navBar?.leftAnchor, paddingLeft: 75, right: navBar?.rightAnchor, paddingRight: 8, width: 0, height: 0)
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: NSLocalizedString("back", comment: ""), style: .plain, target: self, action: #selector(handleCancel))
            fetchFollowing()
        }
    }
    
    //____________________________________________________________________________________
    fileprivate func fetchFollowers(){
        guard let uid = userId else {return}
        let ref = Database.database().reference().child("followers").child(uid)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let dictionaries = snapshot.value as? [String:Any] else {return}
            
            //get list of followers
            var followers = [String]()
            dictionaries.forEach({ (arg) in
                let (key, _) = arg
                followers.append(key)
            })
            
            //get their userProfile
            self.fetchUsers(filter: followers)
            
        }) { (err) in
            print("Failed to fetch followers:",err)
        }
    }
    
    fileprivate func fetchFollowing(){
        guard let uid = userId else {return}
        let ref = Database.database().reference().child("following").child(uid)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let dictionaries = snapshot.value as? [String:Any] else {return}
            
            //get list of followers
            var following = [String]()
            dictionaries.forEach({ (arg) in
                let (key, _) = arg
                following.append(key)
            })
            
            //get their userProfile
            self.fetchUsers(filter: following)
            
        }) { (err) in
            print("Failed to fetch followers:",err)
        }
    }
    
    fileprivate func fetchUsers(filter: [String] = []){
        let ref = Database.database().reference().child("users")
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let dictionaries = snapshot.value as? [String:Any] else {return}
            dictionaries.forEach({ (key,value) in
                // check if the key is current user, then omit it
                if key == Auth.auth().currentUser?.uid {
                    return
                }
                if !filter.isEmpty {
                    // if key is in list, then add in users
                    if filter.contains(key) {
                        guard let userDictionary = value as? [String:Any] else {return}
                        let user = UserProfile(uid: key, dict: userDictionary)
                        self.users.append(user)
                    }
                } else {
                    // add all users in users
                    guard let userDictionary = value as? [String:Any] else {return}
                    let user = UserProfile(uid: key, dict: userDictionary)
                    self.users.append(user)
                }
            })
            self.users.sort(by: { (u1, u2) -> Bool in
                return u1.username.compare(u2.username) == .orderedAscending
            })
            self.filteredUsers = self.users
            self.collectionView?.reloadData()
        }) { (err) in
            print("Failed to fetch users for search:",err)
        }
    }
    
    //____________________________________________________________________________________
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredUsers.count
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! UserSearchCell
        cell.user = filteredUsers[indexPath.item]
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 66)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        searchBar.isHidden = false
    }
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let user = filteredUsers[indexPath.item]
        searchBar.isHidden = true
        searchBar.resignFirstResponder() // hide the keyboard when we navigate
        
        // move to the selected searched user's profile page
        let userProfileVC = UserProfileViewController(collectionViewLayout: UICollectionViewFlowLayout())
        userProfileVC.userId = user.uid
        navigationController?.pushViewController(userProfileVC, animated: true)
    }
    
    @objc func handleCancel(){
        dismiss(animated: true, completion: nil)
    }
}
