import Foundation
import ProtobufMessages
import AnytypeCore
import Combine
import UIKit
import Services

@MainActor
final class SettingsAccountViewModel: ObservableObject {
    
    // MARK: - DI
    
    private weak var output: (any SettingsAccountModuleOutput)?
    
    init(
        output: (any SettingsAccountModuleOutput)?
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
