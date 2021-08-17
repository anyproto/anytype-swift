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
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        viewModel.didSelectBlock(at: indexPath)
        if viewModel.selectionHandler.selectionEnabled {
            return
        }
        collectionView.deselectItem(at: indexPath, animated: false)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        didDeselectItemAt indexPath: IndexPath) {
        if !viewModel.selectionHandler.selectionEnabled {
            return
        }
        self.viewModel.didSelectBlock(at: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        if dataSource.snapshot().sectionIdentifiers[indexPath.section] == .header {
            return false
        }
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        shouldSelectItemAt indexPath: IndexPath) -> Bool {
        guard let item = dataSource.itemIdentifier(for: indexPath)
        else { return false }
        
        if viewModel.selectionHandler.selectionEnabled {
            switch item {
            case let .block(block):
                guard case let .text(text) = block.content else { return true }
                return text.contentType != .title
            case .header:
                return false
            }
        }
        
        switch item {
        case let .block(block):
            guard case .text = block.content else { return true }
            return false
        case .header:
            return false
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        contextMenuConfigurationForItemAt indexPath: IndexPath,
                        point: CGPoint
    ) -> UIContextMenuConfiguration? {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return nil }

        switch item {
        case let .block(block):
            // Analytics
            Amplitude.instance().logEvent(AmplitudeEventsName.popupActionMenu)
            
            return block.contextMenuConfiguration()
        case .header:
            return nil
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let startAppearingOffset: CGFloat = 200
        let endAppearingOffset: CGFloat = 232

        let navigationBarHeight = navigationBarBackgroundView.bounds.height
        
        let yFullOffset = scrollView.contentOffset.y + navigationBarHeight

        let alpha: CGFloat? = {
            if yFullOffset < startAppearingOffset {
                updateBarButtonItemsBackground(hasBackground: isBarButtonItemsWithBackground)
                return 0
            } else if yFullOffset > endAppearingOffset {
                updateBarButtonItemsBackground(hasBackground: false)
                return 1
            } else if yFullOffset > startAppearingOffset, yFullOffset < endAppearingOffset {
                let currentDiff = yFullOffset - startAppearingOffset
                let max = endAppearingOffset - startAppearingOffset
                return currentDiff / max
            }
            
            return nil
        }()
        
        guard let alpha = alpha else {
            return
        }

        navigationBarBackgroundView.alpha = alpha
    }
    
}
