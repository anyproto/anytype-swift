import Services
import UIKit
import Combine
import AnytypeCore

protocol ObjectHeaderRouterProtocol: AnyObject {
    func showIconPicker(
        document: BaseDocumentGeneralProtocol,
        onIconAction: @escaping (ObjectIconPickerAction) -> Void
    )
    func showCoverPicker(
        document: BaseDocumentGeneralProtocol,
        onCoverAction: @escaping (ObjectCoverPickerAction) -> Void
    )
}

final class ObjectHeaderViewModel: ObservableObject {
    
    @Published private(set) var header: ObjectHeader?

    // MARK: - Private variables
    
    private lazy var onIconTap = { [weak self] in
        guard let self = self, !self.configuration.isOpenedForPreview else { return }
        guard !document.objectRestrictions.objectRestriction.contains(.details) else { return }
        UISelectionFeedbackGenerator().selectionChanged()
        self.onIconPickerTap?((document, { [weak self] action in
            self?.handleIconAction(action: action)
        }))
    }
    
    private lazy var onCoverTap = { [weak self] in
        guard let self = self, !self.configuration.isOpenedForPreview else { return }
        guard self.document.details?.layoutValue != .note else { return }
        guard !document.objectRestrictions.objectRestriction.contains(.details) else { return }
        UISelectionFeedbackGenerator().selectionChanged()
        self.onCoverPickerTap?((document, { [weak self] action in
            self?.handleCoverAction(action: action)
        }))
    }
    
    private let document: BaseDocumentGeneralProtocol
    private var subscription: AnyCancellable?
    private let configuration: EditorPageViewModelConfiguration
    private let objectHeaderInteractor: ObjectHeaderInteractorProtocol
    
    
    var onCoverPickerTap: RoutingAction<(BaseDocumentGeneralProtocol, (ObjectCoverPickerAction) -> Void)>?
    var onIconPickerTap: RoutingAction<(BaseDocumentGeneralProtocol, (ObjectIconPickerAction) -> Void)>?
    
    // MARK: - Initializers
    
    init(
        document: BaseDocumentGeneralProtocol,
        configuration: EditorPageViewModelConfiguration,
        interactor: ObjectHeaderInteractorProtocol
    ) {
        self.document = document
        self.configuration = configuration
        self.objectHeaderInteractor = interactor
        
        setupSubscription()

        header = buildShimmeringHeader()
    }
    
    // MARK: - Private
    private func setupSubscription() {
        subscription = document.updatePublisher.sink { [weak self] update in
            self?.onUpdate(update)
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
    
    private func onUpdate(_ update: DocumentUpdate) {
        switch update {
        case .details, .general:
            header = buildHeader()
        case .blocks, .dataSourceUpdate, .syncStatus:
            break
        }
    }
    
    private func buildHeader() -> ObjectHeader {
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

extension ObjectHeaderViewModel {
    func handleCoverAction(action: ObjectCoverPickerAction) {
        objectHeaderInteractor.handleCoverAction(spaceId: document.spaceId, action: action) { [weak self] update in
            if let loadingHeader = self?.buildLoadingHeader(update) {
                self?.header = loadingHeader
            }
        }
    }
    
    func handleIconAction(action: ObjectIconPickerAction) {
        objectHeaderInteractor.handleIconAction(spaceId: document.spaceId, action: action)
    }
}
