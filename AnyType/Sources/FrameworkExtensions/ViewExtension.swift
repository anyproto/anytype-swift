//
//  ViewExtension.swift
//  AnyType
//
//  Created by Denis Batvinkin on 16.08.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import SwiftUI


// MARK: Bounds accessors
extension View {
    
    func errorToast(isShowing: Binding<Bool>, errorText: String) -> some View {
        ErrorAlertView(isShowing: isShowing, errorText: errorText, presenting: self)
    }
    
    func renderedImage(size: CGSize = CGSize(width: 320, height: 160)) -> UIImage? {
        let sceneDeleage = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate
        let rect = CGRect(origin: .zero, size: size)
        let image = sceneDeleage?.window?.rootViewController?.view.renderedImage(rect: rect)
        
        return image
    }
    
    public func saveBounds(viewId: Int, coordinateSpace: CoordinateSpace = .global) -> some View {
        background(GeometryReader { proxy in
            Color.clear.preference(key: SaveBoundsPrefKey.self, value: [SaveBoundsPrefData(viewId: viewId, bounds: proxy.frame(in: coordinateSpace))])
        })
    }
    
    public func retrieveBounds(viewId: Int, _ rect: Binding<CGRect>) -> some View {
        onPreferenceChange(SaveBoundsPrefKey.self) { preferences in
            DispatchQueue.main.async {
                // The async is used to prevent a possible blocking loop,
                // due to the child and the ancestor modifying each other.
                let p = preferences.first(where: { $0.viewId == viewId })
                rect.wrappedValue = p?.bounds ?? .zero
            }
        }
    }
    
    public func retrieveBounds(viewId: Int, onRect: @escaping (CGRect) -> () ) -> some View {
        onPreferenceChange(SaveBoundsPrefKey.self) { preferences in
            DispatchQueue.main.async {
                // The async is used to prevent a possible blocking loop,
                // due to the child and the ancestor modifying each other.
                let p = preferences.first(where: { $0.viewId == viewId })
                onRect(p?.bounds ?? .zero)
            }
        }
    }
    
    public func outputBounds(viewId: Int) -> some View {
        saveBounds(viewId: viewId).retrieveBounds(viewId: viewId, onRect: { print("\(viewId): \($0)")} )
    }
    
    func onGeometryChange<Value>(compute: @escaping (GeometryProxy) -> Value?, onChange: @escaping (Value?) -> ()) -> some View where Value: Equatable {
        let key = TaggedKey<Value, ()>.self
        return self.overlay(GeometryReader { proxy in
            Color.clear.preference(key: key, value: compute(proxy))
        }).onPreferenceChange(key) { value in
            onChange(value)
        }.preference(key: key, value: nil)
    }
    
    func onGeometryPreferenceChange<Value, Preference>(_ preference: Preference.Type, compute: @escaping (GeometryProxy, Preference.Value) -> Value?, onChange: @escaping (Value?) -> ()) -> some View where Value: Equatable, Preference: PreferenceKey {
        let key = TaggedKey<Value, ()>.self
        
        return self.overlayPreferenceValue(preference) { preference in
            return GeometryReader { proxy in
                Color.clear.preference(key: key, value: compute(proxy, preference))
            }.onPreferenceChange(key) { value in
                onChange(value)
            }.preference(key: key, value: nil)
        }
    }
}

// This key takes the first non-`nil` value
struct TaggedKey<Value, Tag>: PreferenceKey {
    static var defaultValue: Value? { nil }
    static func reduce(value: inout Value?, nextValue: () -> Value?) {
        value = value ?? nextValue()
    }
}

private struct SaveBoundsPrefData: Equatable {
    let viewId: Int
    let bounds: CGRect
}

private struct SaveBoundsPrefKey: PreferenceKey {
    static var defaultValue: [SaveBoundsPrefData] = []
    
    static func reduce(value: inout [SaveBoundsPrefData], nextValue: () -> [SaveBoundsPrefData]) {
        value.append(contentsOf: nextValue())
    }
}
