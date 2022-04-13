import BlocksModels
import AnytypeCore

struct EditorScreenData {
    let pageId: AnytypeId
    let type: EditorViewType
}

enum EditorViewType: String {
    case page
    case set
}
