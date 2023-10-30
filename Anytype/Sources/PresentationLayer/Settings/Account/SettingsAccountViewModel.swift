import Foundation
import ProtobufMessages
import AnytypeCore
import Combine
import UIKit
import Services

@MainActor
final class SettingsAccountViewModel: ObservableObject {
    
    // MARK: - DI
    
    private weak var output: SettingsAccountModuleOutput?
    
    init(
        output: SettingsAccountModuleOutput?
    ) {
        self.output = output
    }
    
    func onRecoveryPhraseTap() {
        output?.onRecoveryPhraseSelected()
    }
    
    func onDeleteAccountTap() {
        output?.onDeleteAccountSelected()
    }
    
    func onLogOutTap() {
        output?.onLogoutSelected()
    }
}
