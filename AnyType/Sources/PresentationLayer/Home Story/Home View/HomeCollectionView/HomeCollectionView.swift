//
//  HomeCollectionView.swift
//  AnyType
//
//  Created by Denis Batvinkin on 11.09.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import SwiftUI

enum HomeCollectionViewCellType: CaseIterable {
	case plus
	case document
}

enum HomeCollectionViewSection {
	case main
}

struct HomeCollectionItemModel: Hashable {
	let id = UUID()
	
	var name: String
}

struct HomeCollectionView: UIViewRepresentable {
	
	func makeCoordinator() -> HomeCollectionView.Coordinator {
		Coordinator()
	}
	
	func makeUIView(context: Context) -> UICollectionView {
		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
		collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "HomeCollectionCell")
		
		let dataSource = UICollectionViewDiffableDataSource<HomeCollectionViewSection, HomeCollectionItemModel>(collectionView: collectionView) { collectionView, indexPath, myModelObject in
			
			let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeCollectionCell", for: indexPath)
            cell.backgroundColor = .red

            return cell
		}
		populate(dataSource: dataSource)
		context.coordinator.dataSource = dataSource
		
		return collectionView
	}
	
	func updateUIView(_ uiView: UICollectionView, context: Context) {
		
	}
	
	private func populate(dataSource: UICollectionViewDiffableDataSource<HomeCollectionViewSection, HomeCollectionItemModel>) {
        var snapshot = NSDiffableDataSourceSnapshot<HomeCollectionViewSection, HomeCollectionItemModel>()
        snapshot.appendSections([.main])
        snapshot.appendItems([HomeCollectionItemModel(name: "test1"), HomeCollectionItemModel(name: "test2"), HomeCollectionItemModel(name: "test3")])
        dataSource.apply(snapshot)
    }
	
	private func createCollectionLayout() -> UICollectionViewLayout {
		let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
		let item = NSCollectionLayoutItem(layoutSize: itemSize)
		let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(44.0))
		let group = NSCollectionLayoutGroup(layoutSize: groupSize)
		let section = NSCollectionLayoutSection(group: group)
		let layout = UICollectionViewCompositionalLayout(section: section)
		
		return layout
	}
	
	
	final class Coordinator: NSObject {
		var dataSource: UICollectionViewDiffableDataSource<HomeCollectionViewSection, HomeCollectionItemModel>?
    }
}


