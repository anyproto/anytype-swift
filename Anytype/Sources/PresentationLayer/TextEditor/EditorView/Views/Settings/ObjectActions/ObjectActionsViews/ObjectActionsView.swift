//
//  ObjectActionsView.swift
//  Anytype
//
//  Created by Denis Batvinkin on 23.09.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import SwiftUI
import Amplitude


struct ObjectActionsView: View {
    @EnvironmentObject var viewModel: ObjectActionsViewModel

    var body: some View {
        ScrollView (.horizontal, showsIndicators: false) {
            HStack(spacing: 20) {
                ForEach(viewModel.objectActions, id: \.self) { setting in
                    ObjectActionRow(setting: setting) {
                        switch setting {
                        case .archive:
                            viewModel.changeArchiveState()
                        case .favorite:
                            viewModel.changeFavoriteSate()
//                        case .moveTo:
//                            viewModel.moveTo()
//                        case .template:
//                            viewModel.template()
//                        case .search:
//                            viewModel.search()
                        }
                    }
                }
            }
        }
    }
}
