/// Copyright (c) 2018 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import Foundation

protocol SecureStoreQueryable {
	var query: [String: Any] { get }
}

struct GenericPasswordQueryable {
	let service: String
	let accessGroup: String?
	let account: String
	let password: String?
	let keyChainPassword: String?
	
	init(account: String, service: String, accessGroup: String? = nil, password: String? = nil, keyChainPassword: String? = nil) {
		self.service = service
		self.accessGroup = accessGroup
		self.account = account
		self.password = password
		self.keyChainPassword = keyChainPassword
	}
	
	fileprivate func getPwSecAccessControl() -> SecAccessControl {
        var access: SecAccessControl?
        var error: Unmanaged<CFError>?
        
        access = SecAccessControlCreateWithFlags(nil,
            kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
			[.biometryAny, .applicationPassword],
            &error)
        precondition(access != nil, "SecAccessControlCreateWithFlags failed")
        
		return access!
    }
}

extension GenericPasswordQueryable: SecureStoreQueryable {
	public var query: [String: Any] {
		var query: [String: Any] = [:]
		query[String(kSecClass)] = kSecClassGenericPassword
		query[String(kSecAttrService)] = service
		query[String(kSecAttrAccount)] = account
		// Access group if target environment is not simulator
		#if !targetEnvironment(simulator)
		if let accessGroup = accessGroup {
			query[String(kSecAttrAccessGroup)] = accessGroup
		}
		
		if let password = keyChainPassword {
			let context = LAContext()
			context.setCredential(password.data(using: .utf8), type: .applicationPassword)
			
			query[String[kSecUseAuthenticationContext]] = context
			query[String(kSecAttrAccessControl)] = getPwSecAccessControl()
			
		}
		
		#endif
		return query
	}
}

struct InternetPasswordQueryable {
	let server: String
	let port: Int
	let path: String
	let securityDomain: String
	let internetProtocol: InternetProtocol
	let internetAuthenticationType: InternetAuthenticationType
}

extension InternetPasswordQueryable: SecureStoreQueryable {
	public var query: [String: Any] {
		var query: [String: Any] = [:]
		query[String(kSecClass)] = kSecClassInternetPassword
		query[String(kSecAttrPort)] = port
		query[String(kSecAttrServer)] = server
		query[String(kSecAttrSecurityDomain)] = securityDomain
		query[String(kSecAttrPath)] = path
		query[String(kSecAttrProtocol)] = internetProtocol.rawValue
		query[String(kSecAttrAuthenticationType)] = internetAuthenticationType.rawValue
		return query
	}
}
