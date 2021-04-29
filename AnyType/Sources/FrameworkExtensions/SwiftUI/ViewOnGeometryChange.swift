import SwiftUI


extension View {
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
private struct TaggedKey<Value, Tag>: PreferenceKey {
    static var defaultValue: Value? { nil }
    static func reduce(value: inout Value?, nextValue: () -> Value?) {
        value = value ?? nextValue()
    }
}
