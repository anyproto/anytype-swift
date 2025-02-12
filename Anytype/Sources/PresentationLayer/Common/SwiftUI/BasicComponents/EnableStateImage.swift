import SwiftUI

struct EnableStateImage: View {
    @Environment(\.isEnabled) private var isEnable
    
    let enable: ImageAsset
    let disable: ImageAsset
    
    var body: some View {
        Image(asset: isEnable ? enable : disable)
    }
}
