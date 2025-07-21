import SwiftUI
import AnytypeCore

struct UndoRedoView: View {
    @StateObject private var model: UndoRedoViewModel

    init(objectId: String) {
        self._model = StateObject(wrappedValue: UndoRedoViewModel(objectId: objectId))
    }
    
    var body: some View {
        HStack(spacing: 16) {
            
            AsyncButton {
                try await model.undo()
            } label: {
                ItemView(
                    imageAsset: .X32.Undo.undo,
                    title: Loc.undo
                )
            }
            
            AsyncButton {
                try await model.redo()
            } label: {
                ItemView(
                    imageAsset: .X32.Undo.redo,
                    title: Loc.redo
                )
            }
        }
        .snackbar(toastBarData: $model.toastData)
        .padding(.init(top: 16, leading: 16, bottom: 8, trailing: 16))
        .background(Color.Background.secondary)
    }
}

private struct ItemView: View {
    let imageAsset: ImageAsset
    let title: String

    var body: some View {
        VStack(spacing: 5) {
            Image(asset: imageAsset)
                .foregroundColor(.Control.secondary)
                .frame(height: 52)
                .frame(
                    minWidth: 0,
                    maxWidth: .infinity,
                    alignment: .center
                )
                .background(Color.Background.highlightedMedium)
                .cornerRadius(10.5)
            AnytypeText(title, style: .caption2Regular)
                .foregroundColor(.Text.secondary)
        }
    }
}
