import Foundation
import SwiftUI

struct HomeUpdateGradient: View, Animatable {
    
    private enum Constants {
        static let blue = Color(hex: "#A9DBFF")
        static let green = Color(hex: "#AAF2B5")
    }
    
    var locationState = CGFloat(0)
    
    var body: some View {
        LinearGradient(
            gradient: Gradient(stops: [
                Gradient.Stop(color: Constants.blue, location: locationState-2),
                Gradient.Stop(color: Constants.green, location: locationState-1),
                Gradient.Stop(color: Constants.blue, location: locationState),
                Gradient.Stop(color: Constants.green, location: locationState+1),
            ]),
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    var animatableData: CGFloat {
        get { locationState }
        set { locationState = newValue }
    }
}
