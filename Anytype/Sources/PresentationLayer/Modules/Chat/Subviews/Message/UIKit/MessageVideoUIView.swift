import UIKit
import Services
import SwiftUI

final class MessageVideoUIView: UIView {
    
    // MARK: - Private properties
    
    @Injected(\.videoPreviewStorage)
    private var videoPreviewStorage: any VideoPreviewStorageProtocol
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    private var imageTask: Task<Void, Never>?
    
    private let uploadingStatusView = MessageMediaUploadingStatusUIView()
    
    private let loadingIndicator: UIView = UIHostingController(
        rootView: MessageAttachmentLoadingIndicator()
    ).view
    
    private let errorIndicator: UIView = UIHostingController(
        rootView: MessageAttachmentErrorIndicator()
    ).view
    
    // MARK: - Public properties
    
    var url: URL? {
        didSet {
            if url != oldValue {
                updatePreviewIfNeeded()
            }
        }
    }
    
    var syncStatus: SyncStatus? {
        didSet { uploadingStatusView.syncStatus = syncStatus }
    }
    
    var syncError: SyncError? {
        didSet { uploadingStatusView.syncError = syncError }
    }
    
    // MARK: - Public
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if imageView.frame != bounds {
            updatePreviewIfNeeded()
        }
        imageView.frame = bounds
        errorIndicator.frame = bounds
        loadingIndicator.frame = bounds
        uploadingStatusView.frame = bounds
    }
      
    // MARK: - Private
    
    private func setupLayout() {
        addSubview(imageView)
        addSubview(errorIndicator)
        addSubview(loadingIndicator)
        addSubview(uploadingStatusView)
        imageView.clipsToBounds = true
        
        let syncedView: UIView = UIHostingController(
            rootView: MessageLoadingStateContainer {
                Image(asset: .Controls.play)
                    .foregroundStyle(Color.white)
                }
                .background(.black.opacity(0.5))
        ).view
        syncedView.backgroundColor = .clear
        uploadingStatusView.syncedView = syncedView
    }
    
    private func updatePreviewIfNeeded() {
        
        imageTask?.cancel()
        imageView.image = nil
        uploadingStatusView.isHidden = true
        
        let size = imageView.frame.size
        
        if let url {
            
            errorIndicator.isHidden = true
            loadingIndicator.isHidden = false
            
            imageTask = Task { [weak self, videoPreviewStorage] in
                do {
                    let image = try await videoPreviewStorage.preview(url: url, size: size)
                    self?.errorIndicator.isHidden = true
                    self?.loadingIndicator.isHidden = true
                    guard !Task.isCancelled else { return }
                    self?.imageView.image = image
                    self?.uploadingStatusView.isHidden = false
                } catch {
                    self?.errorIndicator.isHidden = false
                    self?.loadingIndicator.isHidden = true
                }
            }
        }
    }
}

extension MessageVideoUIView {
    func setDetails(_ details: MessageAttachmentDetails) {
        url = ContentUrlBuilder.fileUrl(fileId: details.id)
        syncStatus = details.syncStatus
        syncError = details.syncError
    }
}
