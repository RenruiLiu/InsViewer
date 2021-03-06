//
//  HomePostCellDelegate.swift
//  InsViewer
//
//  Created by Renrui Liu on 16/9/18.
//  Copyright © 2018 Renrui Liu. All rights reserved.
//

import Foundation

protocol HomePostCellDelegate {
    func didTapComment(post: Post)
    func didLike(for cell: HomePostCell)
    func didPressOption(post: Post)
    func didSave(for cell: HomePostCell)
    func didShare(for cell: HomePostCell)
}

protocol UserProfileHeaderDelegate {
    func didChangeToListView()
    func didChangeToGridView()
    func didChangeToSavedView()
    func presentEditProfileVC(user: UserProfile)
}

protocol CommentDelegate {
    func didDeleteComment(comment: Comment, cellId: Int)
}
