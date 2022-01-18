//
//  AnytypeFloatingPanelController.swift
//  Anytype
//
//  Created by Konstantin Mordan on 18.01.2022.
//  Copyright © 2022 Anytype. All rights reserved.
//

import Foundation
import FloatingPanel
import UIKit

final class AnytypeFloatingPanelController: FloatingPanelController {
    
    init(contentViewController: UIViewController) {
        super.init(delegate: nil)
        
        self.set(contentViewController: contentViewController)
        self.isRemovalInteractionEnabled = true
        self.backdropView.dismissalTapGestureRecognizer.isEnabled = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
