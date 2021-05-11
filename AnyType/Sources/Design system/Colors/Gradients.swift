import SwiftUI

final class Gradients {
    static let loginBackground: Gradient = {
        let color1 = Color(red: 0.57, green: 0.71, blue: 0.76)
        let color2 = Color(red: 0.72, green: 0.84, blue: 0.86)
        let color3 = Color(red: 0.81, green: 0.79, blue: 0.75)
        let color4 = Color(red: 0.64, green: 0.61, blue: 0.56)
        let gradient1 = Gradient.Stop(color: color1, location: 0.0)
        let gradient2 = Gradient.Stop(color: color2, location: 0.51)
        let gradient3 = Gradient.Stop(color: color3, location: 0.79)
        let gradient4 = Gradient.Stop(color: color4, location: 1.0)
        let gradient = Gradient(stops: [gradient1, gradient2, gradient3, gradient4])
        
        return gradient
    }()
}
