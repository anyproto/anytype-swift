//
//  EditorNavigationBarHelper.swift
//  EditorNavigationBarHelper
//
//  Created by Konstantin Mordan on 18.08.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import Foundation
import UIKit
import BlocksModels

final class EditorNavigationBarHelper {
    
    private let navigationBarBackgroundView = UIView()
    private let navigationBarTitleView = EditorNavigationBarTitleView()
    
    private let backBarButtonItemView: EditorBarButtonItemView
    private let settingsBarButtonItemView: EditorBarButtonItemView
    
    private var isBarButtonItemsWithBackground = false
    
    private var contentOffsetObservation: NSKeyValueObservation?
    
    private var objectHeaderHeight: CGFloat = 0.0
    
    init(onBackBarButtonItemTap: @escaping () -> Void,
         onSettingsBarButtonItemTap: @escaping () -> Void) {
        self.backBarButtonItemView = EditorBarButtonItemView(
            image: .backArrow,
            action: onBackBarButtonItemTap
        )
        self.settingsBarButtonItemView = EditorBarButtonItemView(
            image: .more,
            action: onSettingsBarButtonItemTap
        )
        
        self.navigationBarBackgroundView.backgroundColor = .grayscaleWhite
        self.navigationBarBackgroundView.alpha = 0.0
        
        self.navigationBarTitleView.setAlphaForSubviews(0.0)
    }
    
}

// MARK: - EditorNavigationBarHelperProtocol

extension EditorNavigationBarHelper: EditorNavigationBarHelperProtocol {
    
    func addNavigationBarBackgroundView(to view: UIView) {
        view.addSubview(navigationBarBackgroundView) {
            $0.top.equal(to: view.topAnchor)
            $0.leading.equal(to: view.leadingAnchor)
            $0.trailing.equal(to: view.trailingAnchor)
            $0.bottom.equal(to: view.layoutMarginsGuide.topAnchor)
        }
    }
    
    func handleViewWillAppear(_ vc: UIViewController?, _ scrollView: UIScrollView) {
        guard let vc = vc else {
            return
        }
        
        configureNavigationItem(in: vc)
        
        contentOffsetObservation = scrollView.observe(
            \.contentOffset,
            options: .new
        ) { [weak self] scrollView, _ in
            self?.handleScrollViewOffsetChange(scrollView.contentOffset.y)
        }
    }
    
    func handleViewWillDisappear() {
        contentOffsetObservation?.invalidate()
        contentOffsetObservation = nil
    }
    
    func configureNavigationBarUsing(header: ObjectHeader, titleBlockText: BlockText?) {
        objectHeaderHeight = header.height
        
        isBarButtonItemsWithBackground = header.isWithCover
        updateBarButtonItemsBackground(hasBackground: isBarButtonItemsWithBackground)
        
        let title: String = {
            guard
                let string = titleBlockText?.attributedText.string,
                !string.isEmpty
            else {
                return "Untitled".localized
            }
            
            return string
        }()
        
        navigationBarTitleView.configure(
            model: EditorNavigationBarTitleView.Model(
                icon: nil,
                title: title
            )
        )
        
    }
    
}

// MARK: - Private extension

private extension EditorNavigationBarHelper {
    
    func configureNavigationItem(in vc: UIViewController) {
        vc.navigationItem.titleView = navigationBarTitleView
        
        vc.setupBackBarButtonItem(
            UIBarButtonItem(customView: backBarButtonItemView)
        )
        
        vc.navigationItem.rightBarButtonItem = UIBarButtonItem(
            customView: settingsBarButtonItemView
        )
        
        updateBarButtonItemsBackground(hasBackground: isBarButtonItemsWithBackground)
    }
    
    func updateBarButtonItemsBackground(hasBackground: Bool) {
        [backBarButtonItemView, settingsBarButtonItemView].forEach {
            guard $0.hasBackground != hasBackground else { return }
            
            $0.hasBackground = hasBackground
        }
    }
    
    func handleScrollViewOffsetChange(_ newOffset: CGFloat) {
        let startAppearingOffset = objectHeaderHeight - 50
        let endAppearingOffset = objectHeaderHeight

        let navigationBarHeight = navigationBarBackgroundView.bounds.height
        
        let yFullOffset = newOffset + navigationBarHeight

        let alpha: CGFloat? = {
            if yFullOffset < startAppearingOffset {
                return 0
            } else if yFullOffset > endAppearingOffset {
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
        
        switch alpha {
        case 0.0:
            updateBarButtonItemsBackground(hasBackground: isBarButtonItemsWithBackground)
        case 1.0:
            updateBarButtonItemsBackground(hasBackground: false)
        default:
            break
        }

        navigationBarTitleView.setAlphaForSubviews(alpha)
        navigationBarBackgroundView.alpha = alpha
    }
    
}

// MARK: - ObjectHeader

private extension ObjectHeader {
    
    var isWithCover: Bool {
        switch self {
        case .iconOnly:
            return false
        case .coverOnly:
            return true
        case .iconAndCover:
            return true
        case .empty:
            return false
        }
    }
    
    var height: CGFloat {
        switch self {
        case .iconOnly:
            return ObjectHeaderIconOnlyContentView.Constants.height
        case .coverOnly:
            return ObjectHeaderCoverOnlyContentView.Constants.height
        case .iconAndCover:
            return ObjectHeaderIconAndCoverContentView.Constants.height
        case .empty:
            return ObjectHeaderEmptyContentView.Constants.height
        }
    }
    
}
