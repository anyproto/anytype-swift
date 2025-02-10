import SwiftUI
import UniformTypeIdentifiers

struct SimpleCameraData: Identifiable {
    let id = UUID()
    let onMediaTaken: (_ media: ImagePickerMediaType) -> Void
}

struct SimpleCameraView: View {
    
    let data: SimpleCameraData
    
    var body: some View {
        ImagePickerView(
            sourceType: .camera,
            onMediaTaken: data.onMediaTaken
        )
        .ignoresSafeArea()
    }
}
