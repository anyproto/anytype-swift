//
//  FileLoadingState.swift
//  AnyType
//
//  Created by Kovalev Alexander on 06.04.2021.
//  Copyright © 2021 AnyType. All rights reserved.
//

import Foundation

/// File loading state
///
/// - loading: File loading prrocess is running and you can access how much are loaded
/// - loaded: File loaded and you can access it by URK
enum FileLoadingState {
    case loading(Float)
    case loaded(URL)
    
    /// Convenience getter for percents complete
    var percentComplete: Float {
        switch self {
        case let .loading(percent):
            return percent
        case .loaded:
            return 1
        }
    }
    
    /// Convenience getter for file URL
    var fileURL: URL? {
        switch self {
        case let .loaded(url):
            return url
        case .loading:
            return nil
        }
    }
}
