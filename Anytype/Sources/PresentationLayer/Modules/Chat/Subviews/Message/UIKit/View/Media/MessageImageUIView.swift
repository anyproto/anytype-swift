import UIKit
import DesignKit
import Services
import SwiftUI

final class MessageImageUIView: UIView {
    
    // MARK: - Private properties
    
    private let cache: CachedAsyncImageCache = .default
    private var imageURL: URL?
    private var imageTask: Task<Void, Never>?
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let uploadingStatusView = MessageMediaUploadingStatusUIView()
    
    private let loadingIndicator: UIView = UIHostingController(
        rootView: MessageAttachmentLoadingIndicator()
    ).view
    
    private let errorIndicator: UIView = UIHostingController(
        rootView: MessageAttachmentErrorIndicator()
    ).view
    
    // MARK: - Public properties
    
    var imageId: String? {
        didSet { updateImageContentIfNeeded() }
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
    
    // MARK: - Private
    
    private func setupLayout() {
        addSubview(imageView)
        addSubview(errorIndicator)
        addSubview(loadingIndicator)
        addSubview(uploadingStatusView)
        imageView.clipsToBounds = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = bounds
        errorIndicator.frame = bounds
        loadingIndicator.frame = bounds
        uploadingStatusView.frame = bounds
        updateImageContentIfNeeded()
    }
    
    deinit {
        imageTask?.cancel()
        imageTask = nil
    }
    
    private func updateImageContentIfNeeded() {
        guard let imageId else { return }
        
        let newUrl = ImageMetadata(
            id: imageId,
            side: .width(min(frame.width, frame.height))
        ).contentUrl
        
        if imageURL != newUrl {
            imageURL = newUrl
            imageTask?.cancel()
            imageView.image = nil
                        
            if let newUrl {
                
                errorIndicator.isHidden = true
                loadingIndicator.isHidden = false
                
                imageTask = Task { [weak self, cache] in
                    do {
                        let image = try await cache.loadImage(from: newUrl)
                        self?.errorIndicator.isHidden = true
                        self?.loadingIndicator.isHidden = true
                        guard !Task.isCancelled else { return }
                        self?.imageView.image = image
                    } catch {
                        self?.errorIndicator.isHidden = false
                        self?.loadingIndicator.isHidden = true
                    }
                }
            }
        }
    }
}

extension MessageImageUIView {
    func setDetails(_ details: MessageAttachmentDetails) {
        imageId = details.id
        syncStatus = details.syncStatus
        syncError = details.syncError
    }
}
