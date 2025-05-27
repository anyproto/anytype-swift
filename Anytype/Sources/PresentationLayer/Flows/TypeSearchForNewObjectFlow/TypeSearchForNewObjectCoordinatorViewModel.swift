import Foundation
import Services
import SwiftUI
import AnytypeCore


@MainActor
final class TypeSearchForNewObjectCoordinatorViewModel: ObservableObject {
    @Published var shouldDismiss = false
    
    @Injected(\.pasteboardBlockService)
    private var pasteboardBlockService: any PasteboardBlockServiceProtocol
    @Injected(\.objectActionsService)
    private var objectActionsService: any ObjectActionsServiceProtocol
    @Injected(\.blockService)
    private var blockService: any BlockServiceProtocol
    @Injected(\.bookmarkService)
    private var bookmarkService: any BookmarkServiceProtocol
    @Injected(\.objectTypeProvider)
    private var typeProvider: any ObjectTypeProviderProtocol
    
    private let spaceId: String
    private let openObject: (ObjectDetails)->()
    
    init(spaceId: String, openObject: @escaping (ObjectDetails)->()) {
        self.spaceId = spaceId
        self.openObject = openObject
    }
    
    func typeSearchModule() -> ObjectTypeSearchView {
        ObjectTypeSearchView(
            title: Loc.createNewObject,
            spaceId: spaceId,
            settings: .newObjectCreation
        ) { [weak self] result in
            guard let self else { return }
            shouldDismiss = true
            
            switch result {
            case .objectType(let type):
                createAndShowNewObject(type: type, pasteContent: false)
            case .createFromPasteboard:
                switch pasteboardBlockService.pasteboardContent {
                case .none:
                    anytypeAssertionFailure("No content in Pasteboard")
                    break
                case .url(let url):
                    createAndShowNewBookmark(url: url)
                case .string:
                    fallthrough
                case .otherContent:
                    guard let type = try? typeProvider.defaultObjectType(spaceId: spaceId) else {
                        return
                    }
                    
                    createAndShowNewObject(type: type, pasteContent: true)
                }
            }
        }
    }
    
    private func createAndShowNewBookmark(url: AnytypeURL) {
        Task {
            let type = try? typeProvider.objectType(uniqueKey: ObjectTypeUniqueKey.bookmark, spaceId: spaceId)
            
            let details = try await bookmarkService.createBookmarkObject(
                spaceId: spaceId,
                url: url,
                templateId: type?.defaultTemplateId,
                origin: .clipboard
            )
            
            AnytypeAnalytics.instance().logSelectObjectType(details.analyticsType, route: .clipboard)
            AnytypeAnalytics.instance().logCreateObject(objectType: details.analyticsType, spaceId: details.spaceId, route: .clipboard)

            openObject(details)
        }
    }
    
    
    private func createAndShowNewObject(
        type: ObjectType,
        pasteContent: Bool
    ) {
        Task {
            let details = try await objectActionsService.createObject(
                name: "",
                typeUniqueKey: type.uniqueKey,
                shouldDeleteEmptyObject: true,
                shouldSelectType: false,
                shouldSelectTemplate: true,
                spaceId: spaceId,
                origin: .none,
                templateId: type.defaultTemplateId
            )
            
            AnytypeAnalytics.instance().logSelectObjectType(type.analyticsType, route: pasteContent ? .clipboard : .longTap)
            AnytypeAnalytics.instance().logCreateObject(objectType: details.analyticsType, spaceId: details.spaceId, route: pasteContent ? .clipboard : .navigation)
            
            if pasteContent && !type.isListType {
                try await objectActionsService.applyTemplate(objectId: details.id, templateId: type.defaultTemplateId)
                let blockId = try await blockService.addFirstBlock(contextId: details.id, info: .emptyText)
                
                pasteboardBlockService.pasteInsideBlock(
                    objectId: details.id,
                    spaceId: details.spaceId,
                    focusedBlockId: blockId,
                    range: .zero,
                    handleLongOperation: { },
                    completion: { _ in }
                )
            }

            openObject(details)
        }
    }
}
