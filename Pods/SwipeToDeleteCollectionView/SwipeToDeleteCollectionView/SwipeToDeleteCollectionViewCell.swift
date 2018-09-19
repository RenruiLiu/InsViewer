//  SwipeToDeleteCollectionView.h
//  SwipeToDeleteCollectionView
//
//  Created by Jozef Matus on 14/05/2017.
//  Copyright © 2017 Jozef Matus. All rights reserved.
//
import UIKit
import RxCocoa
import RxSwift

public protocol SwipeToDeleteCellAble {
    var swipeToDeleteButtons: [SwipeToDeleteButton] { get set }
    func setButtonsArray()
    func configure(WithViewModel vm: SwipeToDeleteCellVM)
}

open class SwipeToDeleteCollectionViewCell: UICollectionViewCell, SwipeToDeleteCellAble {
    
    public var swipeToDeleteButtons: [SwipeToDeleteButton] = []
    var subscriptions: [Disposable] = []
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        self.setButtonsArray()
        self.createDeleteView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override open func prepareForReuse() {
        for subscription in subscriptions {
            subscription.dispose()
        }
    }
    
    func createDeleteView() {
        //create underlying view for swipe to delete
        self.contentView.backgroundColor = UIColor.white
        let deleteView = UIView(frame: self.bounds)
        deleteView.translatesAutoresizingMaskIntoConstraints = false
        deleteView.backgroundColor = UIColor.lightText
        deleteView.layer.zPosition = -10
        self.backgroundView = deleteView
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[subview]-0-|", options: .directionLeadingToTrailing, metrics: nil, views: ["subview" : deleteView]))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[subview]-0-|", options: .directionLeadingToTrailing, metrics: nil, views: ["subview" : deleteView]))
        
        self.addSwipeToDeleteButtons(ToView: deleteView)
        
    }
    
    open func configure(WithViewModel vm: SwipeToDeleteCellVM) {
        for button in self.swipeToDeleteButtons {
            self.subscriptions.append(button.rx.tap.map { _ in return button.data.actionId } .bind(to: vm.swipeToDeleteActionsObserver))
        }
    }
    
    open func setButtonsArray() {
        let deleteButton = SwipeToDeleteButton(data: SwipeToDeleteButtonData(width: 70, color: UIColor.red, title: "DELETE", font: UIFont.boldSystemFont(ofSize: 12), actionId: "delete"))
        self.swipeToDeleteButtons = [deleteButton]
    }
    
    private func addSwipeToDeleteButtons(ToView view: UIView) {
        guard self.swipeToDeleteButtons.count > 0 else {
            return
        }
        for i in 0...self.swipeToDeleteButtons.count - 1 {
            let deleteButton = self.swipeToDeleteButtons[i]
            view.addSubview(deleteButton)
            
            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[button]-\(self.getButtonOffset(ForIndex: i))-|", options: .directionLeadingToTrailing, metrics: nil, views: ["button" : deleteButton]))
            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[button]-0-|", options: .directionLeadingToTrailing, metrics: nil, views: ["button" : deleteButton]))
            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[button(\(deleteButton.data.width))]", options: .directionLeadingToTrailing, metrics: nil, views: ["button" : deleteButton]))
        }
    }
    
    private func getButtonOffset(ForIndex index: Int) -> Int {
        
        guard index < self.swipeToDeleteButtons.count && index > -1 else {
            fatalError("Index out of bounds")
        }
        var offset: Int = 0
        guard index > 0 else {
            return offset
        }
        for i in 0...index-1 {
            offset += self.swipeToDeleteButtons[i].data.width
        }
        return offset
    }
    
    var combinedButtonsWidth: Int { return
        self.swipeToDeleteButtons.reduce(0, { (initialValue, button) -> Int in
            return initialValue + button.data.width
        })
    }
    
}

open class SwipeToDeleteButton: UIButton {
    
    var data: SwipeToDeleteButtonData
    
    public init(data: SwipeToDeleteButtonData) {
        self.data = data
        super.init(frame: CGRect.zero)
        self.backgroundColor = data.color
        self.setTitle(data.title, for: .normal)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel?.font = data.font
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
}

public struct SwipeToDeleteButtonData {
    var width: Int
    var color: UIColor
    var title: String
    var font: UIFont
    var actionId: String
    
    public init(width: Int, color: UIColor, title: String, font: UIFont, actionId: SwipeToDeleteActionID) {
        self.width = width
        self.color = color
        self.title = title
        self.font = font
        self.actionId = actionId
    }
}

