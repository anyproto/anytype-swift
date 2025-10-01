import Foundation
import SwiftUI

struct SpaceTypeChangeView: View {
    
    @StateObject private var model: SpaceTypeChangeViewModel
    
    init(data: SpaceTypeChangeData) {
        self._model = StateObject(wrappedValue: SpaceTypeChangeViewModel(data: data))
    }
    
    var body: some View {
        VStack {
            DragIndicator()
            ModalNavigationHeader(title: "Channel Type")
            ScrollView {
                VStack(spacing: 0) {
                    SpaceTypeChangeRow(
                        icon: .X24.chat,
                        title: "Chat",
                        subtitle: "Group chat with shared data. Best for small groups or a single ongoing conversation.",
                        isSelected: model.chatIsSelected
                    ) {
                        try await model.onTapChat()
                    }
                    
                    SpaceTypeChangeRow(
                        icon: .X24.space,
                        title: "Space",
                        subtitle: "Hub for advanced data management. Multi-chats by topic coming soon. Ideal for larger teams.",
                        isSelected: model.dataIsSelected
                    ) {
                        try await model.onTapData()
                    }
                }
            }
        }
        .task {
            await model.startSubscriptions()
        }
    }
}
