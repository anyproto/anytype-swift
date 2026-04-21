import Foundation
import Services

struct HomepageWidgetViewData {
    let spaceId: String
    let objectId: String
    let canSetHomepage: Bool
    let document: any BaseDocumentProtocol
    let output: (any CommonWidgetModuleOutput)?
    let onChangeHome: @MainActor () -> Void
    let onHomeTap: @MainActor (ScreenData) -> Void
}
