import Foundation
import SwiftUI

struct LaunchView: View {
    
    var body: some View {
        ZStack {
            Color.backgroundPrimary
            Image(asset: .splashLogo)
        }.ignoresSafeArea()
    }
}

struct LaunchView_Previews: PreviewProvider {
    
    static var previews: some View {
        LaunchView()
    }
}
