import Foundation
import SwiftUI

struct ServerDocumentPickerView: View {
    
    @StateObject var model = ServerDocumentPickerViewModel()
    
    var body: some View {
        DocumentPicker(contentTypes: [.yaml]) { url in
            model.onSelectFile(url: url)
        }
    }
}
