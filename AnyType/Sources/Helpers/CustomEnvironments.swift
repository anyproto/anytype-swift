//
//  CustomEnvironments.swift
//  AnyType
//
//  Created by Denis Batvinkin on 11.12.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import SwiftUI


struct LocalRepoServiceKey: EnvironmentKey {
    static let defaultValue: LocalRepoService = LocalRepoService()
}

extension EnvironmentValues {
    var localRepoService: LocalRepoService {
        get {
            return self[LocalRepoServiceKey.self]
        }
        set {
            self[LocalRepoServiceKey.self] = newValue
        }
    }
}


struct AuthServiceKey: EnvironmentKey {
    static let defaultValue: AuthService = AuthService()
}

extension EnvironmentValues {
    var authService: AuthService {
        get {
            return self[AuthServiceKey.self]
        }
        set {
            self[AuthServiceKey.self] = newValue
        }
    }
}


struct IpfsFilesServiceKey: EnvironmentKey {
    static let defaultValue: IpfsFilesService = IpfsFilesService()
}

extension EnvironmentValues {
    var ipfsFilesServie: IpfsFilesService {
        get {
            return self[IpfsFilesServiceKey.self]
        }
        set {
            self[IpfsFilesServiceKey.self] = newValue
        }
    }
}

//
//  CustomEnvironments.swift
//  AnyType
//
//  Created by Denis Batvinkin on 28.11.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import SwiftUI


struct ShowViewFramesKey: EnvironmentKey {
    static let defaultValue: Bool = false
}

extension EnvironmentValues {
    var showViewFrames: Bool {
        get {
            return self[ShowViewFramesKey.self]
        }
        set {
            self[ShowViewFramesKey.self] = newValue
        }
    }
}
