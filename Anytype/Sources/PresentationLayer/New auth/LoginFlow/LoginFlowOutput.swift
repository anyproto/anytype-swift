import SwiftUI

@MainActor
protocol LoginFlowOutput: AnyObject {
    func onEntetingVoidAction() -> AnyView
    func onShowMigrationGuideAction()
}
