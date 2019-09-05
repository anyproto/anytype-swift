//
//  ArrayExtension.swift
//  AnyType
//
//  Created by Denis Batvinkin on 03.09.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

extension Array where Element: Equatable {
	
	/// Add to array only uniq element
	/// - Parameter newElement: new element
	mutating func appendUniq(_ newElement: Element) {
		if !self.contains(newElement) {
			self.append(newElement)
		}
	}
}
