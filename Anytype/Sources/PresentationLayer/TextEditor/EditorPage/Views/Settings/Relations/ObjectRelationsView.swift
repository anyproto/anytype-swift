//
//  ObjectRelationsView.swift
//  Anytype
//
//  Created by Konstantin Mordan on 01.11.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import SwiftUI

struct ObjectRelationsView: View {
    
    var body: some View {
        VStack(spacing: 0) {
            DragIndicator(bottomPadding: 0)
            HStack {
                AnytypeText(
                    "In this object".localized,
                    style: .uxTitle1Semibold,
                    color: .textPrimary
                )
                
                Spacer()
            }.frame(height: 48)
            
            Spacer()
        }
        .padding([.leading, .trailing, .bottom], 20)
    }
    
}

struct ObjectRelationsView_Previews: PreviewProvider {
    static var previews: some View {
        ObjectRelationsView()
    }
}
