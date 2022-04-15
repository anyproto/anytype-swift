import BlocksModels
import AnytypeCore

struct EditorScreenData: Hashable {
    let pageId: AnytypeId
    let type: EditorViewType
}

enum EditorViewType: String {
    case page
    case set
}
