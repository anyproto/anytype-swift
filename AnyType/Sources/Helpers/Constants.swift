//
//  Constants.swift
//  AnyType
//
//  Created by Denis Batvinkin on 16.07.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import UIKit

func getDocumentsDirectory() -> URL {
	let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
	let documentsDirectory = paths[0]
	
	return documentsDirectory
}

var applicationCoordinator: ApplicationCoordinator? {
	let sceneDeleage = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate
	
	return sceneDeleage?.applicationCoordinator
}
