//
//  ObjectSettingsContainerView.swift
//  Anytype
//
//  Created by Konstantin Mordan on 14.07.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import SwiftUI

struct ObjectSettingsContainerView: View {
    
    @ObservedObject var viewModel: ObjectSettingsViewModel
    
    var onHide: () -> Void = {}
        
    @State private var mainViewPresented = false
    @State private var isCoverPickerPresented = false
    
    var body: some View {
        Color.clear
            .ignoresSafeArea()
            .popup(
                isPresented: $mainViewPresented,
                type: .floater(verticalPadding: 42),
                animation: .ripple,
                closeOnTap: false,
                closeOnTapOutside: true,
                backgroundOverlayColor: Color.black.opacity(0.25),
                dismissCallback: {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        onHide()
                    }
                }, view: {
                    ObjectSettingsView(isCoverPickerPresented: $isCoverPickerPresented).padding(8)
                        .environmentObject(viewModel)
                }
            )
            
            .sheet(
                isPresented: $isCoverPickerPresented,
                onDismiss: {
                    // TODO: is it necessary?
                    isCoverPickerPresented = false
                }
            ) {
                DocumentCoverPicker()
            }
            
            .onAppear {
                withAnimation(.ripple) {
                    mainViewPresented = true
                }
            }
    }
}

struct ObjectSettingsContainerView_Previews: PreviewProvider {
    static var previews: some View {
        ObjectSettingsContainerView(
            viewModel: ObjectSettingsViewModel(
                objectDetailsService: ObjectDetailsService(eventHandler: EventHandler(), objectId: "")
            )
        )
    }
}
