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
    
    var data: MessageImageViewData? {
        didSet {
            if oldValue != data {
                updateData()
            }
        }
    }
    
    var onTap: ((_ data: MessageImageViewData) -> Void)?
    
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
        
        addTapGesture { [weak self] _ in
            guard let self, let data else { return }
            onTap?(data)
        }
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
    
    private func updateData() {
        uploadingStatusView.syncStatus = data?.syncStatus
        uploadingStatusView.syncError = data?.syncError
        updateImageContentIfNeeded()
    }
    
    private func updateImageContentIfNeeded() {
        guard let imageId = data?.objectId else { return }
        
        let newUrl = ImageMetadata(
            id: imageId,
            side: .width(min(frame.width, frame.height))
        ).contentUrl
        
        guard imageURL != newUrl else { return }
        
        imageURL = newUrl
        imageTask?.cancel()
        imageTask = nil
        imageView.image = nil
        
        guard let newUrl else { return }
        
        if let image = try? cache.cachedImage(from: newUrl) {
            imageView.image = image
            errorIndicator.isHidden = true
            loadingIndicator.isHidden = true
        } else {
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
