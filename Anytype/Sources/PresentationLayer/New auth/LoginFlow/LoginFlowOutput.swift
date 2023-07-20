import SwiftUI

@MainActor
protocol LoginFlowOutput: AnyObject {
    func onShowMigrationGuideAction()
    func onSettingsAction()
}
