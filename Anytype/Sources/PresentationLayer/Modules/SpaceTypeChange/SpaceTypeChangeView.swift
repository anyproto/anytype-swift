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
            ModalNavigationHeader(title: Loc.channelType)
            ScrollView {
                VStack(spacing: 0) {
                    SpaceTypeChangeRow(
                        icon: .X24.chat,
                        title: Loc.Spaces.UxType.Chat.title,
                        subtitle: Loc.Spaces.UxType.Chat.changeDescription,
                        isSelected: model.chatIsSelected
                    ) {
                        try await model.onTapChat()
                    }
                    
                    SpaceTypeChangeRow(
                        icon: .X24.space,
                        title: Loc.Spaces.UxType.Space.title,
                        subtitle: Loc.Spaces.UxType.Space.changeDescription,
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
