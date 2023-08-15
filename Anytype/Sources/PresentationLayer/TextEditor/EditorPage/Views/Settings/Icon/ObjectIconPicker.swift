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
            case nil:
                EmptyView()
            case .todo, .note, .bookmark, .unknown, .relation, .relationOption, .dashboard, .relationOptionList, .database:
                EmptyView()
                    .onAppear {
                        anytypeAssertionFailure("Not supported layout")
                    }
            }
        }
    }
}
