//
//  NavigationButtonView.swift
//  AnyType
//
//  Created by Denis Batvinkin on 27.08.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import SwiftUI

struct NavigationButtonView: View {
	@Binding var disabled: Bool
	var text: String
	var style: StandardButtonStyle
	
    var body: some View {
		Text(text)
			.font(.headline)
			.padding(.all)
			.foregroundColor(disabled ? Color.gray : style.textColor())
			.frame(minWidth: 0, maxWidth: .infinity)
			.background(style.backgroundColor())
			.cornerRadius(7)
			.disabled(disabled)
    }
}

struct NavigationButtonView_Previews: PreviewProvider {
    static var previews: some View {
		NavigationButtonView(disabled: .constant(false), text: "Navigation Button", style: .yellow)
    }
}
