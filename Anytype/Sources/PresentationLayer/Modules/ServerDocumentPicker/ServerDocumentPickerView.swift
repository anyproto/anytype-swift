import Foundation
import SwiftUI

struct ServerDocumentPickerView: View {

    @State private var model = ServerDocumentPickerViewModel()
    
    var body: some View {
        DocumentPicker(contentTypes: [.yaml]) { url in
            model.onSelectFile(url: url)
        }
    }
}
