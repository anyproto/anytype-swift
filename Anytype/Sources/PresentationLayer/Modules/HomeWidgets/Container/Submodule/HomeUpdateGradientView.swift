import Foundation
import SwiftUI

struct HomeUpdateGradient: View, Animatable {
    
    private enum Constants {
        static let lightBlue = Color(hex: "#A9DBFF")
        static let darkBlue = Color(hex: "#55B8FF")
        static let green = Color(hex: "#AAF3B6")
    }
    
    var locationState = CGFloat(0)
    
    var body: some View {
        LinearGradient(
            gradient: Gradient(stops: [
                Gradient.Stop(color: Constants.green, location: 0-locationOffset),
                Gradient.Stop(color: Constants.green, location: 0.5-locationOffset),
                Gradient.Stop(color: Constants.lightBlue, location: 1-locationOffset),
                Gradient.Stop(color: Constants.darkBlue, location: 1.5-locationOffset),
                Gradient.Stop(color: Constants.lightBlue, location: 2-locationOffset),
                Gradient.Stop(color: Constants.green, location: 2.5-locationOffset),
                // Final
                Gradient.Stop(color: Constants.green, location: 3-locationOffset),
                Gradient.Stop(color: Constants.green, location: 3.5-locationOffset),
                Gradient.Stop(color: Constants.lightBlue, location: 4-locationOffset)
            ]),
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    var animatableData: CGFloat {
        get { locationState }
        set { locationState = newValue }
    }
    
    private var locationOffset: CGFloat {
        locationState.truncatingRemainder(dividingBy: 3)
    }
}

#Preview {
    VStack {
        HomeUpdateGradient(locationState: 0)
        HomeUpdateGradient(locationState: 0.5)
        HomeUpdateGradient(locationState: 1)
        HomeUpdateGradient(locationState: 1.5)
        HomeUpdateGradient(locationState: 2)
        HomeUpdateGradient(locationState: 2.5)
        HomeUpdateGradient(locationState: 3)
    }
}
