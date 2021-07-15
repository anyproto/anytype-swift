//
//  ObjectSettingsView.swift
//  Anytype
//
//  Created by Konstantin Mordan on 14.07.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import SwiftUI

struct ObjectSettingsView: View {
    
    @ObservedObject var viewModel: ObjectSettingsViewModel
    
    var body: some View {
        VStack(
            alignment: .center,
            spacing: 0
        ) {
            DragIndicator()
            DocumentSettingsList()
        }
        .background(Color.background)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.35), radius: 40, x: 0, y: 4)
    }
}

struct ObjectSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        ObjectSettingsView(
            viewModel: ObjectSettingsViewModel()
        )
    }
}
