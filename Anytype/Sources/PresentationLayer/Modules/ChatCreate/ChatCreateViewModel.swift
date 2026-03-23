import Foundation
import Services
import UIKit
import AnytypeCore
import DesignKit

@MainActor
@Observable
final class ChatCreateViewModel {

    // MARK: - DI

    let data: ChatCreateScreenData

    @ObservationIgnored
    @Injected(\.objectActionsService)
    private var objectActionsService: any ObjectActionsServiceProtocol
    @ObservationIgnored
    @Injected(\.fileActionsService)
    private var fileActionsService: any FileActionsServiceProtocol
    @ObservationIgnored
    @Injected(\.detailsService)
    private var detailsService: any DetailsServiceProtocol
    @ObservationIgnored
    @Injected(\.objectTypeProvider)
    private var objectTypeProvider: any ObjectTypeProviderProtocol
    @ObservationIgnored
    @Injected(\.blockService)
    private var blockService: any BlockServiceProtocol

    // MARK: - State

    var chatName = ""
    var chatIcon: Icon = .object(.deleted)
    var createLoadingState = false
    var dismiss: Bool = false
    var iconPickerData: ChatIconPickerData?
    var toastBarData: ToastBarData?

    @ObservationIgnored
    var pageNavigation: PageNavigation?
    @ObservationIgnored
    private var iconState: ChatIconState

    init(data: ChatCreateScreenData) {
        self.data = data
        if case .edit(_, let currentName, let currentIcon) = data.mode {
            self.chatName = currentName
            self.iconState = .unchanged(originalIcon: currentIcon)
        } else {
            self.iconState = .unchanged(originalIcon: nil)
        }
    }

    func onTapSave() {
        guard !createLoadingState else { return }
        createLoadingState = true

        Task {
            defer { createLoadingState = false }

            switch data.mode {
            case .create:
                await handleCreate()
            case .edit(let objectId, _, _):
                await handleEdit(objectId: objectId)
            }
        }
    }

    private func handleCreate() async {
        let details: ObjectDetails
        do {
            details = try await objectActionsService.createObject(
                name: chatName,
                typeUniqueKey: .chatDerived,
                shouldDeleteEmptyObject: false,
                shouldSelectType: false,
                shouldSelectTemplate: false,
                spaceId: data.spaceId,
                origin: .none,
                templateId: nil,
                createdInContext: data.collectionId ?? "",
                createdInContextRef: ""
            )
        } catch {
            toastBarData = ToastBarData(error.localizedDescription, type: .failure)
            return
        }

        try? await saveIcon(to: details.id)

        if let collectionId = data.collectionId {
            try? await objectActionsService.addObjectsToCollection(
                contextId: collectionId,
                objectIds: [details.id]
            )
        }

        // Insert link block in parent document (for slash menu)
        if let linkDocumentId = data.linkDocumentId,
           let linkTargetBlockId = data.linkTargetBlockId {
            let linkInfo = BlockInformation.emptyLink(targetId: details.id)
            _ = try? await blockService.add(
                contextId: linkDocumentId,
                targetId: linkTargetBlockId,
                info: linkInfo,
                position: .replace
            )
            AnytypeAnalytics.instance().logCreateLink(objectType: details.analyticsType, route: data.analyticsRoute)
        }

        UINotificationFeedbackGenerator().notificationOccurred(.success)
        AnytypeAnalytics.instance().logCreateObject(objectType: details.analyticsType, spaceId: details.spaceId, route: data.analyticsRoute)

        dismiss = true
        pageNavigation?.open(details.screenData())
    }

    private func handleEdit(objectId: String) async {
        do {
            try await detailsService.updateBundledDetails(
                objectId: objectId,
                bundledDetails: [.name(chatName)]
            )
            try await saveIcon(to: objectId)

            UINotificationFeedbackGenerator().notificationOccurred(.success)
            dismiss = true
        } catch {
            toastBarData = ToastBarData(error.localizedDescription, type: .failure)
        }
    }

    func onAppear() {
        updateChatIcon()
        AnytypeAnalytics.instance().logScreenChatInfo()
    }

    func onIconTapped() {
        let currentSelection: ChatIconSelection? = if case .selected(let selection) = iconState { selection } else { nil }

        // Extract original icon only if unchanged
        let originalObjectIcon: ObjectIcon?
        if case .unchanged(let originalIcon) = iconState,
           case .object(let objIcon) = originalIcon {
            originalObjectIcon = objIcon
        } else {
            originalObjectIcon = nil  // removed or create mode
        }

        iconPickerData = ChatIconPickerData(
            iconSelection: currentSelection,
            originalObjectIcon: originalObjectIcon
        )
    }

    // MARK: - Icon Picker Callbacks

    func onSelectEmoji(_ emoji: EmojiData) {
        iconState = .selected(.emoji(emoji))
        updateChatIcon()
    }

    func onSelectItemProvider(_ itemProvider: NSItemProvider) {
        Task {
            guard let fileData = try? await fileActionsService.createFileData(source: .itemProvider(itemProvider)) else { return }
            iconState = .selected(.file(fileData))
            updateChatIcon()
        }
    }

    func onRemoveIcon() {
        iconState = .removed
        updateChatIcon()
    }

    // MARK: - Private

    private func saveIcon(to objectId: String) async throws {
        switch iconState {
        case .unchanged:
            break
        case .selected(.emoji(let emojiData)):
            try await detailsService.updateBundledDetails(
                objectId: objectId,
                bundledDetails: BundledDetails.iconDetails(iconEmoji: emojiData.emoji)
            )
        case .selected(.file(let fileData)):
            let fileDetails = try await fileActionsService.uploadFileObject(
                spaceId: data.spaceId,
                data: fileData,
                origin: .none,
                createdInContext: objectId,
                createdInContextRef: BundledPropertyKey.iconImage.rawValue
            )
            try await detailsService.updateBundledDetails(
                objectId: objectId,
                bundledDetails: BundledDetails.iconDetails(objectId: fileDetails.id)
            )
        case .removed:
            try await detailsService.updateBundledDetails(
                objectId: objectId,
                bundledDetails: BundledDetails.iconDetails()
            )
        }
    }

    private func updateChatIcon() {
        switch iconState {
        case .selected(.emoji(let emojiData)):
            chatIcon = .object(.emoji(Emoji(emojiData.emoji) ?? .lamp, circular: true))
        case .selected(.file(let fileData)):
            chatIcon = .object(.space(.localPath(fileData.path, circular: true)))
        case .unchanged(let originalIcon):
            chatIcon = originalIcon ?? defaultChatTypeIcon
        case .removed:
            chatIcon = defaultChatTypeIcon
        }
    }

    private var defaultChatTypeIcon: Icon {
        if let chatType = try? objectTypeProvider.objectType(uniqueKey: .chatDerived, spaceId: data.spaceId),
           case .customIcon(let iconData) = chatType.icon {
            let circularData = CustomIconData(icon: iconData.icon, color: iconData.color, circular: true)
            return .object(.customIcon(circularData))
        } else {
            return .object(.basic("", circular: true))
        }
    }
}
