import SwiftUI
import SharedContentManager
import Services
import AnytypeCore
import Factory

protocol SharingExtensionActionServiceProtocol: AnyObject, Sendable {
    func saveObjects(
        spaceId: String,
        content: SharedContent
    ) async
}

actor SharingExtensionActionService: SharingExtensionActionServiceProtocol {
    
    @Injected(\.bookmarkService)
    private var bookmarkService: any BookmarkServiceProtocol
    @Injected(\.fileActionsService)
    private var fileService: any FileActionsServiceProtocol
    @Injected(\.objectTypeProvider)
    private var objectTypeProvider: any ObjectTypeProviderProtocol
    @Injected(\.objectActionsService)
    private var objectActionsService: any ObjectActionsServiceProtocol
    
    func saveObjects(
        spaceId: String,
        content: SharedContent
    ) async {
        await objectTypeProvider.prepareData(spaceId: spaceId)
        
        let textItems = content.items.filter { $0.isText }
        if content.title?.isNotEmpty ?? false || textItems.isNotEmpty {
            // Create Note object and link it
        } else {
            // Create objects and link it
        }
    }
    
    // MARK: - Private
    
    private func createContainer(
        spaceId: String,
        title: String?
    ) async throws {
        
        let noteObject = try await objectActionsService.createObject(
            name: title ?? "",
            typeUniqueKey: .note,
            shouldDeleteEmptyObject: false,
            shouldSelectType: false,
            shouldSelectTemplate: false,
            spaceId: spaceId,
            origin: .sharingExtension,
            templateId: nil
        )
        
        AnytypeAnalytics.instance().logCreateObject(objectType: noteObject.objectType.analyticsType, spaceId: noteObject.spaceId, route: .sharingExtension)
    }
    
    private func createObjectFromSharedContent(
        spaceId: String,
        linkToObject: ObjectDetails?,
        content: SharedContent
    ) async throws -> [BlockInformation] {
        var blockInformations = [BlockInformation]()
        
        for contentItem in content.items {
            let newObjectId: String
            switch contentItem {
            case let .text(text):
                break
            case let .url(url):
                newObjectId = try await createBookmarkObject(url: AnytypeURL(url: url), spaceId: spaceId).id
                let blockInformation = BlockInformation.bookmark(targetId: newObjectId)
                blockInformations.append(blockInformation)
            case let .file(url):
                newObjectId = try await createFileObject(url: url, spaceId: spaceId).id
                let blockInformation = BlockInformation.emptyLink(targetId: newObjectId)
                blockInformations.append(blockInformation)
            }
        }
        
        return blockInformations
    }
    
    
    private func createBookmarkObject(url: AnytypeURL, spaceId: String) async throws -> ObjectDetails {
        let type = try? objectTypeProvider.objectType(uniqueKey: ObjectTypeUniqueKey.bookmark, spaceId: spaceId)
        
        let newBookmark = try await bookmarkService.createBookmarkObject(
            spaceId: spaceId,
            url: url,
            templateId: type?.defaultTemplateId,
            origin: .sharingExtension
        )
        try await bookmarkService.fetchBookmarkContent(bookmarkId: newBookmark.id, url: url)
        
        AnytypeAnalytics.instance().logCreateObject(
            objectType: newBookmark.objectType.analyticsType,
            spaceId: newBookmark.spaceId,
            route: .sharingExtension
        )
        return newBookmark
    }
    
    private func createFileObject(url: URL, spaceId: String) async throws -> FileDetails {
        let resources = try url.resourceValues(forKeys: [.fileSizeKey])
        let data = FileData(path: url.relativePath, type: .data, sizeInBytes: resources.fileSize, isTemporary: false)
        let details = try await fileService.uploadFileObject(spaceId: spaceId, data: data, origin: .sharingExtension)
        
        AnytypeAnalytics.instance().logCreateObject(
            objectType: details.analyticsType,
            spaceId: details.spaceId,
            route: .sharingExtension
        )
        return details
    }
}
