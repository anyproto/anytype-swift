//
//  RelationEditingViewPopup.swift
//  Anytype
//
//  Created by Konstantin Mordan on 18.01.2022.
//  Copyright © 2022 Anytype. All rights reserved.
//

import Foundation
import FloatingPanel
import UIKit

#warning("TODO R: init with ViewModel + subscribe for content update in order to update floatingpanel layout")
final class RelationEditingViewPopup: FloatingPanelController {
    
    var keyboardFloatingPanelLayoutUpdater: KeyboardFloatingPanelLayoutUpdater?
    
    init(contentViewController: UIViewController) {
        super.init(delegate: nil)
        
        self.set(contentViewController: contentViewController)
        self.isRemovalInteractionEnabled = true
        self.backdropView.dismissalTapGestureRecognizer.isEnabled = true
        
        self.surfaceView.grabberHandlePadding = 8.0
        self.surfaceView.grabberHandle.backgroundColor = .stroke
        self.surfaceView.grabberHandleSize = .init(width: 48.0, height: 5.0)
        self.surfaceView.contentPadding = .init(top: 22, left: 0, bottom: 0, right: 0)
        self.contentMode = .static
        
        let appearance = SurfaceAppearance()
        appearance.cornerRadius = 16.0
        appearance.cornerCurve = .continuous
        // Define shadows
        let shadow = SurfaceAppearance.Shadow()
        shadow.color = UIColor.grayscale90.withAlphaComponent(0.25)
        shadow.offset = CGSize(width: 0, height: 0)
        shadow.radius = 40
        shadow.opacity = 1
        appearance.shadows = [shadow]

        self.surfaceView.appearance = appearance
        
        #if DEBUG
        self.surfaceView.backgroundColor = .red
        #endif
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
