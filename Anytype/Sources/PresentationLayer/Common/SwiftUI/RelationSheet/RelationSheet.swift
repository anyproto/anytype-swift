//
//  RelationSheet.swift
//  Anytype
//
//  Created by Konstantin Mordan on 18.11.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import SwiftUI

struct RelationSheet: View {
    
    @ObservedObject var viewModel: RelationSheetViewModel
    @State private var backgroundOpacity = 0.0
    @State private var showPopup = false
    @State private var sheetHeight = 0.0
    
    private let contentView: AnyView
    
    init(viewModel: RelationSheetViewModel) {
        self.viewModel = viewModel
        self.contentView = viewModel.contentViewModel.makeView()
    }
    
    var body: some View {
        ZStack {
            background
            
            VStack(spacing: 0) {
                Spacer()
                sheet
            }
        }
        .ignoresSafeArea(.container)
        .onAppear {
            withAnimation(.fastSpring) {
                backgroundOpacity = 0.25
                showPopup = true
            }
        }
    }
    
    private var background: some View {
        Color.grayscale90.opacity(backgroundOpacity)
            .onTapGesture {
                withAnimation(.fastSpring) {
                    backgroundOpacity = 0.0
                    showPopup = false
                    viewModel.contentViewModel.saveValue()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        viewModel.onDismiss?()
                    }
                }
            }
    }
    
    private var sheet: some View {
        VStack(spacing: 0) {
            DragIndicator(bottomPadding: 0)
            AnytypeText(viewModel.name, style: .uxTitle1Semibold, color: .textPrimary)
                .padding([.top, .bottom], 12)
            
            contentView
            
            Spacer.fixedHeight(20)
        }
        .background(Color.background)
        .background(FrameCatcher { sheetHeight = $0.height })
        .cornerRadius(16, corners: [.topLeft, .topRight])
        .offset(x: 0, y: currentOffset)
    }
    
    private var currentOffset: CGFloat {
        showPopup ? 0 : sheetHeight
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
        RelationSheet(
            viewModel: RelationSheetViewModel(
                name: "",
                contentViewModel: RelationTextValueEditingViewModel(
                    objectId: "",
                    relationKey: "",
                    value: nil
                )
            )
        )
            .background(Color.red)
    }
}
