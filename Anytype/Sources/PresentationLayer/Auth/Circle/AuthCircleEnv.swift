import SwiftUI

extension VerticalAlignment {
    private enum AuthCircle: AlignmentID {
        static func defaultValue(in d: ViewDimensions) -> CGFloat {
            d[VerticalAlignment.center]
        }
    }
    
    static let authCircle = VerticalAlignment(AuthCircle.self)
}

extension EnvironmentValues {
    @Entry var authCircleCenterVerticalOffset: Binding<CGFloat> = .constant(0)
}
