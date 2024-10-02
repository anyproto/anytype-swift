import Foundation
import SwiftUI
import Services

struct EmptyObjectIconView: View {
    
    let emptyType: ObjectIcon.EmptyType
    
    private let imageMultiplier: CGFloat = 0.625
    
    var body: some View {
        GeometryReader { reader in
            ZStack {
                Image(asset: imageAsset())
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
    
    private func imageAsset() -> ImageAsset {
        switch emptyType {
        case .page:
            return .EmptyIcon.page
        case .list:
            return .EmptyIcon.list
        case .bookmark:
            return .EmptyIcon.bookmark
        case .discussion:
            return .EmptyIcon.discussion
        }
    }
}
