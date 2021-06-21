import SwiftUI

struct DocumentCoverPicker: View {
    
    @Environment(\.presentationMode) private var presentationMode
    
    var body: some View {
        VStack(spacing: 0) {
            DragIndicator(bottomPadding: 0)
            navigationBarView
            CoverColorsGridView()
        }
    }
    
    private var navigationBarView: some View {
        InlineNavigationBar {
            AnytypeText("Change cover", style: .headlineSemibold)
                .multilineTextAlignment(.center)
        } rightButton: {
            Button {
                // TODO: - add
            } label: {
                AnytypeText("Remove", style: .headline)
                    .foregroundColor(.red)
            }
        }
    }
}

struct DocumentCoverPicker_Previews: PreviewProvider {
    static var previews: some View {
        DocumentCoverPicker()
    }
}
