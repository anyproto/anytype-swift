import SwiftUI
import AnytypeCore

struct ObjectIconPicker: View {
    @ObservedObject var viewModel: ObjectIconPickerViewModel
    var dismissHandler = DismissHandler(onDismiss: {})
    
    var body: some View {
        Group {
            switch viewModel.detailsLayout {
            case .basic, .set, .collection, .file, .image, .objectType:
                ObjectBasicIconPicker(
                    viewModel: viewModel,
                    onDismiss: dismissHandler.onDismiss
                )
            case .space, .spaceView, .profile, .participant:
                ObjectProfileIconPicker(viewModel: viewModel, onDismiss: dismissHandler.onDismiss)
            case nil:
                EmptyView()
            case .todo, .note, .bookmark, .UNRECOGNIZED, .relation, .relationOption, .dashboard, .relationOptionsList, .audio, .video, .pdf, .date:
                EmptyView()
                    .onAppear {
                        anytypeAssertionFailure("Not supported layout")
                    }
            }
        }
    }
}
