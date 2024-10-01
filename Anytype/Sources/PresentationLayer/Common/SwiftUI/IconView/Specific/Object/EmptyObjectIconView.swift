import Foundation
import SwiftUI
import Services

struct EmptyObjectIconView: View {
    
    let isList: Bool
    
    var body: some View {
        GeometryReader { reader in
            ZStack {
                Image(asset: isList ? .emptyListObject : .emptyObject)
                    .resizable()
                    .if(reader.size.width > 20) {
                        $0.frame(
                            width: reader.size.width * 0.6,
                            height: reader.size.height * 0.6,
                            alignment: .center
                        )
                    }
            }
            .frame(width: reader.size.width, height: reader.size.height)
            .objectIconBackgroundColorModifier()
        }
    }
}
