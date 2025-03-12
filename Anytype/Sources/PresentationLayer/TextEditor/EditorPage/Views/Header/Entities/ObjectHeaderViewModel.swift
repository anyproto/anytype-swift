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
        
        header = buildShimmeringHeader()
    }
    
    // MARK: - Private
    private func setupSubscription() {
        subscription = document.detailsPublisher.receiveOnMain().sink { [weak self] details in
            self?.onUpdate(details: details)
        }
    }

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
        return .filled(
            state: .iconAndCover(
                icon: .init(
                    icon: .init(mode: .image(image), usecase: usecase),
                    layoutAlignment: .left,
                    onTap: {}
                ),
                cover: .init(
                    coverType: .cover(.color(.Shape.tertiary)),
                    onTap: {})
            ),
            isShimmering: true
        )
    }
    
    private func onUpdate(details: ObjectDetails) {
        let header = buildHeader(details: details)
        
        if self.header != header {
            self.header = header
        }
        
        uploadingStatusSubscription = objectHeaderUploadingService
            .coverUploadPublisher(objectId: details.id, spaceId: details.spaceId)
            .receiveOnMain()
            .sink { [weak self] update in
                if let loadingHeader = self?.buildLoadingHeader(update) {
                    self?.header = loadingHeader
                }
            }
    }
    
    private func buildHeader(details: ObjectDetails) -> ObjectHeader {
        guard let details = document.details else {
            return buildShimmeringHeader()
        }
        
        return HeaderBuilder.buildObjectHeader(
            details: details,
            usecase: .openedObject,
            presentationUsecase: configuration.usecase,
            onIconTap: onIconTap,
            onCoverTap: onCoverTap
        )
    }
    
    private func buildLoadingHeader(_ update: ObjectHeaderUpdate) -> ObjectHeader {
        guard let details = document.details else {
            return fakeHeader(update: update)
        }
        
        let header = HeaderBuilder.buildObjectHeader(
            details: details,
            usecase: .openedObject,
            presentationUsecase: configuration.usecase,
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
                    )
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
                        )
                )
            case .remotePreviewURL(let url):
                return ObjectHeader.filled(state:
                        .coverOnly(
                            ObjectHeaderCover(
                                coverType: .preview(.remote(url)),
                                onTap: onCoverTap
                            )
                        )
                )
            }
        }
    }

}
