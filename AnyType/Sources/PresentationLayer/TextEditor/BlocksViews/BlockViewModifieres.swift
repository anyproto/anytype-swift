//
//  BlockViewModifieres.swift
//  AnyType
//
//  Created by Denis Batvinkin on 04.10.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import SwiftUI


struct DraggingViewPreferenceData: Identifiable {
    var id: String? = nil
    var position: Anchor<CGRect>? = nil
    var translation: CGSize = .zero
    var isActive: Bool = false
}


struct DraggingViewPreferenceKey: PreferenceKey {
    typealias Value = DraggingViewPreferenceData
    
    static var defaultValue = DraggingViewPreferenceData()
    
    static func reduce(value: inout DraggingViewPreferenceData, nextValue: () -> DraggingViewPreferenceData) {
        let next = nextValue()
        
        if next.isActive {
            value = next
        }
    }
}


struct DraggbleView: ViewModifier {
   
    enum DragState {
        case inactive
        case pressing
        case dragging(translation: CGSize)
        
        var translation: CGSize {
            switch self {
            case .inactive, .pressing:
                return .zero
            case .dragging(let translation):
                return translation
            }
        }
        
        var isActive: Bool {
            switch self {
            case .inactive, .pressing:
                return false
            case .dragging:
                return true
            }
        }
        
        var isDragging: Bool {
            switch self {
            case .inactive, .pressing:
                return false
            case .dragging:
                return true
            }
        }
    }
    
    var blockId: String
    @State var initialPosition: Anchor<CGRect>?
    @GestureState private var dragState = DragState.inactive
    
    func body(content: Content) -> some View {
        HStack {
            content
                .anchorPreference(key: DraggingViewPreferenceKey.self, value: .bounds) { anchor in
                    return DraggingViewPreferenceData(id: self.blockId, position: anchor, translation: self.dragState.translation, isActive: self.dragState.isActive)
            }
        }
        .simultaneousGesture(createDragGeasture())
    }
    
    private func createDragGeasture() -> some Gesture {
        let minimumLongPressDuration = 0.4
        return LongPressGesture(minimumDuration: minimumLongPressDuration)
            .sequenced(before: DragGesture(coordinateSpace: .global))
            .updating($dragState) { value, state, transaction in
                switch value {
                // Long press begins.
                case .first(true):
//                    print("pressing")
                    state = .pressing
                // Long press confirmed, dragging may begin.
                case .second(true, let drag):
                    print("drag")
                    state = .dragging(translation: drag?.translation ?? .zero)
                // Dragging ended or the long press cancelled.
                default:
//                    print("inactive")
                    state = .inactive
                }
        }
        .onEnded { value in
//            print("END")
            self.initialPosition = nil
            guard case .second(true, let drag?) = value else { return }
//            self.viewState.width += drag.translation.width
//            self.viewState.height += drag.translation.height
        }
    }
}


struct BaseView_Previews: PreviewProvider {
    static var previews: some View {
        Text("Base modifier").modifier(DraggbleView(blockId: "123"))
    }
}
