import Foundation
import SwiftUI

struct SpaceWidgetView: View {
    
    @StateObject private var model: SpaceWidgetViewModel
    
    init(onSpaceSelected: @escaping () -> Void) {
        _model = StateObject(wrappedValue: SpaceWidgetViewModel(onSpaceSelected: onSpaceSelected))
    }
    
    var body: some View {
        HStack(spacing: 15) {
            IconView(icon: model.spaceIcon)
                .frame(width: 40, height: 40)
            VStack(alignment: .leading, spacing: 1) {
                AnytypeText(model.spaceName, style: .previewTitle2Medium, color: .Text.primary)
                    .lineLimit(1)
                if model.spaceWithMembers {
                    AnytypeText(model.spaceMembers, style: .relation3Regular, color: .Text.secondary)
                } else {
                    AnytypeText(model.spaceAccessType, style: .relation3Regular, color: .Text.secondary)
                }
            }
            Spacer()
            if model.spaceWithMembers {
                IconView(icon: .asset(.X24.sharing))
                    .frame(width: 24, height: 24)
            }
        }
        .padding(.horizontal, 16)
        .frame(height: 68)
        .background(Color.Widget.card)
        .cornerRadius(16, style: .continuous)
        .onTapGesture {
            model.onTapWidget()
        }
        .task {
            await model.startSpaceTask()
        }
        .task {
            await model.startParticipantTask()
        }
    }
}
