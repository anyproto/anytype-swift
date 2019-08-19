//
//  SelectColorView.swift
//  AnyType
//
//  Created by Denis Batvinkin on 20.08.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import SwiftUI

struct SelectColorView: View {
	@State var colors: [Color]
	@Binding var selectedColor: Color
	
    var body: some View {
        HStack {
			ForEach(Colors.colors, id: \.self) { color in
				Circle()
					.frame(height: 50)
					.foregroundColor(color)
					.onTapGesture {
						self.selectedColor = color
				}
				.padding([.trailing, .leading], 5)
				.overlay(self.selectedColor == color ? Circle().stroke(Color.gray).padding(.all, 0) : nil)
			}
		}
    }
}

#if DEBUG
struct SelectColorView_Previews: PreviewProvider {
    static var previews: some View {
		let colors: [Color] = [.black, .gray, .yellow, .red, .purple, .blue, .green]
		return SelectColorView(colors: colors, selectedColor: .constant(.blue))
    }
}
#endif
