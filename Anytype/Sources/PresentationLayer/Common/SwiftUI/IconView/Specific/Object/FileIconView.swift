import Foundation
import SwiftUI

struct FileIconView: View {
    
    let mimeType: String
    let name: String
    
    var body: some View {
        Image(asset: FileIconBuilder.convert(mime: mimeType, fileName: name))
            .resizable()
    }
}
