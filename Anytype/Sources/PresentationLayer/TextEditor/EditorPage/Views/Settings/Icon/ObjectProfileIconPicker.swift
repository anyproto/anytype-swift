import SwiftUI


struct ObjectProfileIconPicker: View {
    
    @ObservedObject var viewModel: ObjectIconPickerViewModel
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
        }
    }
    
    private var tabBarView: some View {
        Button {
            viewModel.removeIcon()
            dismiss()
        } label: {
            AnytypeText(Loc.removePhoto, style: .uxBodyRegular)
                .foregroundColor(viewModel.isRemoveEnabled ? Color.System.red : .Button.inactive)
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
        ObjectProfileIconPicker(
            viewModel: ObjectIconPickerViewModel(
                document: DI.preview.serviceLocator.documentsProvider.document(objectId: "", forPreview: false),
                onIconAction: { _ in }
            )
        )
    }
}
