import Foundation
import SwiftUI
import Services

struct EmptyObjectIconView: View {
    
    private let imageMultiplier: CGFloat = 0.625
    
    let isList: Bool
    
    var body: some View {
        GeometryReader { reader in
            ZStack {
                Image(asset: isList ? .emptyListObject : .emptyObject)
                    .resizable()
                    .if(reader.size.width > 20) {
                        $0.frame(
                            width: reader.size.width * imageMultiplier,
                            height: reader.size.height * imageMultiplier,
                            alignment: .center
                        )
                    }
            }
            .frame(width: reader.size.width, height: reader.size.height)
            .objectIconBackgroundColorModifier()
            .objectIconCornerRadius()
        }
    }
}
