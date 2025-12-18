import SwiftUI
import Services
import AnytypeCore

struct BookmarkCreateView: View {
    @State private var model: BookmarkCreateViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.pageNavigation) private var pageNavigation

    init(data: BookmarkCreateScreenData) {
        _model = State(wrappedValue: BookmarkCreateViewModel(data: data))
    }

    var body: some View {
        inputContainer
            .onAppear {
                model.pageNavigation = pageNavigation
            }
            .onChange(of: model.dismiss) {
                dismiss()
            }
            .snackbar(toastBarData: $model.toastBarData)
    }

    private var inputContainer: some View {
        VStack(spacing: 0) {
            DragIndicator()
            HStack(spacing: 0) {
                TextField(Loc.Set.Bookmark.Create.placeholder, text: $model.urlText)
                    .font(AnytypeFontBuilder.font(anytypeFont: .uxBodyRegular))
                    .foregroundStyle(Color.Text.primary)
                    .keyboardType(.URL)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .submitLabel(.done)
                    .onSubmit { model.onTapCreate() }

                Spacer(minLength: 8)

                Button(Loc.create) { model.onTapCreate() }
                    .font(AnytypeFontBuilder.font(anytypeFont: .uxBodyRegular))
                    .foregroundStyle(model.isCreateDisabled ? Color.Text.tertiary : Color.Control.accent100)
                    .disabled(model.isCreateDisabled)
            }
            .padding(.horizontal, 20)
            .frame(height: 48)
            
            Spacer.fixedHeight(12)
        }
        .background(Color.Background.secondary)
    }
}
