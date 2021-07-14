//
//  ObjectSettingsContainerView.swift
//  Anytype
//
//  Created by Konstantin Mordan on 14.07.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import SwiftUI

struct ObjectSettingsContainerView: View {
    
    var onHide: () -> Void = {}
    
    @State private var mainViewPresented = false
    @State private var layoutSettingsPresented = false
    
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
                    DocumentSettingsView().padding(8)
                }
            )
            .onAppear {
                withAnimation(.ripple) {
                    mainViewPresented = true
                }
            }
    }
}

struct ObjectSettingsContainerView_Previews: PreviewProvider {
    static var previews: some View {
        ObjectSettingsContainerView()
    }
}
