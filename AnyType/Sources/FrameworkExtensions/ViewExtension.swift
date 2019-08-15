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
}
