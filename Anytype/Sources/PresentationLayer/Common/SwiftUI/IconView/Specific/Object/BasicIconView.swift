import Foundation
import SwiftUI

struct BasicIconView: View {
    
    let imageId: String
    
    var body: some View {
        ImageIdIconView(imageId: imageId)
            .cornerRadius(2)
    }
}
