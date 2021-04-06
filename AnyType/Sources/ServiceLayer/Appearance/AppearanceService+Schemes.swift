//
//  AppearanceService.swift
//  AnyType
//
//  Created by Lobanov Dmitry on 19.11.19.
//  Copyright © 2019 AnyType. All rights reserved.
//

import Foundation

// MARK: Schemes
extension AppearanceService {
    class Schemes {
        init() {
            self.setup()
        }
        func setup() {
            self.schemes = self.createSchemes()
        }

        var schemes: [UpperBound] = []
    }
}

// MARK: Schemes
extension AppearanceService.Schemes {
    func createSchemes() -> [UpperBound] {
        return [
            Global.SwiftUI.BaseText(),
            Global.Appearance.BaseNavigationBar()
        ]
    }
    func scheme<T>(for search: T.Type) -> T? where T: UpperBound {
        return self.schemes.filter { (item) in
            return type(of: item) is T.Type
        }.first as? T
    }
}

// MARK: Schemes/Base
import UIKit
import SwiftUI

extension AppearanceService.Schemes {
    class UpperBound {
        func apply() {}
    }

    class AppearanceScheme<Appearance: UIView>: UpperBound {
        var appearance: Appearance
        init(_ appearance: Appearance = .appearance()) {
            self.appearance = appearance
        }
        override init() {
            self.appearance = .appearance()
        }
    }

    class SwiftUIScheme: UpperBound {}
}

protocol AppearanceService_Schemes_HasSingleModifier_Protocol where Self: AppearanceService.Schemes.UpperBound {
    typealias SingleModifier = AppearanceService.Schemes.Supplement.SingleModifier<Self>
}

protocol AppearanceService_Schemes_HasAppearanceStackModifier_Protocol where Self: AppearanceService.Schemes.UpperBound {
    typealias AppearanceStackModifier = AppearanceService.Schemes.Supplement.AppearanceStackModifier<Self>
}

protocol AppearanceService_Schemes_HasAppearanceDualModifier_Protocol where Self: AppearanceService.Schemes.UpperBound {
    typealias AppearanceDualModifier = AppearanceService.Schemes.Supplement.AppearanceDualModifier<Self>
}


// MARK: Schemes/HasModifier
extension AppearanceService.Schemes.SwiftUIScheme: AppearanceService_Schemes_HasSingleModifier_Protocol {}
extension AppearanceService.Schemes.AppearanceScheme: AppearanceService_Schemes_HasSingleModifier_Protocol {}
extension AppearanceService.Schemes.AppearanceScheme: AppearanceService_Schemes_HasAppearanceStackModifier_Protocol {}
extension AppearanceService.Schemes.AppearanceScheme: AppearanceService_Schemes_HasAppearanceDualModifier_Protocol {}

// MARK: Schemes/Global
extension AppearanceService.Schemes {
    enum Global {
        enum SwiftUI {
            typealias UpperBound = SwiftUIScheme
        }
        enum Appearance {
            typealias UpperBound = AppearanceScheme
        }
    }
}

// MARK: Schemes/Global/SwiftUI
extension AppearanceService.Schemes.Global.SwiftUI {
    class BaseText: UpperBound {
        var foregroundColor: Color?
        var font: Font?
        var fontWeight: Font.Weight?
    }
    class BaseImage: UpperBound {
        var renderingType: Image.ResizingMode?
    }
}

// MARK: Schemes/Global/Appearance
extension AppearanceService.Schemes.Global.Appearance {
    class BaseNavigationBar: UpperBound<UINavigationBar> {
        var barTintColor: UIColor?
        override func apply() {
            appearance.barTintColor = self.barTintColor
        }
    }
}

// MARK: Schemes/Supplement
extension AppearanceService.Schemes {
    enum Supplement {}
}

