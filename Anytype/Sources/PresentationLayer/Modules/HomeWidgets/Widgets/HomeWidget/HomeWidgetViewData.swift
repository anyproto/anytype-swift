import Foundation
import Services

struct HomeWidgetViewData {
    let spaceId: String
    let objectId: String
    let output: (any CommonWidgetModuleOutput)?
    let onChangeHome: () -> Void
}
