import Foundation
import Services
import AnytypeCore
import UIKit


@MainActor
protocol BlockActionHandlerProtocol: AnyObject, Sendable {
    func turnInto(_ style: BlockText.Style, blockId: String, route: AnalyticsEventsRouteKind?) async throws
    @discardableResult
    func turnIntoObject(blockId: String) async throws -> String?
    
    func setTextColor(_ color: BlockColor, blockIds: [String], route: AnalyticsEventsRouteKind?)
    func setBackgroundColor(_ color: BlockBackgroundColor, blockIds: [String], route: AnalyticsEventsRouteKind?)
    func duplicate(blockId: String)
    func fetch(url: AnytypeURL, blockId: String) async throws
    func checkbox(selected: Bool, blockId: String)
    func toggle(blockId: String)
    func setAlignment(_ alignment: LayoutAlignment, blockIds: [String], route: AnalyticsEventsRouteKind?)
    func delete(blockIds: [String])
    func moveToPage(blockIds: [String], pageId: String) async throws
    func createEmptyBlock(parentId: String)
    func addLink(targetDetails: ObjectDetails, blockId: String)
    func changeMarkup(blockIds: [String], markType: MarkupType, route: AnalyticsEventsRouteKind?)
    @discardableResult
    func addBlock(_ type: BlockContentType, blockId: String, blockText: SafeNSAttributedString?, position: BlockPosition?) async throws -> String
    func toggleWholeBlockMarkup(
        _ attributedString: SafeNSAttributedString?,
        markup: MarkupType,
        info: BlockInformation,
        route: AnalyticsEventsRouteKind?
    ) async throws -> SafeNSAttributedString?
    func upload(blockId: String, filePath: String) async throws
    func createPage(targetId: String, spaceId: String, typeUniqueKey: ObjectTypeUniqueKey, templateId: String) async throws -> String?

    func setObjectType(type: ObjectType) async throws
    @discardableResult
    func turnIntoBookmark(url: AnytypeURL) async throws -> ObjectType
    func setObjectSetType() async throws
    func setObjectCollectionType() async throws
    func applyTemplate(objectId: String, templateId: String) async throws
    func changeText(_ text: SafeNSAttributedString, blockId: String) async throws
    func setTextStyle(
        _ attribute: MarkupType,
        range: NSRange,
        blockId: String,
        currentText: SafeNSAttributedString,
        contentType: BlockContentType
    ) async throws -> SafeNSAttributedString
    func uploadMediaFile(uploadingSource: FileUploadingSource, type: MediaPickerContentType, blockId: String, route: UploadMediaRoute)
    func uploadImage(image: UIImage, type: String, blockId: String, route: UploadMediaRoute)
    func uploadFileAt(localPath: String, blockId: String, route: UploadMediaRoute)
    func createAndFetchBookmark(
        targetID: String,
        position: BlockPosition,
        url: AnytypeURL
    ) async throws
    func setAppearance(blockId: String, appearance: BlockLink.Appearance)
    func createTable(
        blockId: String,
        rowsCount: Int,
        columnsCount: Int,
        blockText: SafeNSAttributedString?
    ) async throws -> String
    func pasteContent()
}

extension BlockActionHandlerProtocol {
    @discardableResult
    func addBlock(_ type: BlockContentType, blockId: String, blockText: SafeNSAttributedString? = nil) async throws -> String {
        try await addBlock(type, blockId: blockId, blockText: blockText, position: nil)
    }
    
    func turnInto(_ style: BlockText.Style, blockId: String) async throws {
        try await turnInto(style, blockId: blockId, route: nil)
    }
    
    func setBackgroundColor(_ color: BlockBackgroundColor, blockIds: [String]) {
        setBackgroundColor(color, blockIds: blockIds, route: nil)
    }
    
    func setAlignment(_ alignment: LayoutAlignment, blockIds: [String]) {
        setAlignment(alignment, blockIds: blockIds, route: nil)
    }
    
    func changeMarkup(blockIds: [String], markType: MarkupType) {
        changeMarkup(blockIds: blockIds, markType: markType, route: nil)
    }
    
    func toggleWholeBlockMarkup(
        _ attributedString: SafeNSAttributedString?,
        markup: MarkupType,
        info: BlockInformation
    ) async throws -> SafeNSAttributedString? {
        return try await toggleWholeBlockMarkup(attributedString, markup: markup, info: info, route: nil)
    }
    
    func setTextColor(_ color: BlockColor, blockIds: [String]) {
        setTextColor(color, blockIds: blockIds, route: nil)
    }
}
