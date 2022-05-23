import SwiftUI


struct ObjectProfileIconPicker: View {
    
    @EnvironmentObject private var viewModel: ObjectIconPickerViewModel
    @Environment(\.presentationMode) private var presentationMode
    
    var onDismiss: (() -> ())?
    
    var body: some View {
        VStack(spacing: 0) {
            mediaPickerView
            tabBarView
        }
        .ignoresSafeArea(.keyboard)
    }
    
    private var mediaPickerView: some View {
        MediaPickerView(contentType: viewModel.mediaPickerContentType) { itemProvider in
            itemProvider.flatMap {
                viewModel.uploadImage(from: $0)
            }
            dismiss()
        }
    }
    
    private var tabBarView: some View {
        Button {
            viewModel.removeIcon()
            dismiss()
        } label: {
            AnytypeText("Remove photo".localized, style: .uxBodyRegular, color: viewModel.isRemoveEnabled ? Color.System.red : .buttonInactive)
        }
        .disabled(!viewModel.isRemoveEnabled)
        .frame(height: 48)
    }
    
    private func dismiss() {
        presentationMode.wrappedValue.dismiss()
        onDismiss?()
    }
}

struct DocumentProfileIconPicker_Previews: PreviewProvider {
    static var previews: some View {
        ObjectProfileIconPicker()
    }
}
