//
//  StandardButton.swift
//  AnyType
//
//  Created by Denis Batvinkin on 29.07.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import SwiftUI

typealias StandardButtonAction = () -> Void

enum StandardButtonStyle {
	case yellow
	case black
	
	func backgroundColor() -> Color {
		switch self {
		case .black:
			return Color.black
		case .yellow:
			return Color.yellow
		}
	}
	
	func textColor() -> Color {
		switch self {
		case .black:
			return Color.white
		case .yellow:
			return Color.black
		}
	}
}

struct StandardButton: View {
	@Binding var disabled: Bool
	var text: String
	var style: StandardButtonStyle
	var action: StandardButtonAction
	
	var body: some View {
		Button(action: {
			self.action()
		}) {
			Text(text).font(.headline)
				.padding(.all)
				.foregroundColor(disabled ? Color.gray : style.textColor())
				.frame(minWidth: 0, maxWidth: .infinity)
				.background(style.backgroundColor())
				.cornerRadius(7)
		}
		.disabled(disabled)
	}
}

#if DEBUG
struct StandardButton_Previews: PreviewProvider {
    static var previews: some View {
		StandardButton(disabled: .constant(false) ,text: "Standard button", style: .yellow, action: {})
    }
}
#endif
