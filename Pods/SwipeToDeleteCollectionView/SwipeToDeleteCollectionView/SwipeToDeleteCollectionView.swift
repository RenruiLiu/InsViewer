//  SwipeToDeleteCollectionView.h
//  SwipeToDeleteCollectionView
//
//  Created by Jozef Matus on 14/05/2017.
//  Copyright © 2017 Jozef Matus. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

open class SwipeToDeleteCollectionView: UICollectionView {
    var deleteModeGR: UIPanGestureRecognizer = UIPanGestureRecognizer()
    var cancelDeleteModeTapGR: UITapGestureRecognizer = UITapGestureRecognizer()
    var dragingCellIndexPath: IndexPath?
    var disposeBag: DisposeBag = DisposeBag()
    
    
    override open func awakeFromNib() {
        self.setupGestureRecognizer()
    }
    
    override public init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        self.setupGestureRecognizer()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    private func setupGestureRecognizer() {
        deleteModeGR.delegate = self
        deleteModeGR.maximumNumberOfTouches = 1
        self.addGestureRecognizer(self.deleteModeGR)
        deleteModeGR.rx.event.subscribe(onNext: { (recognizer) in
            guard let index = self.dragingCellIndexPath else {
                return
            }
            let translation = recognizer.translation(in: self)
            let cell = self.cellForItem(at: index) as! SwipeToDeleteCollectionViewCell
            cell.contentView.transform = CGAffineTransform(translationX: translation.x, y: 0)
            if recognizer.state == .ended && translation.x > -CGFloat(cell.combinedButtonsWidth/2) {
                cell.contentView.transform = CGAffineTransform(translationX: 0, y: 0)
            }
            if recognizer.state == .ended && translation.x < -CGFloat(cell.combinedButtonsWidth/2) {
                cell.contentView.transform = CGAffineTransform(translationX: -CGFloat(cell.combinedButtonsWidth), y: 0)
            }
            self.addGestureRecognizer(self.cancelDeleteModeTapGR)
        }).disposed(by: self.disposeBag)
        
        self.cancelDeleteModeTapGR.delegate = self
        self.cancelDeleteModeTapGR.rx.event.subscribe(onNext: { recognizer in
            self.cancelSwipeToDelete()
        }).disposed(by: self.disposeBag)
        
    }
    
    func cancelSwipeToDelete() {
        guard let index = self.dragingCellIndexPath else {
            return
        }
        let cell = self.cellForItem(at: index) as! SwipeToDeleteCollectionViewCell
        UIView.animate(withDuration: 0.2) {
            cell.contentView.transform = CGAffineTransform(translationX: 0, y: 0)
        }
        self.dragingCellIndexPath = nil
        self.removeGestureRecognizer(self.cancelDeleteModeTapGR)
    }
    
}

extension SwipeToDeleteCollectionView: UIGestureRecognizerDelegate {
    override open func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard gestureRecognizer != self.cancelDeleteModeTapGR else {
            return true
        }
        guard self.dragingCellIndexPath == nil else {
            self.cancelSwipeToDelete()
            return false
        }
        guard gestureRecognizer == self.deleteModeGR else {
            return super.gestureRecognizerShouldBegin(gestureRecognizer)
        }
        let gr = gestureRecognizer as! UIPanGestureRecognizer
        let velocity = gr.velocity(in: self)
        gr.translation(in: self)
        guard velocity.x < -150 else {
            return false
        }
        guard let index = self.indexPathForItem(at: gr.location(in: self)) else {
            return false
        }
        guard self.isInIndexbounds(index: index) else {
            return false
        }
        self.dragingCellIndexPath = index
        return true
    }
}

public extension UICollectionView {
    func isInIndexbounds(index: IndexPath) -> Bool {
        let sectionsCount = self.numberOfSections
        guard index.section <= sectionsCount else {
            return false
        }
        let itemCount = self.numberOfItems(inSection: index.section)
        guard index.row <= (itemCount - 1) else {
            return false
        }
        return true
    }
}
