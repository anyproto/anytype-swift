import Foundation
import Testing
import Services
import AnytypeCore
@testable import Anytype

struct QuickCaptureDraftTests {
    @Test func untouchedRestoredDraftNavigatesWithoutPrompt() {
        for targetHasContent in [false, true] {
            #expect(QuickCaptureSpaceSwitch.action(
                hasContent: true, hasLocalEdits: false, targetHasContent: targetHasContent
            ) == .openTarget)
        }
    }

    @Test func clearedDraftNavigatesEvenAfterEditing() {
        #expect(QuickCaptureSpaceSwitch.action(
            hasContent: false, hasLocalEdits: true, targetHasContent: true
        ) == .openTarget)
    }

    @Test func editedTextMovesUnlessDestinationHoldsContent() {
        #expect(QuickCaptureSpaceSwitch.action(
            hasContent: true, hasLocalEdits: true, targetHasContent: false
        ) == .move)
        #expect(QuickCaptureSpaceSwitch.action(
            hasContent: true, hasLocalEdits: true, targetHasContent: true
        ) == .confirm)
    }

    @Test func explicitPublishedFlagWinsOverHidden() {
        let details = hiddenDraft().updated(by: [QuickCaptureDraft.relationKey: false.protobufValue])
        #expect(!QuickCaptureDraft.isDraft(details, participantId: "me"))
    }

    @Test func legacyHiddenDraftSurvivesMissingFlagAndCreator() {
        #expect(QuickCaptureDraft.isDraft(hiddenDraft(), participantId: "me"))
        #expect(QuickCaptureDraft.isDraft(hiddenDraft(), participantId: nil))
        #expect(QuickCaptureDraft.isDraft(hiddenDraft().updated(by: [QuickCaptureDraft.relationKey: .init()]), participantId: nil))
    }

    @Test func legacyMigrationIncludesNullButNotExplicitFlags() {
        #expect(QuickCaptureDraft.needsMigration(hiddenDraft()))
        #expect(QuickCaptureDraft.needsMigration(hiddenDraft().updated(by: [QuickCaptureDraft.relationKey: .with { $0.nullValue = .nullValue }])))
        for flag in [true, false] {
            #expect(!QuickCaptureDraft.needsMigration(hiddenDraft().updated(by: [QuickCaptureDraft.relationKey: flag.protobufValue])))
        }
    }

    @Test func knownForeignCreatorIsRejectedButUnknownParticipantDoesNotHideDraft() {
        let details = hiddenDraft().updated(by: [BundledPropertyKey.creator.rawValue: "someone-else".protobufValue])
        #expect(!QuickCaptureDraft.isDraft(details, participantId: "me"))
        #expect(QuickCaptureDraft.isDraft(details, participantId: nil))
    }

    @Test func deletedAndArchivedObjectsAreNeverDrafts() {
        for key in [BundledPropertyKey.isDeleted, .isArchived] {
            let details = hiddenDraft().updated(by: [key.rawValue: true.protobufValue, QuickCaptureDraft.relationKey: true.protobufValue])
            #expect(!QuickCaptureDraft.isDraft(details, participantId: nil))
        }
    }

    @Test func discoveryRequestsEveryConsumedFieldAndEveryParticipant() throws {
        let request = QuickCaptureDraft.discoveryRequest(participantIds: ["me-space-a", "me-space-b"], localDraftIds: ["legacy"])
        let union = try #require(request.filters.first)
        #expect(union.operator == .or)
        let owned = try #require(union.nestedFilters.first)
        #expect(owned.operator == .and)
        let creators = try #require(owned.nestedFilters.first { $0.relationKey == BundledPropertyKey.creator.rawValue })
        #expect(creators.condition == .in)
        #expect(creators.value.listValue.values.map(\.stringValue) == ["me-space-a", "me-space-b"])
        #expect(union.nestedFilters.last?.relationKey == BundledPropertyKey.id.rawValue)
        for key in ["id", "spaceId", "name", "description", "snippet", "creator", "createdDate", "isDraft", "isHidden", "isDeleted", "isArchived"] {
            #expect(request.keys.contains(key))
        }
        #expect(request.sorts.first?.relationKey == "createdDate")
        #expect(request.sorts.first?.type == .desc)
    }

    @Test func partialDiscoveryRetainsKnownDraftsWithoutClaimingAbsence() {
        let discovery = QuickCaptureDraftDiscovery(drafts: [hiddenDraft()], isComplete: false)
        #expect(discovery.newestDraft(spaceId: "space-a")?.id == "draft")
        #expect(discovery.newestDraft(spaceId: "space-b") == nil)
        #expect(!discovery.isComplete)
    }

    @Test func bodyOnlyAndAttachmentOnlyDraftsAreNotEmpty() {
        #expect(content([text("body", "Unsent text")]).hasContent)
        #expect(content([image("image")]).hasContent)
        #expect(!content([text("empty", "")]).hasContent)
    }

    @Test func fullyEmptyDraftCanBeCleanedUpWithOrWithoutPlaceholderBlocks() {
        #expect(!content([]).hasContent)
        #expect(!content([
            .empty(id: "title", content: .text(.plain("", contentType: .title))),
            text("empty-one", ""), text("empty-two", "")
        ]).hasContent)
    }

    @Test func titleOrDescriptionAlonePreventsEmptyDraftCleanup() {
        for key in [BundledPropertyKey.name, .description] {
            let details = hiddenDraft().updated(by: [key.rawValue: "Unsent text".protobufValue])
            #expect(QuickCaptureDraftContent(details: details, blocks: [text("empty", "")]).hasContent)
        }
    }

    @Test func headerTextSurvivesEvenWhenDetailsHaveNotCaughtUp() {
        for style in [BlockText.Style.title, .description] {
            #expect(content([.empty(id: "header", content: .text(.plain("Unsent text", contentType: style)))]).hasContent)
        }
    }

    @Test func nestedAndUnsupportedBlocksPreventCleanup() {
        #expect(content([
            .empty(id: "layout", content: .layout(.init(style: .header))),
            text("nested", "Unsent text")
        ]).hasContent)
        #expect(content([.empty(id: "unknown", content: .unsupported)]).hasContent)
    }

    @Test func whitespaceIsPreservedInsteadOfBeingTreatedAsFullyEmpty() {
        #expect(content([text("body", " \n")]).hasContent)
        let details = hiddenDraft().updated(by: [BundledPropertyKey.name.rawValue: " ".protobufValue])
        #expect(QuickCaptureDraftContent(details: details, blocks: []).hasContent)
    }

    @Test func textLandingDoesNotProveAttachmentWasCopied() {
        let source = content([text("body", "A note"), image("image")])
        #expect(!content([text("copied-body", "A note")]).contains(source))
        #expect(content([text("copied-body", "A note"), image("copied-image")]).contains(source))
    }

    @Test func copyVerificationChecksAllTextAndRepeatedAttachments() {
        let source = content([text("body", "A note"), text("cell", "Table content"), image("one"), image("two")])
        #expect(!content([text("copy", "A note"), image("image")]).contains(source))
        #expect(!content([text("copy", "A note"), text("cell-copy", "Table content"), image("one")]).contains(source))
    }

    private func hiddenDraft() -> ObjectDetails {
        ObjectDetails(id: "draft", values: [
            BundledPropertyKey.isHidden.rawValue: true.protobufValue,
            BundledPropertyKey.spaceId.rawValue: "space-a".protobufValue
        ])
    }

    private func content(_ blocks: [BlockInformation]) -> QuickCaptureDraftContent {
        QuickCaptureDraftContent(details: hiddenDraft(), blocks: blocks)
    }

    private func text(_ id: String, _ value: String) -> BlockInformation {
        .empty(id: id, content: .text(.plain(value, contentType: .text)))
    }

    private func image(_ id: String) -> BlockInformation {
        .empty(id: id, content: .file(.empty(contentType: .image)))
    }
}
