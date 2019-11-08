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
    let bounds: Anchor<CGRect>?
    let isDragging: Bool
}


struct BaseViewPreferenceKey: PreferenceKey {
    typealias Value = BaseViewPreferenceData
    
    static var defaultValue = BaseViewPreferenceData(bounds: nil, isDragging: false)
    
    static func reduce(value: inout BaseViewPreferenceData, nextValue: () -> BaseViewPreferenceData) {
        let next = nextValue()
        
        if next.isDragging {
            value = next
        }
    }
}


struct BaseView: ViewModifier {
    @State var dragOffset: CGSize = .zero
    
    func body(content: Content) -> some View {
        HStack {
            Text("+")
                .gesture(createDragGeasture())
            content
        }
        .anchorPreference(key: BaseViewPreferenceKey.self, value: .bounds) {
            return BaseViewPreferenceData(bounds: $0, isDragging: !self.dragOffset.equalTo(.zero))
        }
        .offset(x: self.dragOffset.width, y: self.dragOffset.height)
    }
    
    private func createDragGeasture() -> some Gesture {
        return DragGesture()
            .onChanged { value in
                self.dragOffset.width += value.translation.width
                self.dragOffset.height += value.translation.height
        }
        .onEnded { value in
            self.dragOffset = .zero
        }
    }
}


struct BaseView_Previews: PreviewProvider {
    static var previews: some View {
        Text("Base modifier").modifier(BaseView())
    }
}
