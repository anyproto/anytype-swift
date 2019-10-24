//
//  BlockViewModifieres.swift
//  AnyType
//
//  Created by Denis Batvinkin on 04.10.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import SwiftUI


struct BaseView: ViewModifier {
    @State var dragOffset: CGSize = .zero
    
    func body(content: Content) -> some View {
        HStack {
            Text("+").gesture(createDragGeasture())
            content
        }.offset(x: self.dragOffset.width, y: self.dragOffset.height)
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
