import Foundation
import SwiftUI

struct ChatHeaderView: View {
    
    @StateObject private var model: ChatHeaderViewModel
    
    init(spaceId: String, onTapSettings: @escaping () -> Void) {
        self._model = StateObject(wrappedValue: ChatHeaderViewModel(spaceId: spaceId, onTapSettings: onTapSettings))
    }
    
    var body: some View {
        PageNavigationHeader {
            AnytypeText(model.title, style: .uxTitle1Semibold)
                .lineLimit(1)
        } rightView: {
            IncreaseTapButton {
                model.tapSettings()
            } label: {
                IconView(icon: model.icon)
                    .frame(width: 28, height: 28)
            }
        }
        .task {
            await model.subscribe()
        }
    }
}

@MainActor
final class ChatHeaderViewModel: ObservableObject {
    
    @Injected(\.workspaceStorage)
    private var workspaceStorage: any WorkspacesStorageProtocol
    
    @Published private(set) var title: String?
    @Published private(set) var icon: Icon?
    
    private let spaceId: String
    private let onTapSettings: () -> Void
    
    init(spaceId: String, onTapSettings: @escaping () -> Void) {
        self.spaceId = spaceId
        self.onTapSettings = onTapSettings
    }
    
    func subscribe() async {
        for await spaceInfo in workspaceStorage.spaceViewPublisher(spaceId: spaceId).values {
            title = spaceInfo.title
            icon = spaceInfo.objectIconImage
        }
    }
    
    func tapSettings() {
        onTapSettings()
    }
}
