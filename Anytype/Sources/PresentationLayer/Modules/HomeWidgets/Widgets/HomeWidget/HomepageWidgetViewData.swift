import Foundation
import Services

struct HomepageWidgetViewData {
    let spaceId: String
    let objectId: String
    let canSetHomepage: Bool
    let output: (any CommonWidgetModuleOutput)?
    let onChangeHome: () -> Void
}
