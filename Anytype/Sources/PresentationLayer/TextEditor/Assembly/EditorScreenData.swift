import BlocksModels

enum EditorViewType: String {
    case page
    case set
}

struct EditorScreenData: Hashable {
    let pageId: BlockId
    let type: EditorViewType
    
    static var empty: EditorScreenData {
        EditorScreenData(pageId: "", type: .page)
    }
}