// MARK: Schemes/Supplement/Stack
extension AppearanceService.Schemes.Supplement {
    class Stack<Value> {
        var defaultValue: Value?
        var values: [Value] = []
        func push(_ value: Value) {
            self.values.append(value)
        }
        func pop() -> Value? {
            let value = self.peek()
            self.values = self.values.dropLast()
            return value
        }
        func peek() -> Value? {
            if self.values.isEmpty {
                return self.defaultValue
            }
            return values.last
        }
        init(_ value: Value) {
            self.defaultValue = value
        }
        init() {}
    }
}

// MARK: Schemes/Supplement/ViewModifiers
extension AppearanceService.Schemes.Supplement {
    typealias UpperBound = AppearanceService.Schemes.UpperBound
    // Usage:
    // let modifier = AppearanceService.Schemes.Supplement.SingleModifier<AppearanceService.Schemes.Global.SwiftUI.BaseText>()
    // get scheme if exists...
    // let scheme = modifier.scheme
    // edit scheme if needed...
    // and apply it...
    struct SingleModifier<Scheme: UpperBound>: ViewModifier {
        let appearanceService = ServiceLocator.shared.appearanceService()
        var storedScheme: Scheme? {
            return appearanceService.schemes.scheme(for: Scheme.self)!
        }
        init(_ scheme: Scheme? = nil) {}
        func body(content: Content) -> some View {
            content
        }
    }

    // Usage:
    // let scheme = AppearanceService.Schemes.Global.Appearance.BaseNavigationBar()
    // edit scheme...
    // let modifier = AppearanceService.Schemes.Supplement.AppearanceStackModifier(scheme)
    // or
    // create it first:
    // let modifier = AppearanceService.Schemes.Supplement.AppearanceStackModifier<AppearanceService.Schemes.Global.Appearance.BaseNavigationBar>()
    // ....
    // in modifier:
    // content.modifier(modifier)
    struct AppearanceStackModifier<Scheme: UpperBound>: ViewModifier {
        let appearanceService = ServiceLocator.shared.appearanceService()
        var storedScheme: Scheme? {
            return appearanceService.schemes.scheme(for: Scheme.self)
        }
        var stack: Stack<Scheme> = .init()
        init(_ scheme: Scheme? = nil) {
            if let defaultScheme = self.storedScheme {
                self.stack.defaultValue = defaultScheme
            }
            if let scheme = scheme {
                self.stack.push(scheme)
            }
        }
        private func push(_ scheme: Scheme?) {
            if let scheme = scheme {
                self.stack.push(scheme)
            }
        }
        private func pop() {
            _ = self.stack.pop()
        }

        func popUp() -> Self {
            self.pop()
            return self
        }
        func pushDown(_ scheme: Scheme?) -> Self {
            self.push(scheme)
            return self
        }
        func body(content: Content) -> some View {
            content.onAppear() {
                self.stack.peek()?.apply()
            }.onDisappear() {
                self.stack.pop()?.apply()
            }
        }
    }

    struct AppearanceDualModifier<Scheme: UpperBound>: ViewModifier {
        private let appearanceService = ServiceLocator.shared.appearanceService()
        
        var storedScheme: Scheme? {
            return appearanceService.schemes.scheme(for: Scheme.self)
        }
        private var dualScheme: (Scheme?, Scheme?)
        private var left: Scheme? {
            return self.dualScheme.0
        }
        private var right: Scheme? {
            return self.dualScheme.1
        }
        private var current: Scheme? {
            return self.dualScheme.1 ?? self.dualScheme.0
        }
        init(_ scheme: Scheme? = nil) {
            self.dualScheme = (self.storedScheme, scheme)
        }
        private mutating func setRight(_ scheme: Scheme?) {
            self.dualScheme.1 = scheme
        }
        func setCurrent(_ scheme: Scheme?) -> Self {
            return .init(scheme)
        }
        func unsetCurrent() -> Self {
            return .init()
        }
        func body(content: Content) -> some View {
            content.onAppear() {
                self.current?.apply()
            }.onDisappear() {
                self.left?.apply()
            }
        }
    }
}

