//
//  ObjectHeaderLocalEventsListener.swift
//  ObjectHeaderLocalEventsListener
//
//  Created by Konstantin Mordan on 10.08.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import Foundation
import UIKit
import Combine

final class ObjectHeaderLocalEventsListener {
    
    // MARK: - Private variables
    
    private var subscriptions: [AnyCancellable] = []
    
    // MARK: - Internal functions
    
    func beginObservingEvents(with onReceive: @escaping (ObjectHeaderLocalEvent) -> Void) {
        NotificationCenter.Publisher(
            center: .default,
            name: .documentCoverImageUploadingEvent,
            object: nil
        )
        .map {
            guard let string = $0.object as? String else { return nil }
            return UIImage(contentsOfFile: string)
        }
        .receiveOnMain()
        .sink {
            onReceive(.coverUploading($0))
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
        .sink { onReceive(.iconUploading($0)) }
        .store(in: &subscriptions)
    }
    
}
