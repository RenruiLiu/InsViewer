//
//  RootViewController.swift
//  InstagramViewer
//
//  Created by Renrui Liu on 9/9/18.
//  Copyright © 2018 Renrui Liu. All rights reserved.
//

import UIKit

class RootViewController: UIPageViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    lazy var vcArray: [UIViewController] = {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let appVC = storyBoard.instantiateViewController(withIdentifier: "appVC")
        let camVC = storyBoard.instantiateViewController(withIdentifier: "camVC")
        let msgVC = storyBoard.instantiateViewController(withIdentifier: "msgVC")
        return [appVC,msgVC,camVC]
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dataSource = self
        self.delegate = self
        
        if let fstVC = self.vcArray.first{
            self.setViewControllers([fstVC], direction: .forward, animated: true, completion: nil)
        }
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let vcIndex = vcArray.index(of: viewController) else{ return nil}
        let prevIndex = vcIndex - 1
        guard prevIndex >= 0 else {return vcArray.last}
        guard vcArray.count > prevIndex else {return nil}
        return vcArray[prevIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let vcIndex = vcArray.index(of: viewController) else{ return nil}
        let nextIndex = vcIndex + 1
        guard nextIndex < vcArray.count else {return vcArray.first}
        guard vcArray.count > nextIndex else {return nil}
        return vcArray[nextIndex]
    }
    
}
