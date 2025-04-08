import Foundation
import SwiftUI

struct HomeUpdateGradient: View, @preconcurrency Animatable {
    
    var percent: CGFloat
    
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
        get { percent }
        set { percent = newValue }
    }
    
    private var locationOffset: CGFloat {
        (percent * 3).truncatingRemainder(dividingBy: 3)
    }
}

#Preview {
    VStack {
        HomeUpdateGradient(percent: 0)
        HomeUpdateGradient(percent: 1/6)
        HomeUpdateGradient(percent: 2/6)
        HomeUpdateGradient(percent: 3/6)
        HomeUpdateGradient(percent: 4/6)
        HomeUpdateGradient(percent: 5/6)
        HomeUpdateGradient(percent: 1)
    }
}
