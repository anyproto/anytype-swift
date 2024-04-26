import UIKit
import Services
import AnytypeCore

protocol ObjectHeaderInteractorProtocol {
    func handleCoverAction(
        spaceId: String,
        action: ObjectCoverPickerAction,
        onCoverUpdate: @escaping (ObjectHeaderUpdate) -> Void
    )
    
    func handleIconAction(spaceId: String, action: ObjectIconPickerAction)
}

final class ObjectHeaderInteractor: ObjectHeaderInteractorProtocol {
    private let detailsService: DetailsServiceProtocol
    private let fileService: FileActionsServiceProtocol
    private let unsplashService: UnsplashServiceProtocol
    
    init(
        detailsService: DetailsServiceProtocol,
        fileService: FileActionsServiceProtocol,
        unsplashService: UnsplashServiceProtocol
    ) {
        self.detailsService = detailsService
        self.fileService = fileService
        self.unsplashService = unsplashService
    }
    
    func handleCoverAction(
        spaceId: String,
        action: ObjectCoverPickerAction,
        onCoverUpdate: @escaping (ObjectHeaderUpdate) -> Void
    ) {
        switch action {
        case .setCover(let coverSource):
            switch coverSource {
            case let .color(colorName):
                AnytypeAnalytics.instance().logEvent(AnalyticsEventsName.setCover)
                Task {
                    try? await detailsService.updateBundledDetails(
                        [.coverType(CoverType.color), .coverId(colorName)]
                    )
                }
            case let .gradient(gradientName):
                AnytypeAnalytics.instance().logEvent(AnalyticsEventsName.setCover)
                Task {
                    try? await detailsService.updateBundledDetails(
                        [.coverType(CoverType.gradient), .coverId(gradientName)]
                    )
                }
            case let .upload(itemProvider):
                let safeSendableItemProvider = SafeSendable(value: itemProvider)
                Task { @MainActor [weak self] in
                    guard let data = try? await self?.fileService.createFileData(source: .itemProvider(safeSendableItemProvider.value)) else {
                        anytypeAssertionFailure("Can't load image from item provider")
                        return
                    }
                    
                    onCoverUpdate(.coverUploading(.bundleImagePath(data.path)))

                    AnytypeAnalytics.instance().logEvent(AnalyticsEventsName.setCover)
                    
                    try await self?.detailsService.setCover(spaceId: spaceId, source: .itemProvider(safeSendableItemProvider.value))
                }
            case let .unsplash(unsplashItem):
                AnytypeAnalytics.instance().logEvent(AnalyticsEventsName.setCover)
                
                onCoverUpdate(.coverUploading(.remotePreviewURL(unsplashItem.url)))
                Task { @MainActor in
                    let imageObjectId = try await unsplashService.downloadImage(spaceId: spaceId, id: unsplashItem.id)
                    try await detailsService.setCover(imageObjectId: imageObjectId)
                }
            }
        case .removeCover:
            AnytypeAnalytics.instance().logEvent(AnalyticsEventsName.removeCover)
            Task {
                try? await detailsService.updateBundledDetails(
                    [.coverType(CoverType.none), .coverId("")]
                )
            }
        }
    }
    
    func handleIconAction(spaceId: String, action: ObjectIconPickerAction) {
        switch action {
        case .setIcon(let iconSource):
            switch iconSource {
            case .emoji(let emojiUnicode):
                AnytypeAnalytics.instance().logEvent(AnalyticsEventsName.setIcon)
                Task {
                    try await detailsService.updateBundledDetails([.iconEmoji(emojiUnicode), .iconObjectId("")])
                }
            case .upload(let itemProvider):
                AnytypeAnalytics.instance().logEvent(AnalyticsEventsName.setIcon)
                let safeSendableItemProvider = SafeSendable(value: itemProvider)
                Task {
                    let data = try await fileService.createFileData(source: .itemProvider(safeSendableItemProvider.value))
                    let fileDetails = try await fileService.uploadFileObject(spaceId: spaceId, data: data, origin: .none)
                    try await detailsService.updateBundledDetails([.iconEmoji(""), .iconObjectId(fileDetails.id)])
                }
            }
        case .removeIcon:
            AnytypeAnalytics.instance().logEvent(AnalyticsEventsName.removeIcon)
            Task {
                try await detailsService.updateBundledDetails(
                    [.iconEmoji(""), .iconObjectId("")]
                )
            }
        }
    }
}
