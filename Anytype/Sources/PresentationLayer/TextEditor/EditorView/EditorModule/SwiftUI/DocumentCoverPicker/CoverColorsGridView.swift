//
//  CoverColorsGridView.swift
//  Anytype
//
//  Created by Konstantin Mordan on 18.06.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import SwiftUI

struct CoverColorsGridView: View {
    
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible())
    ]
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVGrid(
                columns: columns,
                spacing: 16,
                pinnedViews: [.sectionHeaders]
            ) {
                colorsSection
                gradientsSection
            }
        }
        .padding(.horizontal, 16)
    }
    
    private var colorsSection: some View {
        Section(header: PickerSectionHeaderView(title: "Solid colors")) {
            ForEach(CoverConstants.colors) { color in
                Color(hex: color.hex)
                    .cornerRadius(4)
                    .frame(height: 112)
                    .onTapGesture {
                        debugPrint(color.hex)
                    }
            }
        }
    }
    
    private var gradientsSection: some View {
        Section(header: PickerSectionHeaderView(title: "Gradients")) {
            ForEach(CoverConstants.gradients) { gradient in
                gradient.asLinearGradient()
                .cornerRadius(4)
                .frame(height: 112)
                .onTapGesture {
                    debugPrint(gradient.name)
                }
            }
        }
    }
}

struct CoverColorsGridView_Previews: PreviewProvider {
    static var previews: some View {
        CoverColorsGridView()
    }
}

// MARK: - CoverGradient

private extension CoverGradient {
    
    func asLinearGradient() -> some View {
        LinearGradient(
            gradient: Gradient(
                colors: [
                    Color(hex: self.startHex),
                    Color(hex: self.endHex)
                ]
            ),
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
}
