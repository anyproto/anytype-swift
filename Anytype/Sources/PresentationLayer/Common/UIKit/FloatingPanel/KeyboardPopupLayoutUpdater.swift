import Foundation
import CoreGraphics
import FloatingPanel
import UIKit

final class KeyboardPopupLayoutUpdater {
    
    private var keyboardListener: KeyboardEventsListnerHelper?
    
    init(initialPanelHeight: CGFloat, fpc: FloatingPanelController?) {
        let showAction: KeyboardEventsListnerHelper.Action = { [weak fpc] notification in
            guard
                let keyboardRect = notification.localKeyboardRect(for: UIResponder.keyboardFrameEndUserInfoKey),
                let fpc = fpc
            else { return }
            
            fpc.layout = FixedHeightPopupLayout(height: initialPanelHeight + keyboardRect.height)
            fpc.invalidateLayout()
        }
        
        let willHideAction: KeyboardEventsListnerHelper.Action = { [weak fpc] _ in
            guard let fpc = fpc else { return }
            
            fpc.layout = FixedHeightPopupLayout(height: initialPanelHeight)
            fpc.invalidateLayout()
        }
        
        self.keyboardListener = KeyboardEventsListnerHelper(
            willShowAction: showAction,
            willChangeFrame: showAction,
            willHideAction: willHideAction
        )
    }
    
}
