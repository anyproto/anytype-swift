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


struct AddedScrollViewOffsetKey: EnvironmentKey {
    static let defaultValue: CGPoint = .zero
}

extension EnvironmentValues {
    var addedScrollViewOffset: CGPoint {
        get {
            return self[AddedScrollViewOffsetKey.self]
        }
        set {
            self[AddedScrollViewOffsetKey.self] = newValue
        }
    }
}


struct TimingTimerKey: EnvironmentKey {
    static let defaultValue: TimingTimer = TimingTimer()
}

extension EnvironmentValues {
    var timingTimer: TimingTimer {
        get {
            return self[TimingTimerKey.self]
        }
        set {
            self[TimingTimerKey.self] = newValue
        }
    }
}

struct DeveloperOptionsKey: EnvironmentKey {
    static let defaultValue: DeveloperOptions.Service = .init()
}

extension EnvironmentValues {
    var developerOptions: DeveloperOptions.Service {
        get {
            return self[DeveloperOptionsKey.self]
        }
        set {
            self[DeveloperOptionsKey.self] = newValue
        }
    }
}

struct KeychainStoreServiceKey: EnvironmentKey {
    static let defaultValue: KeychainStoreService = .init()
}

extension EnvironmentValues {
    var keychainStoreService: KeychainStoreService {
        get {
            return self[KeychainStoreServiceKey.self]
        }
        set {
            self[KeychainStoreServiceKey.self] = newValue
        }
    }
}
