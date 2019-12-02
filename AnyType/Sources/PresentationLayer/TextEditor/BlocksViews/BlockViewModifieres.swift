//
//  BlockViewModifieres.swift
//  AnyType
//
//  Created by Denis Batvinkin on 04.10.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import SwiftUI


struct BaseViewPreferenceData: Identifiable, Equatable {
    static func == (lhs: BaseViewPreferenceData, rhs: BaseViewPreferenceData) -> Bool {
        lhs.id == rhs.id
    }
    
    let id = UUID()
    let dragRect: Anchor<CGRect>?
    let isDragging: Bool
    let view: AnyView?
}


struct BaseViewPreferenceKey: PreferenceKey {
    typealias Value = BaseViewPreferenceData
    
    static var defaultValue = BaseViewPreferenceData(dragRect: nil, isDragging: false, view: nil)
    
    static func reduce(value: inout BaseViewPreferenceData, nextValue: () -> BaseViewPreferenceData) {
        let next = nextValue()
        
        if next.isDragging {
            value = next
        }
    }
}


struct DraggbleView: ViewModifier {
    @State var dragOffset: CGSize = .zero
    @State var translation: CGSize = .zero
    
    @GestureState private var state: DragGesture.Value?
    
    
    func body(content: Content) -> some View {
        return HStack {
            Text("+")
                .gesture(createDragGeasture())
            content
        }.overlay(
            ZStack {
                if translation != CGSize.zero {
                    HStack {
                        Text("+")
                        content
                    }
                    .anchorPreference(key: BaseViewPreferenceKey.self, value: .bounds) { anchor in
                        return BaseViewPreferenceData(dragRect: anchor, isDragging:  !self.translation.equalTo(.zero), view:
                            AnyView(self.body(content: content)))
                    }
                    .offset(x: self.translation.width, y: self.translation.height)
                }
            }
        )
    }
    
    private func createDragGeasture() -> some Gesture {
        return DragGesture()
            .onChanged { value in
                self.dragOffset.width += value.translation.width
                self.dragOffset.height += value.translation.height
                self.translation = value.translation
                
        }
        .onEnded { value in
            self.translation = .zero
            self.dragOffset = .zero
        }
    }
}


struct BaseView_Previews: PreviewProvider {
    static var previews: some View {
        Text("Base modifier").modifier(DraggbleView())
    }
}
