import Foundation
import SwiftUI

extension BottomAlert {
    static func binConfirmation(
        count: Int,
        onConfirm: @escaping () -> Void
    ) -> Self {
        BottomAlert(
            title: Loc.areYouSureYouWantToDelete(count),
            message: Loc.theseObjectsWillBeDeletedIrrevocably,
            leftButton: BottomAlertButton(title: Loc.cancel, isDistructive: false, action: {}),
            rightButton: BottomAlertButton(title: Loc.delete, isDistructive: true, action: {
                onConfirm()
            })
        )
    }
}
