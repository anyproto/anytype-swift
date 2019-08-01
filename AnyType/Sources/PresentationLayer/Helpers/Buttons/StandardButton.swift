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
	var text: String
	var style: StandardButtonStyle
	var action: StandardButtonAction

	var body: some View {
		Button(action: {
			self.action()
		}) {
			Text(text).font(.headline).foregroundColor(style.textColor()).frame(minWidth: 0, maxWidth: .infinity)
		}.padding(.all).background(style.backgroundColor()).cornerRadius(7)
	}
}

#if DEBUG
struct StandardButton_Previews: PreviewProvider {
    static var previews: some View {
		StandardButton(text: "Standard button", style: .yellow, action: {})
    }
}
#endif
