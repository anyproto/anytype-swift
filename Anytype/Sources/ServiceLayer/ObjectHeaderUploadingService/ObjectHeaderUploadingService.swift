import UIKit
import Services
import AnytypeCore
@preconcurrency import Combine

protocol ObjectHeaderUploadingServiceProtocol: AnyObject, Sendable {
    
    func coverUploadPublisher(objectId: String, spaceId: String) -> AnyPublisher<ObjectHeaderUpdate, Never>
    
    func handleCoverAction(
        objectId: String,
        spaceId: String,
        action: ObjectCoverPickerAction
    ) async throws
    
    func handleIconAction(objectId: String, spaceId: String, action: ObjectIconPickerAction) async throws
}

final class ObjectHeaderUploadingService: ObjectHeaderUploadingServiceProtocol, Sendable {
    
    private let detailsService: any DetailsServiceProtocol = Container.shared.detailsService()
    private let fileService: any FileActionsServiceProtocol = Container.shared.fileActionsService()
    private let unsplashService: any UnsplashServiceProtocol = Container.shared.unsplashService()
    
    private let coverUploadSubject = PassthroughSubject<(objectId: String, spaceId: String, update: ObjectHeaderUpdate), Never>()
    
    func coverUploadPublisher(objectId: String, spaceId: String) -> AnyPublisher<ObjectHeaderUpdate, Never> {
        coverUploadSubject.filter { $0.objectId == objectId && $0.spaceId == spaceId }.map { $0.update }.eraseToAnyPublisher()
    }
    
    func handleCoverAction(
        objectId: String,
        spaceId: String,
        action: ObjectCoverPickerAction
    ) async throws {
        switch action {
        case .setCover(let coverSource):
            switch coverSource {
            case let .color(colorName):
                AnytypeAnalytics.instance().logSetCover()
                try? await detailsService.updateBundledDetails(
                    objectId: objectId,
                    bundledDetails: [.coverType(CoverType.color), .coverId(colorName)]
                )
            case let .gradient(gradientName):
                AnytypeAnalytics.instance().logSetCover()
                try? await detailsService.updateBundledDetails(
                    objectId: objectId,
                    bundledDetails: [.coverType(CoverType.gradient), .coverId(gradientName)]
                )
            case let .upload(itemProvider):
                let safeSendableItemProvider = itemProvider.sendable()
                guard let data = try? await fileService.createFileData(source: .itemProvider(safeSendableItemProvider.value)) else {
                    anytypeAssertionFailure("Can't load image from item provider")
                    return
                }
                
                coverUploadSubject.send((objectId, spaceId, .coverUploading(.bundleImagePath(data.path))))
                
                AnytypeAnalytics.instance().logSetCover()
                
                try await detailsService.setCover(
                    objectId: objectId,
                    spaceId: spaceId,
                    source: .itemProvider(safeSendableItemProvider.value)
                )
            case let .unsplash(unsplashItem):
                AnytypeAnalytics.instance().logSetCover()
                
                coverUploadSubject.send((objectId, spaceId, .coverUploading(.remotePreviewURL(unsplashItem.url))))
                
                let imageObjectId = try await unsplashService.downloadImage(spaceId: spaceId, id: unsplashItem.id)
                try await detailsService.setCover(objectId: objectId, imageObjectId: imageObjectId)
            }
        case .removeCover:
            AnytypeAnalytics.instance().logRemoveCover()
            try? await detailsService.updateBundledDetails(
                objectId: objectId,
                bundledDetails: [.coverType(CoverType.none), .coverId("")]
            )
        }
    }
    
    func handleIconAction(objectId: String, spaceId: String, action: ObjectIconPickerAction) async throws {
        switch action {
        case .setIcon(let iconSource):
            switch iconSource {
            case .emoji(let emojiUnicode):
                AnytypeAnalytics.instance().logSetIcon()
                try await detailsService.updateBundledDetails(
                    objectId: objectId,
                    bundledDetails: [.iconEmoji(emojiUnicode), .iconObjectId("")]
                )
            case .upload(let itemProvider):
                AnytypeAnalytics.instance().logSetIcon()
                let safeSendableItemProvider = itemProvider.sendable()
                let data = try await fileService.createFileData(source: .itemProvider(safeSendableItemProvider.value))
                let fileDetails = try await fileService.uploadFileObject(spaceId: spaceId, data: data, origin: .none)
                try await detailsService.updateBundledDetails(objectId: objectId, bundledDetails: [.iconEmoji(""), .iconObjectId(fileDetails.id)])
            }
        case .removeIcon:
            AnytypeAnalytics.instance().logRemoveIcon()
            try await detailsService.updateBundledDetails(
                objectId: objectId,
                bundledDetails: [.iconEmoji(""), .iconObjectId("")]
            )
        }
    }
}
