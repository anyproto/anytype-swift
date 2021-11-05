//
//  StatusRelationView.swift
//  Anytype
//
//  Created by Konstantin Mordan on 05.11.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import SwiftUI

struct StatusRelationView: View {
    
    let value: StatusRelation?
    let hint: String
    
    var body: some View {
        if let value = value {
            AnytypeText(
                value.text,
                style: .relation1Regular,
                color: value.color
            )
                .lineLimit(1)
        } else {
            AnytypeText(
                hint,
                style: .callout,
                color: .textTertiary
            )
                .lineLimit(1)
        }
    }
}

struct StatusRelationView_Previews: PreviewProvider {
    static var previews: some View {
        TextRelationView(
            value: "nil",
            hint: "Hint"
        )
    }
}
