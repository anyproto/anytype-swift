import Foundation
import SwiftUI

struct ServerDocumentPickerView: View {
    
    @StateObject var model: ServerDocumentPickerViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        YamlDocumentPicker { url in
            model.onSelectFile(url: url)
        }
        .onChange(of: model.dismiss) { _ in
            dismiss()
        }
        .ignoresSafeArea()
    }
}
