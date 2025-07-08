import SwiftUI

struct ObjectProfileIconPicker: View {
    
    let isRemoveEnabled: Bool
    let mediaPickerContentType: MediaPickerContentType
    let onSelectItemProvider: (_ itemProvider: NSItemProvider) -> Void
    let removeIcon: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var selectedIndex = 0
    
    var body: some View {
        VStack(spacing: 0) {
            // Fix MediaPickerView. Without TabView it broken presentation
            TabView(selection: $selectedIndex) {
                mediaPickerView
                    .tag(0)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            tabBarView
        }
        .ignoresSafeArea(.keyboard)
        .background(Color.Background.primary)
    }
    
    private var mediaPickerView: some View {
        MediaPickerView(contentType: mediaPickerContentType) { itemProvider in
            itemProvider.flatMap {
                onSelectItemProvider($0)
            }
            dismiss()
        }
    }
    
    private var tabBarView: some View {
        Button {
            removeIcon()
            dismiss()
        } label: {
            AnytypeText(Loc.removePhoto, style: .uxBodyRegular)
                .foregroundColor(isRemoveEnabled ? Color.Pure.red : .Control.inactive)
        }
        .disabled(!isRemoveEnabled)
        .frame(height: 48)
    }
}
