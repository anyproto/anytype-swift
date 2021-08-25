import SwiftUI

struct ObjectIconPicker: View {
    @ObservedObject var viewModel: ObjectIconPickerViewModel
    var dismissHandler = DismissHandler(onDismiss: {})
    
    var body: some View {
        Group {
            switch viewModel.detailsLayout {
            case .basic:
                ObjectBasicIconPicker(onDismiss: dismissHandler.onDismiss)
                    .environmentObject(viewModel)
            case .profile:
                ObjectProfileIconPicker(onDismiss: dismissHandler.onDismiss)
                    .environmentObject(viewModel)
            default:
                EmptyView()
            }
        }
    }
}
