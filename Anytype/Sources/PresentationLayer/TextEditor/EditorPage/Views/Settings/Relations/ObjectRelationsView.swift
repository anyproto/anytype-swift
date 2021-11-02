//
//  ObjectRelationsView.swift
//  Anytype
//
//  Created by Konstantin Mordan on 01.11.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import SwiftUI

struct ObjectRelationsView: View {
    
    @ObservedObject var viewModel: ObjectRelationsViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            DragIndicator(bottomPadding: 0)
            title
            relationsList
        }
        .padding([.leading, .trailing, .bottom], 20)
    }
    
    private var title: some View {
        HStack {
            AnytypeText(
                "In this object".localized,
                style: .uxTitle1Semibold,
                color: .textPrimary
            )
            
            Spacer()
        }
        .frame(height: 48)
    }
    
    private var relationsList: some View {
        List(viewModel.relations) { relation in
            AnytypeText(
                relation.name,
                style: .uxTitle1Semibold,
                color: .textPrimary
            )
        }
    }
    
}

struct ObjectRelationsView_Previews: PreviewProvider {
    static var previews: some View {
        ObjectRelationsView(viewModel: ObjectRelationsViewModel())
    }
}
