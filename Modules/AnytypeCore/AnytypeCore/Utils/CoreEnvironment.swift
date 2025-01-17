import Foundation
import AppTarget

// Configurations problem.
// SPM allow only two configurations: debug and release.
// If build name contains Debug - this is debug build.
// Other flags from Xcode configuration don't pass to SPM.
// This means `#if DEBUG` will work only in SPM debug build.
// https://forums.swift.org/t/annoying-limitation-of-packagedescription-buildconfiguration/56037/6
// https://github.com/apple/swift/issues/58321

// Dsym problem.
// Xcode generated Dsym for local packages only in Release configuration. DEBUG_INFORMATION_FORMAT isn't used.😬
// External dependencies don't have this problem. There are contains in App.dsym file.
// We should to use configuration with "Release" name for generate Dsyms in nightly buils for local packages.

// We can't use `#if DEBUG` and generate Dsyms at the same time for local packages 😭.
// One of solution - crate 'Release' build and pass debug flags to package.
// Other solution. Allow for debug configuration dsyms in each local package. But this desition will slow down local builds.

// Check it in feature XCode versions. Maybe it will be fixed.

// Temporary solution - setup environment from main target.
// In the main target, always use #if. This way, the compiler will cut out unused code.
public enum CoreEnvironment {
    
    private static let targetTypeStorage = AtomicStorage(AppTargetType.debug)
    public static var targetType: AppTargetType  {
        get { targetTypeStorage.value }
        set { targetTypeStorage.value = newValue }
    }
    
    public static var isSimulator: Bool {
        #if targetEnvironment(simulator)
          return true
        #else
          return false
        #endif
    }
}
