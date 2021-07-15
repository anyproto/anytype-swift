//
//  ObjectSettingsView.swift
//  Anytype
//
//  Created by Konstantin Mordan on 14.07.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import SwiftUI

struct ObjectSettingsView: View {
    
    @EnvironmentObject var viewModel: ObjectSettingsViewModel
    
    var body: some View {
        VStack(
            alignment: .center,
            spacing: 0
        ) {
            DragIndicator(bottomPadding: 0)
            settings
        }
        .background(Color.background)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.35), radius: 40, x: 0, y: 4)
    }
    
    private var settings: some View {
        VStack(spacing: 0) {
            ForEach(viewModel.settings, id: \.self) { setting in
                ObjectSettingRow(setting: setting) {
                    debugPrint(setting)
                }
            }
        }
        .padding([.leading, .trailing, .bottom], 16)
    }
}

struct ObjectSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        ObjectSettingsView()
            .environmentObject(ObjectSettingsViewModel())
    }
}
