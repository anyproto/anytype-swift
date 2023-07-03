import SwiftUI

struct DataIconView: View {
    
    @Environment(\.isEnabled) private var isEnable
    
    let uiImage: UIImage
    
    var body: some View {
        Image(uiImage: uiImage)
            .foregroundColor(isEnable ? .Button.active : .Button.inactive)
    }
}
