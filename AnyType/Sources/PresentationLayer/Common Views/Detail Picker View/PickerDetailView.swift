//
//  PickerDetailView.swift
//  AnyType
//
//  Created by Denis Batvinkin on 05.08.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import SwiftUI

struct PickerDetailView: View {
	@Binding var content: [String]
	@Binding var selection: Int
	
	var body: some View {
		Form {
			List {
				ForEach(0 ..< content.count) { index in
					Button(action: {
						self.selection = index
					}) {
						HStack {
							Text(self.content[index]).foregroundColor(Color.black)
							Spacer()
							if self.selection == index {
								Image(systemName: "checkmark").foregroundColor(.gray)
							}
						}
					}
				}.onDelete(perform: delete)
			}
			.navigationBarItems(trailing: EditButton())
		}
	}
	
	private func delete(at offsets: IndexSet) {
		content.remove(atOffsets: offsets)
	}
}

#if DEBUG
struct PickerDetailView_Previews: PreviewProvider {
	static var previews: some View {
		let model = ["public key 1", "public key 2", "public key 3"]
		
		return NavigationView {
			PickerDetailView(content: .constant(model), selection: .constant(0))
		}
	}
}
#endif
