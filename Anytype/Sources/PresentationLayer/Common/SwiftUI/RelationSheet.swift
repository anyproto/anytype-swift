//
//  RelationSheet.swift
//  Anytype
//
//  Created by Konstantin Mordan on 18.11.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import SwiftUI

struct RelationSheet: View {
    
    @State private var showPopup = false
    
    var body: some View {
        ZStack {
            background
            
            VStack {
                Spacer()
                sheet
            }
        }
        .ignoresSafeArea(.container)
        .onAppear {
            withAnimation(.fastSpring) {
                showPopup = true
            }
        }
    }
    
    private var background: some View {
        Color.grayscale90.opacity(0.25)
            .onTapGesture {
                withAnimation(.fastSpring) {
                    showPopup = false
                }
            }
    }
    
    private var sheet: some View {
        VStack(spacing: 0) {
            DragIndicator(bottomPadding: 0)
            AnytypeText("About".localized, style: .uxTitle1Semibold, color: .textPrimary)
                .padding([.top, .bottom], 12)
            
            Color.blue.frame(height: 100)
            
            Spacer.fixedHeight(20)
        }
        .background(Color.background)
        .cornerRadius(16, corners: [.topLeft, .topRight])
        .offset(x: 0, y: currentOffset)
    }
    
    private var currentOffset: CGFloat {
        showPopup ? 0 : 1000
    }
    
    @ViewBuilder
    fileprivate func addTap(onTap: @escaping ()->()) -> some View {
        self.simultaneousGesture(
            TapGesture().onEnded {
                onTap()
            }
        )
    }
}

struct RelationSheet_Previews: PreviewProvider {
    static var previews: some View {
        RelationSheet()
            .background(Color.red)
    }
}
