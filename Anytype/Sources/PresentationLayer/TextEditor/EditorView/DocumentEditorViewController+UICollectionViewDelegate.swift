//
//  DocumentEditorViewController+UICollectionViewDelegate.swift
//  DocumentEditorViewController+UICollectionViewDelegate
//
//  Created by Konstantin Mordan on 09.08.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import UIKit
import Amplitude
import BlocksModels

// MARK: - UICollectionViewDelegate

extension DocumentEditorViewController: UICollectionViewDelegate {
    
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        viewModel.didSelectBlock(at: indexPath)
        if viewModel.selectionHandler.selectionEnabled {
            return
        }
        collectionView.deselectItem(at: indexPath, animated: false)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        didDeselectItemAt indexPath: IndexPath
    ) {
        if !viewModel.selectionHandler.selectionEnabled {
            return
        }
        self.viewModel.didSelectBlock(at: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        shouldSelectItemAt indexPath: IndexPath
    ) -> Bool {
        guard let item = dataSource.itemIdentifier(for: indexPath)
        else { return false }
        
        if viewModel.selectionHandler.selectionEnabled {
            switch item {
            case let .block(block):
                guard case let .text(text) = block.content else { return true }
                return text.contentType != .title
            }
        }
        
        switch item {
        case let .block(block):
            guard case .text = block.content else { return true }
            return false
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        contextMenuConfigurationForItemAt indexPath: IndexPath,
        point: CGPoint
    ) -> UIContextMenuConfiguration? {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return nil }

        switch item {
        case let .block(block):
            // Analytics
            Amplitude.instance().logEvent(AmplitudeEventsName.popupActionMenu)
            
            return block.contextMenuConfiguration()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let relativeYOffset = -(scrollView.contentOffset.y + scrollView.contentInset.top)
        if relativeYOffset < 0 {
            objectHeaderViewTopConstraint.constant = relativeYOffset
        } else {
            objectHeaderView.activeHeightConstraint?.constant = max(-scrollView.contentOffset.y, scrollView.contentInset.top)
        }
    }
    
}
