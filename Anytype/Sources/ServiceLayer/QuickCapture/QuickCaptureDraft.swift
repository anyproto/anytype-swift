import Foundation
import Services
import AnytypeCore

enum QuickCaptureDraft {
    // GO-7499; not yet present in the bundled middleware's generated property keys.
    static let relationKey = "isDraft"

    static let keys = (BundledPropertyKey.objectListKeys + [
        .id, .spaceId, .name, .description, .snippet, .creator, .createdDate,
        .isHidden, .isDeleted, .isArchived, .internalFlags, .coverId, .coverType
    ]).uniqued().map(\.rawValue) + [relationKey]

    static func isDraft(_ details: ObjectDetails, participantId: String?) -> Bool {
        guard !details.isDeleted, !details.isArchived else { return false }
        if let participantId, participantId.isNotEmpty, details.creator.isNotEmpty,
           details.creator != participantId { return false }
        // Explicit false always wins, including a published object still marked hidden.
        if let kind = details.values[relationKey]?.kind {
            switch kind {
            case .boolValue(let value): return value
            case .nullValue: return details.isHidden
            default: return false
            }
        }
        return details.isHidden
    }

    static func needsMigration(_ details: ObjectDetails) -> Bool {
        guard let kind = details.values[relationKey]?.kind else { return true }
        if case .nullValue = kind { return true }
        return false
    }

    static func discoveryRequest(participantIds: [String], localDraftIds: [String] = [], offset: Int = 0) -> CrossSpaceSearchRequest {
        var draftFilter = DataviewFilter()
        draftFilter.relationKey = relationKey
        draftFilter.condition = .equal
        draftFilter.value = true
        var ownedDrafts = DataviewFilter()
        ownedDrafts.operator = .and
        ownedDrafts.nestedFilters = [draftFilter, SearchHelper.creatorsFilter(participantIds)]
        var discoverable = DataviewFilter()
        discoverable.operator = .or
        // Legacy local pointers may have no creator; validate ownership on the result.
        discoverable.nestedFilters = [ownedDrafts]
        if localDraftIds.isNotEmpty { discoverable.nestedFilters.append(SearchHelper.includeIdsFilter(localDraftIds)) }
        return CrossSpaceSearchRequest(
            filters: [discoverable,
                      SearchHelper.isDeletedFilter(isDeleted: false), SearchHelper.isArchivedFilter(isArchived: false)],
            sorts: [SearchHelper.sort(relation: .createdDate, type: .desc)],
            fullText: "",
            keys: keys,
            offset: offset,
            limit: 100
        )
    }
}

struct QuickCaptureDraftDiscovery: Sendable {
    let drafts: [ObjectDetails]
    let isComplete: Bool

    func newestDraft(spaceId: String) -> ObjectDetails? {
        drafts.first { $0.spaceId == spaceId }
    }

    var spaceIds: Set<String> { Set(drafts.map(\.spaceId)) }
}

enum QuickCaptureSpaceSwitch: Equatable {
    case openTarget
    case move
    case confirm

    static func action(hasContent: Bool, hasLocalEdits: Bool, targetHasContent: Bool) -> Self {
        guard hasContent, hasLocalEdits else { return .openTarget }
        return targetHasContent ? .confirm : .move
    }
}

struct QuickCaptureDraftContent: Equatable {
    let name: String
    let description: String
    let blocks: [BlockInformation]
    let copyableBlocks: [BlockInformation]
    let hasContent: Bool

    init(details: ObjectDetails, blocks: [BlockInformation]) {
        name = details.name
        description = details.description
        hasContent = details.name.isNotEmpty || details.description.isNotEmpty || blocks.contains { info in
            switch info.content {
            case .smartblock, .layout, .tableRow, .tableColumn, .featuredRelations, .relation:
                return false
            case .text(let text):
                return text.text.isNotEmpty
            default:
                return true
            }
        }
        self.blocks = blocks.filter { info in
            guard info.kind == .block else { return false }
            switch info.content {
            case .featuredRelations: return false
            case .text(let text): return text.contentType != .title && text.contentType != .description
            default: return true
            }
        }
        // The copy RPC expands a table itself. Selecting its cells again duplicates them.
        let tableCellIds = Set(blocks.flatMap { info -> [String] in
            switch info.content {
            case .tableRow, .tableColumn: return info.childrenIds
            default: return []
            }
        })
        copyableBlocks = self.blocks.filter { !tableCellIds.contains($0.id) }
    }

    // Compare all text, including table cells, and counts of each non-text block type.
    // Block ids, parent ids and attachment object ids can change during cross-space paste.
    func contains(_ source: Self) -> Bool {
        guard name == source.name, description == source.description else { return false }
        var remaining = blocks
        for block in source.blocks {
            if case .text(let text) = block.content, text.text.isEmpty { continue }
            guard let index = remaining.firstIndex(where: { candidate in
                guard candidate.content.type == block.content.type else { return false }
                if case .text(let text) = block.content {
                    return candidate.textContent?.text == text.text
                }
                return true
            }) else { return false }
            remaining.remove(at: index)
        }
        return true
    }
}
