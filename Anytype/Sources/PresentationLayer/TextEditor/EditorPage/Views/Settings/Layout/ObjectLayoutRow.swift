//
//  ObjectLayoutRow.swift
//  Anytype
//
//  Created by Konstantin Mordan on 06.07.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import SwiftUI
import Services

struct ObjectLayoutRow: View {
    
    let layout: DetailsLayout
    let isSelected: Bool
    
    let onTap: () -> Void
    
    var body: some View {
        Button {
            onTap()
        }
        label: {
            row
        }
    }
    
    private var row: some View {
        HStack(spacing: 0) {
            Image(asset: layout.iconAsset)
                .frame(width: 44, height: 44)
                .border(8, color: .Control.secondary.opacity(0.4))
            
            Spacer.fixedWidth(12)
            
            VStack(alignment: .leading, spacing: 0) {
                Spacer()
                
                HStack(spacing: 0) {
                    VStack(alignment: .leading, spacing: 0) {
                        AnytypeText(layout.title, style: .uxTitle2Medium)
                            .foregroundColor(.Text.primary)
                        AnytypeText(layout.description, style: .caption1Regular)
                            .foregroundColor(.Text.secondary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.9)
                    }
                    
                    Spacer(minLength: 12)
                    
                    if isSelected {
                        Image(asset: .X24.tick).frame(width: 24, height: 24).foregroundColor(.Control.primary)
                    }
                }
                
                Spacer()
                AnytypeDivider()
            }
        }
        .frame(height: 60)
        .padding(.horizontal, 16)
    }
    
}

struct DocumentLayoutTypeRow_Previews: PreviewProvider {
    static var previews: some View {
        ObjectLayoutRow(layout: .basic, isSelected: true, onTap: {})
            .background(Color.blue)
    }
}
