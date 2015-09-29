//
//  StreamHeaderCellPresenter.swift
//  Ello
//
//  Created by Sean on 2/18/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation
import TimeAgoInWords

public struct StreamHeaderCellPresenter {

    static func configure(
        cell:UICollectionViewCell,
        streamCellItem:StreamCellItem,
        streamKind: StreamKind,
        indexPath: NSIndexPath,
        currentUser: User?)
    {
        if let cell = cell as? StreamHeaderCell,
            authorable = streamCellItem.jsonable as? Authorable
        {
            cell.close()
            cell.indexPath = indexPath

            cell.ownPost = false
            cell.ownComment = false

            if let currentUser = currentUser,
                comment = streamCellItem.jsonable as? Comment
            {
                if comment.authorId == currentUser.id {
                    cell.ownComment = true
                }
                else if comment.parentPost?.authorId == currentUser.id {
                    cell.ownPost = true
                }
            }

            var author = authorable.author
            var followButtonVisible = false
            if streamCellItem.type == .Header {
                cell.streamKind = streamKind
                cell.avatarHeight = streamKind.isGridLayout ? 30.0 : 60.0
                cell.scrollView.scrollEnabled = false
                cell.chevronHidden = true
                cell.goToPostView.hidden = false

                if let repostAuthor = (streamCellItem.jsonable as? Post)?.repostAuthor
                {
                    author = repostAuthor

                    if let author = author {
                        cell.relationshipControl.userId = author.id
                        cell.relationshipControl.userAtName = author.atName
                        cell.relationshipControl.relationshipPriority = author.relationshipPriority
                    }

                    if streamKind.isDetail {
                        followButtonVisible = true
                    }
                }
                cell.canReply = false
            }
            else {
                cell.canReply = true
            }

            cell.setUser(authorable.author)
            cell.followButtonVisible = followButtonVisible
            cell.timeStamp = streamKind.isGridLayout ? "" : authorable.createdAt.timeAgoInWords()

            if streamCellItem.type == .CommentHeader {
                cell.avatarHeight = 30.0
                cell.scrollView.scrollEnabled = true
                cell.chevronHidden = false
                cell.goToPostView.hidden = true
            }
            cell.updateUsername(author?.atName ?? "", isGridLayout: streamKind.isGridLayout)
            cell.layoutIfNeeded()
        }
    }
}
