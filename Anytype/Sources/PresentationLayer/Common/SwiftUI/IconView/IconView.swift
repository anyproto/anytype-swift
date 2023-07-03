import SwiftUI

struct IconView: View {
    
    let icon: ObjectIconImage
    
    var body: some View {
        switch icon {
        case .icon(let objectIconType):
            switch objectIconType {
            case .basic(let string):
                SquareImageIdView(imageId: string)
            case .profile(let profile):
                switch profile {
                case .imageId(let imageId):
                    CircleImageIdView(imageId: imageId)
                case .character(let c):
                    CircleCharIconView(text: String(c))
                case .gradient(let gradientId):
                    CircleGradientIconView(gradientId: gradientId)
                }
            case .emoji(let emoji):
                EmojiIconView(text: emoji.value)
            case .bookmark(let string):
                SquareSmallImageIdView(imageId: string)
            case .space(let space):
                switch space {
                case .character(let c):
                    // TODO: Check me
                    EmojiIconView(text: String(c))
                case .gradient(let gradientId):
                    SquareGradientIconView(gradientId: gradientId)
                }
            }
        case .todo(let bool):
            TodoIconView(checked: bool)
        case .placeholder(let character):
            // TODO: Rename Emoji view
            EmojiIconView(text: character.map { String($0) } ?? "")
        case .imageAsset(let imageAsset):
            AssetIconView(asset: imageAsset)
        case .image(let uIImage):
            DataIconView(uiImage: uIImage)
        }
    }
}
