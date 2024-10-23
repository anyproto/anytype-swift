import SwiftUI
import DeepLinks
import Services
import Combine
import AnytypeCore

@MainActor
final class HomeChatCoordinatorViewModel: ObservableObject {
    
    @Injected(\.workspaceStorage)
    private var workspaceStorage: any WorkspacesStorageProtocol
    @Injected(\.searchMiddleService)
    private var searchMiddleService: any SearchMiddleServiceProtocol
    @Injected(\.objectActionsService)
    private var objectActionService: any ObjectActionsServiceProtocol
    
    let spaceInfo: AccountInfo
    var pageNavigation: PageNavigation?
    
    @Published var chatData: EditorChatObject?
    
    init(spaceInfo: AccountInfo) {
        self.spaceInfo = spaceInfo
    }
    
    func startSubscription() async {
        // Production code. Waiting middleware.
//        for await spaceView in workspaceStorage.spaceViewPublisher(spaceId: spaceInfo.accountSpaceId).values {
//            chatData = EditorChatObject(objectId: spaceView.chatId, spaceId: spaceInfo.accountSpaceId)
//        }
        // Temporary code for work in dev brach.
        do {
            let request = SearchRequest(spaceId: spaceInfo.accountSpaceId, filters: [], sorts: [], fullText: "CHAT HOME OBJECT", keys: [], limit: 1)
            let result = try await searchMiddleService.search(data: request)
            if let chatObject = result.first, chatObject.name == "CHAT HOME OBJECT" {
                chatData = EditorChatObject(objectId: chatObject.id, spaceId: chatObject.spaceId)
            } else {
                let chatObject =  try await objectActionService.createObject(
                    name: "CHAT HOME OBJECT",
                    typeUniqueKey: .chat,
                    shouldDeleteEmptyObject: false,
                    shouldSelectType: false,
                    shouldSelectTemplate: false,
                    spaceId: spaceInfo.accountSpaceId,
                    origin: .none,
                    templateId: nil
                )
                chatData = EditorChatObject(objectId: chatObject.id, spaceId: chatObject.spaceId)
            }
        } catch {}
    }
}
