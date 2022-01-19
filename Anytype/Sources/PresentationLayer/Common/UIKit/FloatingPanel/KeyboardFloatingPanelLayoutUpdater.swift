//
//  KeyboardFloatingPanelLayoutUpdater.swift
//  Anytype
//
//  Created by Konstantin Mordan on 19.01.2022.
//  Copyright © 2022 Anytype. All rights reserved.
//

import Foundation
import CoreGraphics
import FloatingPanel
import UIKit

final class KeyboardFloatingPanelLayoutUpdater {
    
    private var keyboardListener: KeyboardEventsListnerHelper?
    
    init(initialPanelHeight: CGFloat, fpc: FloatingPanelController?) {
        let showAction: KeyboardEventsListnerHelper.Action = { [weak fpc] notification in
            guard
                let keyboardRect = notification.localKeyboardRect(for: UIResponder.keyboardFrameEndUserInfoKey),
                let fpc = fpc
            else { return }
            
            fpc.layout = FixedHeightFloatingPanelLayout(height: initialPanelHeight + keyboardRect.height)
            fpc.invalidateLayout()
        }
        
        let willHideAction: KeyboardEventsListnerHelper.Action = { [weak fpc] _ in
            guard let fpc = fpc else { return }
            
            fpc.layout = FixedHeightFloatingPanelLayout(height: initialPanelHeight)
            fpc.invalidateLayout()
        }
        
        self.keyboardListener = KeyboardEventsListnerHelper(
            willShowAction: showAction,
            willChangeFrame: showAction,
            willHideAction: willHideAction
        )
    }
    
}
