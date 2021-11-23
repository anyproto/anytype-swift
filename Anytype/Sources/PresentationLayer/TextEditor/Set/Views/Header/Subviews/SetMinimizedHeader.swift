import SwiftUI

struct SetMinimizedHeader: View {
    let headerPosition: CGPoint
    
    private let minimizedHeaderHeight: CGFloat = 92
    
    var body: some View {
        Group {
            if headerPosition.y < minimizedHeaderHeight {
                VStack {
                    VStack {
                        CoverConstants.gradients[1].asLinearGradient().frame(height: minimizedHeaderHeight)
                        SetHeaderSettings()
                    }.background(Color.background)
                    Spacer()
                }
            } else {
                EmptyView()
            }
        }

    }
}

struct SetMinimizedHeader_Previews: PreviewProvider {
    static var previews: some View {
        SetMinimizedHeader(headerPosition: .zero)
    }
}
