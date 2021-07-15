//
//  DocumentProfileIconPicker.swift
//  Anytype
//
//  Created by Konstantin Mordan on 06.07.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import SwiftUI

struct DocumentProfileIconPicker: View {
    
    @EnvironmentObject private var viewModel: ObjectIconPickerViewModel
    @Environment(\.presentationMode) private var presentationMode
    
    var body: some View {
        VStack(spacing: 0) {
            mediaPickerView
            tabBarView
        }
        .ignoresSafeArea(.keyboard)
    }
    
    private var mediaPickerView: some View {
        MediaPickerView(contentType: viewModel.mediaPickerContentType) { item in
            item.flatMap { viewModel.uploadImage(from: $0) }
            presentationMode.wrappedValue.dismiss()
        }
    }
    
    private var tabBarView: some View {
        Button {
            viewModel.removeIcon()
            presentationMode.wrappedValue.dismiss()
        } label: {
            AnytypeText("Remove photo", style: .headline)
                .foregroundColor(viewModel.isRemoveEnabled ? .pureRed : Color.buttonInactive)
        }
        .disabled(!viewModel.isRemoveEnabled)
        .frame(height: 48)
    }
}

struct DocumentProfileIconPicker_Previews: PreviewProvider {
    static var previews: some View {
        DocumentProfileIconPicker()
    }
}
