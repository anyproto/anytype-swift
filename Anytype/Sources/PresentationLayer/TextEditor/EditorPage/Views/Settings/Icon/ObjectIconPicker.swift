import SwiftUI
import AnytypeCore

struct ObjectIconPicker: View {
    @ObservedObject var viewModel: ObjectIconPickerViewModel
    var dismissHandler = DismissHandler(onDismiss: {})
    
    var body: some View {
        Group {
            switch viewModel.detailsLayout {
            case .basic, .set, .collection, .space, .file, .image, .objectType:
                ObjectBasicIconPicker(
                    viewModel: viewModel,
                    onDismiss: dismissHandler.onDismiss
                )
            case .profile:
                ObjectProfileIconPicker(viewModel: viewModel, onDismiss: dismissHandler.onDismiss)
            case .todo, .note, .bookmark, .unknown, .relation, .relationOption:
                EmptyView()
                    .onAppear {
                        anytypeAssertionFailure("Not supported layout")
                    }
            }
        }
    }
}
