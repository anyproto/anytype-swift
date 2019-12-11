//
//  LocalRepoService.swift
//  AnyType
//
//  Created by Denis Batvinkin on 11.12.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//


/// Protocol provides local paths where user data stored
protocol LocalRepoServiceProtocol {
    /// Returns local path to middleware files
    var middlewareRepoPath: String { get }
    
    /// Returns path to dir with cashed images (for example user avatar)
    var imagePath: String { get }
}


class LocalRepoService: LocalRepoServiceProtocol {
    
    var middlewareRepoPath: String {
        return getDocumentsDirectory().appendingPathComponent("middleware-go").path
    }
    
    var imagePath: String {
        return getDocumentsDirectory().appendingPathComponent("images").path
    }
}
