import SwiftUI
import UniformTypeIdentifiers

struct MessageLinkLocalBinaryFileView: View {
    
    let path: String
    let type: UTType
    let onTapRemove: () -> Void
    
    private var fileName: String { URL(fileURLWithPath: path).lastPathComponent }
    
    var body: some View {
        MessageLinkObjectView(
            icon: .object(.file(mimeType: type.identifier, name: fileName)),
            title: fileName,
            description: Loc.file,
            onTapRemove: onTapRemove
        )
    }
}
