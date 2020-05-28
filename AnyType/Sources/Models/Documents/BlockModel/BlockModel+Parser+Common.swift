//
//  BlockModel+Parser+Common.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 26.05.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import UIKit

extension BlockModels.Parser {
    enum Common {
        enum Alignment {}
        enum Position {}
    }
}

// MARK: - Common / Alignment
extension BlockModels.Parser.Common.Alignment {
    enum Converter {
        typealias Model = BlockModels.Block.Information.Alignment
        typealias MiddlewareModel = Anytype_Model_Block.Align
        static func asModel(_ value: MiddlewareModel) -> Model? {
            switch value {
            case .left: return .left
            case .center: return .center
            case .right: return .right
            default: return nil
            }
        }
        
        static func asMiddleware(_ value: Model) -> MiddlewareModel? {
            switch value {
            case .left: return .left
            case .center: return .center
            case .right: return .right
            }
        }
    }
    enum UIKitConverter {
        typealias Model = BlockModels.Block.Information.Alignment
        typealias UIKitModel = NSTextAlignment
        static func asModel(_ value: UIKitModel) -> Model? {
            switch value {
            case .left: return .left
            case .center: return .center
            case .right: return .right
            default: return nil
            }
        }
        
        static func asUIKitModel(_ value: Model) -> UIKitModel? {
            switch value {
            case .left: return .left
            case .center: return .center
            case .right: return .right
            }
        }
    }
}

// MARK: - Common / Position
extension BlockModels.Parser.Common.Position {
    // TODO: Move to Model if needed?
    enum Position {
        case none
        case top, bottom
        case left, right
        case inner
        case replace
    }
}

extension BlockModels.Parser.Common.Position {
    enum Converter {
        typealias Model = Position
        typealias MiddlewareModel = Anytype_Model_Block.Position
        
        static func asModel(_ value: MiddlewareModel) -> Model? {
            switch value {
            case .none: return Model.none
            case .top: return .top
            case .bottom: return .bottom
            case .left: return .left
            case .right: return .right
            case .inner: return .inner
            case .replace: return .replace
            default: return nil
            }
        }
        static func asMiddleware(_ value: Model) -> MiddlewareModel? {
            switch value {
            case .none: return MiddlewareModel.none
            case .top: return .top
            case .bottom: return .bottom
            case .left: return .left
            case .right: return .right
            case .inner: return .inner
            case .replace: return .replace
            }
        }
    }
}
