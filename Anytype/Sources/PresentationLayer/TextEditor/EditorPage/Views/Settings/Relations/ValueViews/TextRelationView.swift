//
//  TextRelationView.swift
//  Anytype
//
//  Created by Konstantin Mordan on 04.11.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import SwiftUI

struct TextRelationView: View {
    
    let value: String?
    let hint: String
    
    var body: some View {
        if let value = value, value.isNotEmpty {
            AnytypeText(
                value,
                style: .relation1Regular,
                color: .textPrimary
            )
                .lineLimit(1)
        } else {
            ObjectRelationRowHintView(hint: hint)
        }
    }
}

struct TextRelationView_Previews: PreviewProvider {
    static var previews: some View {
        TextRelationView(
            value: "nil",
            hint: "Hint"
        )
    }
}
