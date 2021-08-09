//
//  IconOnlyObjectHeaderContentView.swift
//  IconOnlyObjectHeaderContentView
//
//  Created by Konstantin Mordan on 09.08.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import UIKit

final class IconOnlyObjectHeaderContentView: UIView, UIContentView {
    
    private var appliedConfiguration: IconOnlyObjectHeaderConfiguration
    var configuration: UIContentConfiguration {
        get { self.appliedConfiguration }
        set {
            guard let configuration = newValue as? IconOnlyObjectHeaderConfiguration else {
                return
            }
        }
    }
    
    
    init(configuration: IconOnlyObjectHeaderConfiguration) {
        self.appliedConfiguration = configuration

        super.init(frame: .zero)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
