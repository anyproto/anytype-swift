import SwiftUI

struct EditorSetEmptyView: View {
    let model: EditorSetEmptyViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            content
            Spacer()
        }
    }
    
    var content: some View {
        VStack(spacing: 0) {
            AnytypeText(model.mode.title, style: .uxCalloutRegular)
                .foregroundColor(.Text.secondary)
            
            Spacer.fixedHeight(4)
            
            AnytypeText(model.mode.subtitle, style: .caption1Regular)
                .foregroundColor(.Text.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)
            
            Spacer.fixedHeight(16)
            
            if model.mode.enableAction {
                Button {
                    model.onTap()
                } label: {
                    AnytypeText(model.mode.buttonTitle, style: .caption1Regular)
                        .foregroundColor(.Text.primary)
                        .padding(EdgeInsets(top: 9, leading: 12, bottom: 9, trailing: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.Shape.primary, lineWidth: 1)
                        )
                }
            }
        }
    }
}

#Preview {
    EditorSetEmptyView(
        model: EditorSetEmptyViewModel(
            mode: .emptyQuery(canChange: true),
            onTap: {}
        )
    )
}
