import BlocksModels
import AnytypeCore

struct EditorScreenData: Hashable {
    let pageId: AnytypeId
    let type: EditorViewType
    let isOpenedForPreview: Bool

    init(pageId: AnytypeId, type: EditorViewType, isOpenedForPreview: Bool = false) {
        self.pageId = pageId
        self.type = type
        self.isOpenedForPreview = isOpenedForPreview
    }
}

enum EditorViewType: String {
    case page
    case set
}
