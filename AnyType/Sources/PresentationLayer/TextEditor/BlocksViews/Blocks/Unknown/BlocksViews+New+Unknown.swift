import Foundation
import SwiftUI
import Combine
import os
import BlocksModels

fileprivate typealias Namespace = BlocksViews.Unknown

// This is special kind of blocks. If we want, we could skip all blocks and show all blocks as "Unknown".

extension Namespace {
    enum Label {}
    enum Base {}
}

extension Namespace.Base {
    class ViewModel: BlocksViews.Base.ViewModel {}
}


