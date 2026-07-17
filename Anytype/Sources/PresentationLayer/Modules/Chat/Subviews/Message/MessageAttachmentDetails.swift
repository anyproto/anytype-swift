import SwiftUI
import Services

struct MessageAttachmentDetails: Equatable, Identifiable, Hashable {
    let id: String
    let title: String
    let description: String
    let sizeInBytes: Int?
    let resolvedLayoutValue: DetailsLayout
    let objectIconImage: Icon
    let source: String?
    let syncStatus: SyncStatus?
    let syncError: SyncError?
    let downloadingState: Bool
    let uploadTimeMs: Int?
}

extension MessageAttachmentDetails {
    init(details: ObjectDetails) {
        let source = details.source?.url.host() ?? details.source?.absoluteString

        var uploadTimeMs: Int? = nil
        if let addedDate = details.addedDate, let syncDate = details.syncDate, syncDate > addedDate {
            uploadTimeMs = Int(syncDate.timeIntervalSince(addedDate) * 1000)
        }

        self = MessageAttachmentDetails(
            id: details.id,
            title: details.title,
            description: details.objectType.displayName,
            sizeInBytes: details.sizeInBytes,
            resolvedLayoutValue: details.resolvedLayoutValue,
            objectIconImage: details.objectIconImage,
            source: source,
            syncStatus: details.syncStatusValue,
            syncError: details.syncErrorValue,
            downloadingState: false,
            uploadTimeMs: uploadTimeMs
        )
    }
    
    init(fileDetails: FileDetails) {
        let resolvedLayoutValue: DetailsLayout = switch fileDetails.fileContentType {
        case .file: .file
        case .image: .image
        case .video: .video
        case .audio: .audio
        case .none: .basic
        }
        self = MessageAttachmentDetails(
            id: fileDetails.id,
            title: fileDetails.fileName,
            description: "",
            sizeInBytes: fileDetails.sizeInBytes,
            resolvedLayoutValue: resolvedLayoutValue,
            objectIconImage: .object(.file(mimeType: fileDetails.fileMimeType, name: fileDetails.name)),
            source: nil,
            syncStatus: nil,
            syncError: nil,
            downloadingState: false,
            uploadTimeMs: nil
        )
    }

    static func placeholder(tagetId: String) -> Self {
        MessageAttachmentDetails(
            id: tagetId,
            title: "Placeholder",
            description: "Placeholder",
            sizeInBytes: nil,
            resolvedLayoutValue: .basic,
            objectIconImage: .object(.defaultObjectIcon),
            source: nil,
            syncStatus: nil,
            syncError: nil,
            downloadingState: true,
            uploadTimeMs: nil
        )
    }
}
