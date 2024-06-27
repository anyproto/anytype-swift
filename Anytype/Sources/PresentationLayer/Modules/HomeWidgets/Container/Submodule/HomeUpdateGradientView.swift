import Foundation
import SwiftUI

struct HomeUpdateGradient: View, Animatable {
    
    var locationState: CGFloat
    
    var body: some View {
        LinearGradient(
            gradient: Gradient(stops: [
                Gradient.Stop(color: .Gradients.UpdateAlert.green, location: 0-locationOffset),
                Gradient.Stop(color: .Gradients.UpdateAlert.green, location: 0.5-locationOffset),
                Gradient.Stop(color: .Gradients.UpdateAlert.lightBlue, location: 1-locationOffset),
                Gradient.Stop(color: .Gradients.UpdateAlert.darkBlue, location: 1.5-locationOffset),
                Gradient.Stop(color: .Gradients.UpdateAlert.lightBlue, location: 2-locationOffset),
                Gradient.Stop(color: .Gradients.UpdateAlert.green, location: 2.5-locationOffset),
                // Final
                Gradient.Stop(color: .Gradients.UpdateAlert.green, location: 3-locationOffset),
                Gradient.Stop(color: .Gradients.UpdateAlert.green, location: 3.5-locationOffset),
                Gradient.Stop(color: .Gradients.UpdateAlert.lightBlue, location: 4-locationOffset)
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
