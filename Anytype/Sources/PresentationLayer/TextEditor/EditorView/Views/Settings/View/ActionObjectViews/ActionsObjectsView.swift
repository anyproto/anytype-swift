//
//  ActionsObjectsView.swift
//  Anytype
//
//  Created by Denis Batvinkin on 23.09.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import SwiftUI
import Amplitude


struct ActionsObjectsView: View {
    @EnvironmentObject var viewModel: ObjectSettingsViewModel

    var body: some View {
        ScrollView (.horizontal, showsIndicators: false) {
            HStack(spacing: 20) {
                ForEach(viewModel.bottomSettings, id: \.self) { setting in
                    ActionObjectSettingRow(setting: setting) {
                        switch setting {
                        case .archive:
                            viewModel.archiveObject()
                        case .favorite:
                            viewModel.favoriteObject()
                        case .moveTo:
                            viewModel.moveTo()
                        case .template:
                            viewModel.template()
                        case .search:
                            viewModel.search()
                        }
                    }
                }
            }
        }
    }
}
