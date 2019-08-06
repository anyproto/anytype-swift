//
//  DetailedPickerView.swift
//  AnyType
//
//  Created by Denis Batvinkin on 05.08.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import SwiftUI


struct DetailedPickerView: View {
	let title: String
	@State var content: [String]
	@State var selected: Int {
		didSet {
			let isValidIndex = content.indices.contains(selected)
			
			if !isValidIndex {
				selected = 0
			}
		}
	}
	
    var body: some View {
		NavigationView {
			VStack(alignment: .leading, spacing: 0) {
				Text(title)
				
				if !content.isEmpty {
					NavigationLink(destination: PickerDetailView(content: $content, selection: $selected)) {
						HStack {
							Text(content[selected]).foregroundColor(.gray)
							Spacer()
							Image(systemName: "chevron.right").foregroundColor(.gray)
						}
					}
				}
			}.padding()
		}
    }
}

#if DEBUG
struct DetailPickerView_Previews: PreviewProvider {
    static var previews: some View {
		let model = ["public key 1", "public key 2", "public key 3"]
		return DetailedPickerView(title: "Accounts", content: model, selected: 0)
    }
}
#endif
