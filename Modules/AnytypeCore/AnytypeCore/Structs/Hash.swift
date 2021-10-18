//
//  Hash.swift
//  AnytypeCore
//
//  Created by Konstantin Mordan on 06.10.2021.
//

public struct Hash: Hashable {
    
    public let value: String
    
    // MARK: - Initializer
    
    public init?(_ value: String?) {
        guard let value = value?.trimmed, value.isNotEmpty else {
            return nil
        }
        
        self.value = value
    }
}
