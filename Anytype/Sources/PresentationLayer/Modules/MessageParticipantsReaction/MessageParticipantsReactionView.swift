import Foundation
import SwiftUI

struct MessageParticipantsReactionView: View {
    
    @StateObject private var model: MessageParticipantsReactionViewModel
    
    init(data: MessageParticipantsReactionData) {
        self._model = StateObject(wrappedValue: MessageParticipantsReactionViewModel(data: data))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            DragIndicator()
            titleView
            if let state = model.state {
                content(with: state)
            }
        }
        .mediumPresentationDetents()
        .task {
            await model.subscribeOnParticipants()
        }
    }
    
    private var titleView: some View {
        HStack {
            Spacer()
            AnytypeText(model.title, style: .bodyRegular)
                .foregroundStyle(Color.Text.primary)
            Spacer()
        }
        .frame(height: 48)
    }
    
    @ViewBuilder
    private func content(with state: MessageParticipantsReactionState) -> some View {
        switch state {
        case .data(let participantsData):
            list(with: participantsData)
        case .empty:
            EmptyStateView(
                title: Loc.Chat.Reactions.Empty.title,
                subtitle: Loc.Chat.Reactions.Empty.subtitle,
                style: .plain
            )
        }
    }
    
    private func list(with data: [ObjectCellData]) -> some View {
        PlainList {
            ForEach(data) { data in
                ObjectCell(data: data)
            }
        }
        .scrollIndicators(.never)
    }
}
