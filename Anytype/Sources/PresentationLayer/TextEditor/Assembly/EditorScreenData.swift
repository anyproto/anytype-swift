import BlocksModels
import AnytypeCore

struct EditorScreenData {
    let pageId: BlockId
    let type: EditorViewType
}

enum EditorViewType: String {
    case page
    case set
}
