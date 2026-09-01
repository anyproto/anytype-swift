import Services
import UIKit
import Combine
import AnytypeCore

@MainActor
protocol ObjectHeaderRouterProtocol: AnyObject {
    func showIconPicker(document: some BaseDocumentProtocol)
}

@MainActor
protocol ObjectHeaderModuleOutput: AnyObject {
    func showCoverPicker(document: some BaseDocumentProtocol)
}

@MainActor
final class ObjectHeaderViewModel: ObservableObject {
    
    @Injected(\.objectHeaderUploadingService)
    private var objectHeaderUploadingService: any ObjectHeaderUploadingServiceProtocol
    
    @Published private(set) var header: ObjectHeader?

    // MARK: - Private variables
    
    private lazy var onIconTap = { [weak self] in
        guard let self, document.mode.isHandling, document.permissions.canChangeIcon else { return }
        UISelectionFeedbackGenerator().selectionChanged()
        self.onIconPickerTap?(document)
    }
    
    private lazy var onCoverTap = { [weak self] in
        guard let self, document.mode.isHandling else { return }
        guard document.details?.resolvedLayoutValue != .note else { return }
        guard document.permissions.canChangeCover else { return }
        UISelectionFeedbackGenerator().selectionChanged()
        output?.showCoverPicker(document: document)
    }
    
    private let document: any BaseDocumentProtocol
    private let targetObjectId: String
    private var subscription: AnyCancellable?
    private var uploadingStatusSubscription: AnyCancellable?
    private let configuration: EditorPageViewModelConfiguration
    private weak var output: (any ObjectHeaderModuleOutput)?
    
    private var showPublishingBanner: Bool = false
    
    var onIconPickerTap: RoutingAction<any BaseDocumentProtocol>?
    
    // MARK: - Initializers
    
    init(
        document: some BaseDocumentProtocol,
        targetObjectId: String,
        configuration: EditorPageViewModelConfiguration,
        output: (any ObjectHeaderModuleOutput)?
    ) {
        self.document = document
        self.targetObjectId = targetObjectId
        self.configuration = configuration
        self.output = output
        
        setupSubscription()

        // Details already loaded (reopened document) - skip the placeholder
        if let details = document.details {
            header = buildHeader(details: details, showPublishingBanner: showPublishingBanner)
        } else {
            header = buildShimmeringHeader()
        }
    }
    
    func updatePublishingBannerVisibility(_ isVisible: Bool) {
        showPublishingBanner = isVisible
        onUpdate(details: document.details, showPublishingBanner: isVisible)
    }
    
    // MARK: - Private
    private func setupSubscription() {
        subscription = document.detailsPublisher.receiveOnMain().sink { [weak self] details in
            guard let self else { return }
            
            onUpdate(details: details, showPublishingBanner: showPublishingBanner)
        }
    }

    // Sized to the layout the real header will have (when the opening flow knew
    // the details) - a placeholder of a different height visibly collapses once
    // data arrives, because the editor never compensates the reflow
    func buildShimmeringHeader() -> ObjectHeader {
        let usecase = ObjectIconImageUsecase.openedObject
        let imageSize = usecase.objectIconImageGuidelineSet.emojiImageGuideline?.size ?? .zero
        let image = UIImage.image(
            imageSize: imageSize,
            cornerRadius: 0,
            side: imageSize.height,
            foregroundColor: nil,
            backgroundColor: .Shape.tertiary
        )
        let shimmerIcon = ObjectHeaderIcon(
            icon: .init(mode: .image(image), usecase: usecase),
            layoutAlignment: .left,
            onTap: {}
        )
        let shimmerCover = ObjectHeaderCover(
            coverType: .cover(.color(.Shape.tertiary)),
            onTap: {}
        )

        switch configuration.headerHint {
        case .iconOnly:
            return .filled(
                state: .iconOnly(ObjectHeaderIconOnlyState(icon: shimmerIcon, onCoverTap: {})),
                showPublishingBanner: showPublishingBanner,
                isShimmering: true
            )
        case .coverOnly:
            return .filled(
                state: .coverOnly(shimmerCover),
                showPublishingBanner: showPublishingBanner,
                isShimmering: true
            )
        case .empty:
            return .empty(
                data: ObjectHeaderEmptyData(presentationStyle: configuration.usecase),
                showPublishingBanner: showPublishingBanner,
                isShimmering: true
            )
        case .iconAndCover, nil:
            return .filled(
                state: .iconAndCover(icon: shimmerIcon, cover: shimmerCover),
                showPublishingBanner: showPublishingBanner,
                isShimmering: true
            )
        }
    }
    
    private func onUpdate(details: ObjectDetails?, showPublishingBanner: Bool) {
        guard let details else { return }
        
        let header = buildHeader(details: details, showPublishingBanner: showPublishingBanner)

        if self.header != header {
            self.header = header
        }
        
        uploadingStatusSubscription = objectHeaderUploadingService
            .coverUploadPublisher(objectId: details.id, spaceId: details.spaceId)
            .receiveOnMain()
            .sink { [weak self] update in
                if let loadingHeader = self?.buildLoadingHeader(
                    update, showPublishingBanner: showPublishingBanner
                ) {
                    self?.header = loadingHeader
                }
            }
    }
    
    private func buildHeader(details: ObjectDetails, showPublishingBanner: Bool) -> ObjectHeader {
        guard let details = document.details else {
            return buildShimmeringHeader()
        }
        
        return HeaderBuilder.buildObjectHeader(
            details: details,
            usecase: .openedObject,
            presentationUsecase: configuration.usecase,
            showPublishingBanner: showPublishingBanner,
            onIconTap: onIconTap,
            onCoverTap: onCoverTap
        )
    }
    
    private func buildLoadingHeader(_ update: ObjectHeaderUpdate, showPublishingBanner: Bool) -> ObjectHeader {
        guard let details = document.details else {
            return fakeHeader(update: update)
        }
        
        let header = HeaderBuilder.buildObjectHeader(
            details: details,
            usecase: .openedObject,
            presentationUsecase: configuration.usecase,
            showPublishingBanner: showPublishingBanner,
            onIconTap: onIconTap,
            onCoverTap: onCoverTap
        )
        return header.modifiedByUpdate(
            update,
            onIconTap: onIconTap,
            onCoverTap: onCoverTap
        )
    }
    
    private func fakeHeader(update: ObjectHeaderUpdate) -> ObjectHeader {
        switch update {
        case .iconUploading(let path):
            return ObjectHeader.filled(state:
                    .iconOnly(
                        ObjectHeaderIconOnlyState(
                            icon: ObjectHeaderIcon(
                                icon: .init(mode: .basicPreview(UIImage(contentsOfFile: path)), usecase: .openedObject),
                                layoutAlignment: .left,
                                onTap: onIconTap
                            ),
                            onCoverTap: onCoverTap
                        )
                    ), showPublishingBanner: showPublishingBanner
            )
        case .coverUploading(let coverUpdate):
            switch coverUpdate {
            case .bundleImagePath(let string):
                return ObjectHeader.filled(state:
                        .coverOnly(
                            ObjectHeaderCover(
                                coverType: .preview(.image(UIImage(contentsOfFile: string))),
                                onTap: onCoverTap
                            )
                        ), showPublishingBanner: showPublishingBanner
                )
            case .remotePreviewURL(let url):
                return ObjectHeader.filled(state:
                        .coverOnly(
                            ObjectHeaderCover(
                                coverType: .preview(.remote(url)),
                                onTap: onCoverTap
                            )
                        ), showPublishingBanner: showPublishingBanner
                )
            }
        }
    }

}
