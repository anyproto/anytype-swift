import Foundation
import SwiftUI
import Services

struct ObjectIconView: View {
    
    let icon: ObjectIcon?
    
    var body: some View {
        switch icon {
        case .basic(let imageId):
            BasicIconView(imageId: imageId)
        case .profile(let profile):
            ProfileIconView(icon: profile)
        case .emoji(let emoji):
            EmojiIconView(emoji: emoji)
        case .bookmark(let imageId):
            BookmarkIconView(imageId: imageId)
        case .space(let space):
            SpaceIconView(icon: space)
        case .todo(let checked):
            TodoIconView(checked: checked)
        case .placeholder(let name):
            PlaceholderIconView(text: name)
        case .file(let mimeType, let name):
            FileIconView(mimeType: mimeType, name: name)
        case .deleted:
            Image(asset: .ghost)
        case .none:
            EmptyView()
        }
    }
}
