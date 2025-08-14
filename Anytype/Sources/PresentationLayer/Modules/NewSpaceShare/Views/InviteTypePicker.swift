import SwiftUI


struct InviteTypePicker: View {
    let currentType: SpaceRichIviteType
    let onSelect: (SpaceRichIviteType) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            DragIndicator()
            ForEach(Array(SpaceRichIviteType.allCases.enumerated()), id: \.element) { index, type in
                Button {
                    UISelectionFeedbackGenerator().selectionChanged()
                    onSelect(type)
                } label: {
                    HStack(spacing: 0) {
                            InviteStateView(richInviteType: type)
                            if type == currentType {
                                Image(asset: .X24.tick)
                                    .foregroundColor(.Control.primary)
                           }
                    }
                    .if(index < SpaceRichIviteType.allCases.count - 1) {
                        $0.newDivider()
                    }
                }
            }
            Spacer.fixedHeight(8)
        }
        .padding(.horizontal, 16)
        .background(Color.Background.secondary)
        .onAppear {
            AnytypeAnalytics.instance().logScreenSpaceLinkTypePicker()
        }
    }
}

#Preview {
    InviteTypePicker(currentType: .editor) { _ in }
}
