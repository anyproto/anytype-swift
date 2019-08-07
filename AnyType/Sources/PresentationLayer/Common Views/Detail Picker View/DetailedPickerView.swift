//
//  DetailedPickerView.swift
//  AnyType
//
//  Created by Denis Batvinkin on 05.08.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import SwiftUI


struct DetailedPickerView: View {
	let title: Text
	@State var content: [String]
	@Binding var selected: Int {
		didSet {
			let isValidIndex = content.indices.contains(selected)
			
			if !isValidIndex {
				selected = 0
			}
		}
	}
	
    var body: some View {
		VStack(alignment: .leading, spacing: 0) {
			title
			
			if !content.isEmpty {
				NavigationLink(destination: PickerDetailView(content: $content, selection: $selected)) {
					HStack {
						Text(content[selected]).foregroundColor(.gray)
						Spacer()
						Image(systemName: "chevron.right").foregroundColor(.gray)
					}
				}
			}
		}
    }
}

#if DEBUG
struct DetailPickerView_Previews: PreviewProvider {
    static var previews: some View {
		let model = ["public key 1", "public key 2", "public key 3"]
		return DetailedPickerView(title: Text("Accounts"), content: model, selected: .constant(0))
    }
}
#endif
