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
		List {
			ForEach(content, id: \.self) { publicKey in
				Button(action: {
					self.selection = self.content.firstIndex(of: publicKey) ?? 0
				}) {
					HStack {
						Text(publicKey).foregroundColor(Color.black)
						Spacer()
						if self.selection == self.content.firstIndex(of: publicKey) {
							Image(systemName: "checkmark").foregroundColor(.gray)
						}
					}
				}
			}.onDelete(perform: delete)
		}
		.navigationBarItems(trailing: EditButton())
		.listStyle(GroupedListStyle())
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
			return PickerDetailView(content: .constant(model), selection: .constant(0))
		}
	}
}
#endif
