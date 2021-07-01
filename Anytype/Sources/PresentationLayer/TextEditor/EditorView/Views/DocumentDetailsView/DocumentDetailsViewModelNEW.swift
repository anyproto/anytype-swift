//
//  DocumentDetailsViewModelNEW.swift
//  Anytype
//
//  Created by Konstantin Mordan on 30.06.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import UIKit
import Combine

final class DocumentDetailsViewModelNEW {

    // MARK: - Internal variables
    
    private(set) var cover: DocumentCover? = nil

    // MARK: - Private variables
    
    private var coverNotificationSubscription: AnyCancellable?

    private let onUpdate: () -> Void
    
    // MARK: - Initializer
    
    init(onUpdate: @escaping () -> Void) {
        self.onUpdate = onUpdate
        
        setupSubscriptions()
    }
    
    func performCoverUpdate(_ cover: DocumentCover?) {
        self.cover = cover
        
        onUpdate()
    }
    
}

private extension DocumentDetailsViewModelNEW {
    
    func setupSubscriptions() {
        coverNotificationSubscription = NotificationCenter.Publisher(
            center: .default,
            name: .documentCoverImageUploadingEvent,
            object: nil
        )
        .compactMap { $0.object as? String }
        .compactMap { UIImage(contentsOfFile: $0) }
        .receiveOnMain()
        .sink { [weak self] image in
            guard let self = self else { return }
            
            self.cover = .preview(image)
            self.onUpdate()
        }
    }
    
}
