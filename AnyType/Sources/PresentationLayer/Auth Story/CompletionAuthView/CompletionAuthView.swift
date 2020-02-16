//
//  CompletionAuthView.swift
//  AnyType
//
//  Created by Denis Batvinkin on 03.12.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import SwiftUI

protocol CompletionAuthViewDelegate: class {
    func showDashboardDidTap()
}

struct CompletionAuthView: View {
    // TODO: move creating to assembly. Move coordinator to viewModel
    @State var viewModel: CompletionAuthViewModel
    weak var delegate: CompletionAuthViewDelegate?
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradients.LoginBackground.gradient, startPoint: .top, endPoint: .bottom)
            .edgesIgnoringSafeArea(.all)
            VStack {
                Spacer()
                VStack(alignment: .leading, spacing: 0) {
                    ImageWithCircleBackgroundView(imageName: "congrats", backgroundColor: Color("backgroundColor"))
                        .frame(width: 64, height: 64)
                    Text("Congratulations!")
                        .fontWeight(.bold)
                        .padding(.top, 16)
                    Text("CongratulationDescription")
                        .padding(.top, 10)
                    StandardButton(disabled: false, text: "Let’s start!", style: .yellow) {
                        self.delegate?.showDashboardDidTap()
                    }
                    .padding(.top, 18)
                }
                .padding([.leading, .trailing, .top], 20)
                .padding(.bottom, 16)
                .background(Color.white)
                .cornerRadius(12)
            }
            .padding()
        }
    }
}

struct CompletionAuthView_Previews: PreviewProvider {
    static var previews: some View {
        CompletionAuthView(viewModel: CompletionAuthViewModel(), delegate: nil)
    }
}
