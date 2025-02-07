import Foundation

struct BookmarkScreenData: Hashable, Identifiable {
    let url: URL
    let editorScreenData: EditorScreenData
    
    var id: Int { hashValue }
}
