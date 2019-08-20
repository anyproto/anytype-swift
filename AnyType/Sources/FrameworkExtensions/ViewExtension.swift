//
//  ViewExtension.swift
//  AnyType
//
//  Created by Denis Batvinkin on 16.08.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import SwiftUI


extension View {
	
	func erroToast(isShowing: Binding<Bool>, errorText: Binding<String>) -> some View {
		ErrorAlertView(isShowing: isShowing, errorText: errorText, presenting: self)
	}
	
	var renderedImage: UIImage? {
		let sceneDeleage = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate
		let rect = CGRect(origin: .zero, size: CGSize(width: 320, height: 160))
		let image = sceneDeleage?.window?.rootViewController?.view.renderedImage(rect: rect)
		
		return image
	}
}
