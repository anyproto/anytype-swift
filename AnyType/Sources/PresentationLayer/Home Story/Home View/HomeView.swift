//
//  HomeView.swift
//  AnyType
//
//  Created by Denis Batvinkin on 11.09.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import SwiftUI

struct HomeView: View {
	var documentsList = ["First", "Second", "Third", "Next", "First", "Second", "Third", "Next", "First", "Second", "Third"]
	
	var body: some View {
		VStack {
			HomeCollectionView()
		}
	}
}

struct HomeView_Previews: PreviewProvider {
	static var previews: some View {
		HomeView()
	}
}

struct DocumentItem: View {
	var name: String
	
	var body: some View {
		Text(name)
	}
}
