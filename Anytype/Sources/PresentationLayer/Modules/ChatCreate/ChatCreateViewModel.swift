import Foundation
import Services
import UIKit
import AnytypeCore
import DesignKit

enum ChatIconSelection {
    case file(FileData)
    case emoji(EmojiData)
}

struct ChatIconPickerData: Identifiable {
    let id = UUID()
    let iconSelection: ChatIconSelection?
}

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
    private var iconSelection: ChatIconSelection?

    init(data: ChatCreateScreenData) {
        self.data = data
    }

    func onTapCreate() {
        guard !createLoadingState else { return }
        createLoadingState = true
        
        Task {
            defer { createLoadingState = false }

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
                    templateId: nil
                )
            } catch {
                toastBarData = ToastBarData(error.localizedDescription, type: .failure)
                return
            }

            switch iconSelection {
            case .emoji(let emojiData):
                try? await detailsService.updateBundledDetails(
                    objectId: details.id,
                    bundledDetails: BundledDetails.iconDetails(iconEmoji: emojiData.emoji)
                )
            case .file(let fileData):
                let fileDetails = try? await fileActionsService.uploadFileObject(
                    spaceId: data.spaceId,
                    data: fileData,
                    origin: .none
                )
                if let fileDetails {
                    try? await detailsService.updateBundledDetails(
                        objectId: details.id,
                        bundledDetails: BundledDetails.iconDetails(objectId: fileDetails.id)
                    )
                }
            case .none:
                break
            }

            if let collectionId = data.collectionId {
                try? await objectActionsService.addObjectsToCollection(
                    contextId: collectionId,
                    objectIds: [details.id]
                )
            }

            UINotificationFeedbackGenerator().notificationOccurred(.success)
            AnytypeAnalytics.instance().logCreateObject(objectType: details.analyticsType, spaceId: details.spaceId, route: data.analyticsRoute)

            dismiss = true
            pageNavigation?.open(details.screenData())
        }
    }

    func onAppear() {
        updateChatIcon()
    }

    func onIconTapped() {
        iconPickerData = ChatIconPickerData(iconSelection: iconSelection)
    }

    // MARK: - Icon Picker Callbacks

    func onSelectEmoji(_ emoji: EmojiData) {
        iconSelection = .emoji(emoji)
        updateChatIcon()
    }

    func onSelectItemProvider(_ itemProvider: NSItemProvider) {
        Task {
            guard let fileData = try? await fileActionsService.createFileData(source: .itemProvider(itemProvider)) else { return }
            iconSelection = .file(fileData)
            updateChatIcon()
        }
    }

    func onRemoveIcon() {
        iconSelection = nil
        updateChatIcon()
    }

    // MARK: - Private

    private func updateChatIcon() {
        switch iconSelection {
        case .emoji(let emojiData):
            chatIcon = .object(.emoji(Emoji(emojiData.emoji) ?? .lamp, circular: true))
        case .file(let fileData):
            chatIcon = .object(.space(.localPath(fileData.path, circular: true)))
        case .none:
            if let chatType = try? objectTypeProvider.objectType(uniqueKey: .chatDerived, spaceId: data.spaceId),
               case .customIcon(let iconData) = chatType.icon {
                let circularData = CustomIconData(icon: iconData.icon, color: iconData.color, circular: true)
                chatIcon = .object(.customIcon(circularData))
            } else {
                chatIcon = .object(.basic("", circular: true))
            }
        }
    }
}
