//
//  ErrorAlertView.swift
//  AnyType
//
//  Created by Denis Batvinkin on 15.08.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import SwiftUI

struct ErrorAlertView<Presenting>: View where Presenting: View {
	@Binding var isShowing: Bool
	@Binding var errorText: String
	
	let presenting: Presenting
	
    var body: some View {
		GeometryReader { geometry in
			ZStack(alignment: .center) {
				self.presenting.blur(radius: self.isShowing ? 1 : 0)
				
				VStack() {
					Spacer()
					
					Text(self.errorText)
						.foregroundColor(Color.white)
						.padding()
					
					Spacer()
					
					VStack(spacing: 0) {
						Divider().background(Color.white)
						Button(action: {
							self.isShowing.toggle()
						}) {
							Text("Ok")
								.foregroundColor(Color("GrayText"))
								.padding()
						}
					}
				}
				.frame(width: geometry.size.width * 0.8, height: geometry.size.height * 0.25)
				.background(Color("BrownMenu"))
				.cornerRadius(10)
				.transition(.slide)
				.opacity(self.isShowing ? 1 : 0)
			}
		}
    }
}

#if DEBUG
struct ErrorAlertView_Previews: PreviewProvider {
    static var previews: some View {
		let view = VStack {
			Text("ParentView")
		}
		return ErrorAlertView(isShowing: .constant(true), errorText: .constant("Some Error"), presenting: view)
    }
}
#endif
