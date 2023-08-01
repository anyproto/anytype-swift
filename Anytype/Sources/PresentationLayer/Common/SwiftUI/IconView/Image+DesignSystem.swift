import Foundation
import SwiftUI

struct ImageView: View {
    
    @Environment(\.isEnabled) private var isEnable
    
    let asset: ImageAsset
    
    var body: some View {
        Image(asset: asset)
            .foregroundColor(isEnable ? .Button.active : .Button.inactive)
    }
}
