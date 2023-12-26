import Foundation
import SwiftUI

extension BottomAlertLegacy {
    static func binConfirmation(
        count: Int,
        onConfirm: @escaping () -> Void
    ) -> Self {
        BottomAlertLegacy(
            title: Loc.areYouSureYouWantToDelete(count),
            message: Loc.theseObjectsWillBeDeletedIrrevocably,
            leftButton: BottomAlertButtonLegacy(title: Loc.cancel, isDistructive: false, action: {}),
            rightButton: BottomAlertButtonLegacy(title: Loc.delete, isDistructive: true, action: {
                onConfirm()
            })
        )
    }
}
