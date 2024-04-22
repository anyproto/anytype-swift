import SwiftUI


struct ObjectProfileIconPicker: View {
    
    @ObservedObject var viewModel: ObjectIconPickerViewModel
    @Environment(\.dismiss) private var dismiss
    
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
}

struct DocumentProfileIconPicker_Previews: PreviewProvider {
    static var previews: some View {
        ObjectProfileIconPicker(
            viewModel: ObjectIconPickerViewModel(
                document: DI.preview.serviceLocator.documentsProvider.document(objectId: "", forPreview: false),
                actionHandler: ObjectIconActionHandler()
            )
        )
    }
}
