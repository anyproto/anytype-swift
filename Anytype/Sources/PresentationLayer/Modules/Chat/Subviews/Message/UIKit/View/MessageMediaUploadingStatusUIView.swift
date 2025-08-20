import UIKit
import Services
import SwiftUI

final class MessageMediaUploadingStatusUIView: UIView {
    
    private let loadingView: UIView = UIHostingController(
        rootView: MessageCircleLoadingView()
    ).view
    
    private var errorView: UIView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var syncedView: UIView? {
        didSet {
            if syncedView !== oldValue {
                setNeedsLayout()
                oldValue?.removeFromSuperview()
            }
        }
    }
    
    var syncStatus: SyncStatus? {
        didSet {
            if syncStatus != oldValue {
                setNeedsLayout()
            }
        }
    }
    
    var syncError: SyncError? {
        didSet {
            if syncError != oldValue {
                setNeedsLayout()
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        switch syncStatus {
        case .synced, .UNRECOGNIZED, .none:
            loadingView.isHidden = true
            errorView?.isHidden = true
            syncedView?.isHidden = false
            if let syncedView {
                addSubview(syncedView)
            }
        case .syncing, .queued:
            loadingView.isHidden = false
            syncedView?.isHidden = true
            errorView?.isHidden = true
        case .error:
            errorView?.removeFromSuperview()
            loadingView.isHidden = true
            syncedView?.isHidden = true
            let newErrorView: UIView = UIHostingController(
                rootView: MessageErrorView(syncError: syncError)
            ).view
            addSubview(newErrorView)
            errorView = newErrorView
        }
        
        loadingView.frame = bounds
        errorView?.frame = bounds
        syncedView?.frame = bounds
    }
    
    // MARK: - Private
    
    private func setupLayout() {
        addSubview(loadingView)
    }
}
