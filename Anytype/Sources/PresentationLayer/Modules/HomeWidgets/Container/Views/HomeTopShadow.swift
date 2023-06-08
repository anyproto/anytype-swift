import Foundation
import SwiftUI

struct HomeTopShadow: View {
    
    // Soft gradient
    // Online calculator https://larsenwork.com/easing-gradients/
    private let softOpacity = [
        0.35, 0.346973, 0.337572, 0.321419,
        0.298406, 0.268879, 0.233841, 0.195058,
        0.154942, 0.116159, 0.0811212, 0.051594,
        0.0285809, 0.0124285, 0.00302652, 0
    ]
    
    var body: some View {
        return LinearGradient(
            gradient: Gradient(colors: softOpacity.map { Color.black.opacity($0) }),
            startPoint: .top,
            endPoint: .bottom
        )
        .frame(height: 88)
    }
}
