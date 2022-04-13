//
//  WaitingPopupView.swift
//  Anytype
//
//  Created by Denis Batvinkin on 12.04.2022.
//  Copyright © 2022 Anytype. All rights reserved.
//

import SwiftUI

struct WaitingPopupView: View {
    let text: String

    var body: some View {
        VStack(spacing: 0) {
            Spacer.fixedHeight(15)
            AnytypeText(text, style: .uxCalloutRegular, color: .textPrimary)
            Spacer.fixedHeight(13)
            ProgressBar(showAnimation: true)
            Spacer.fixedHeight(20)
        }
        .padding(.horizontal, 20)
        .background(Color.backgroundPrimary)
        .cornerRadius(16)
    }
}

struct WaitingPopupView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.blue
            DashboardLoadingAlert(text: "Progress...".localized)
        }
    }
}
