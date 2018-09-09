//
//  AppViewController.swift
//  InsViewer
//
//  Created by Renrui Liu on 9/9/18.
//  Copyright © 2018 Renrui Liu. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    //
    @IBOutlet weak var contentTable: UITableView!
    
    //functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        contentTable.delegate = self
        contentTable.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = contentTable.dequeueReusableCell(withIdentifier: "contentCell"){
            return cell
        } else {
            return UITableViewCell()
        }
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}
