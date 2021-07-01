//
//  DocumentDetailsViewModel.swift
//  Anytype
//
//  Created by Konstantin Mordan on 30.06.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import UIKit
import Combine
import BlocksModels

final class DocumentDetailsViewModel {

    // MARK: - Internal variables
    
    private(set) var coverViewState: DocumentCoverViewState = .empty
    private(set) var iconViewState: DocumentIconViewState = .empty

    // MARK: - Private variables
    
    private var subscriptions: [AnyCancellable] = []
    
    private let onUpdate: () -> Void
    
    // MARK: - Initializer
    
    init(onUpdate: @escaping () -> Void) {
        self.onUpdate = onUpdate
        
        setupSubscriptions()
    }
    
    func performUpdateUsingDetails(_ detailsData: DetailsData) {
        coverViewState = {
            guard let cover = detailsData.documentCover else {
                return DocumentCoverViewState.empty
            }
            
            return DocumentCoverViewState.cover(cover)
        }()
        
        iconViewState = {
            guard let icon = detailsData.documentIcon else {
                return DocumentIconViewState.empty
            }
            
            return DocumentIconViewState.icon(icon)
        }()
        
        onUpdate()
    }
    
}

private extension DocumentDetailsViewModel {
    
    func setupSubscriptions() {
        NotificationCenter.Publisher(
            center: .default,
            name: .documentCoverImageUploadingEvent,
            object: nil
        )
        .compactMap { $0.object as? String }
        .compactMap { UIImage(contentsOfFile: $0) }
        .receiveOnMain()
        .sink { [weak self] image in
            guard let self = self else { return }
            
            self.coverViewState = .preview(image)
            self.onUpdate()
        }
        .store(in: &subscriptions)
        
        NotificationCenter.Publisher(
            center: .default,
            name: .documentIconImageUploadingEvent,
            object: nil
        )
        .compactMap { $0.object as? String }
        .compactMap { UIImage(contentsOfFile: $0) }
        .receiveOnMain()
        .sink { [weak self] image in
            guard let self = self else { return }
            
            self.iconViewState = .preview(image)
            self.onUpdate()
        }
        .store(in: &subscriptions)
    }
    
}
