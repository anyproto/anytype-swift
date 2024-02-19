import Foundation
import SwiftUI

struct SpaceJoinView: View {
    
    @StateObject var model: SpaceJoinViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            DragIndicator()
            ScreenStateView(state: model.state, error: model.errorMessage) {
                content
            }
        }
        .multilineTextAlignment(.center)
        .background(Color.Background.secondary)
        .onChange(of: model.dismiss) { _ in
            dismiss()
        }
    }
    
    private var content: some View {
        ScrollView {
            VStack(spacing: 0) {
                // TODO: Add icon
                ButtomAlertHeaderImageView(icon: .BottomAlert.update, style: .blue)
                Spacer.fixedHeight(15)
                AnytypeText(Loc.SpaceShare.Join.title, style: .heading, color: .Text.primary)
                Spacer.fixedHeight(16)
                AnytypeText(model.message, style: .bodyRegular, color: .Text.primary)
                Spacer.fixedHeight(16)
                // TODO: Make Multiline text field
                AnytypeTextField(
                    placeholder: Loc.SpaceShare.Join.commentPlaceholder,
                    placeholderFont: .caption1Regular,
                    text: $model.comment
                )
            }
            .padding(.horizontal, 30)
        }
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 0) {
                AsyncStandardButton(text: Loc.SpaceShare.Join.button, style: .primaryLarge) {
                    try await model.onJoin()
                }
                Spacer.fixedHeight(20)
                AnytypeText(Loc.SpaceShare.Join.info, style: .caption1Regular, color: .Text.secondary)
            }
            .padding(.horizontal, 30)
        }
        .snackbar(toastBarData: $model.toast)
    }
}

#Preview("Default") {
    DI.preview.modulesDI.spaceJoin().make(data: SpaceJoinModuleData(cid: "", key: ""))
}

#Preview("Sheet") {
    Color.black.sheet(isPresented: .constant(true)) {
        DI.preview.modulesDI.spaceJoin().make(data: SpaceJoinModuleData(cid: "", key: ""))
    }
}
