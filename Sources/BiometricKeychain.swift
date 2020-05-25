//
//  BiometricKeychain.swift
//  KeychainWrapperX
//
//  Created by Prashant Shrestha on 5/25/20.
//  Copyright © 2020 Inficare. All rights reserved.
//

import Foundation
import KeychainAccess

public typealias Credential = String
public typealias BiometricKeychainResult = (Result<Credential, Error>) -> Void

public protocol BiometricKeychain {
    func updateCredential(_ credential: String, for key: String, with authenticationPrompt: String?, completion: @escaping BiometricKeychainResult)
    func getCredential(for key: String, with authenticationPrompt: String?, completion: @escaping BiometricKeychainResult)
    func deleteCredential(for key: String, completion: @escaping BiometricKeychainResult)
    func contains(key: String) -> Bool
    
}

fileprivate struct KeychainConstant {
    static let serviceName = Bundle.main.bundleIdentifier.map({ "\($0).user-credential" }) ?? Bundle.init(for: BiometricKeychainImpl.self).bundleIdentifier.map({ "\($0).user-credential" }) ?? "com.biometricX.keychain"
}

public class BiometricKeychainAccess {
    static var keychain: BiometricKeychain = BiometricKeychainImpl()
}


class BiometricKeychainImpl: BiometricKeychain {
    private let keychain: Keychain
    
    init() {
        self.keychain = Keychain(service: KeychainConstant.serviceName)
        
        if UserDefaults.standard.bool(forKey: KeychainConstant.serviceName) == false {
            try? self.deleteAll()
            UserDefaults.standard.set(true, forKey: KeychainConstant.serviceName)
        }
    }
    
    func updateCredential(_ credential: String, for key: String, with authenticationPrompt: String?, completion: @escaping BiometricKeychainResult) {
        DispatchQueue.global().async {
            do {
                var keychain =  self.keychain
                if #available(iOS 11.3, *) {
                    keychain = keychain.accessibility(.whenUnlockedThisDeviceOnly, authenticationPolicy: .biometryCurrentSet)
                } else {
                    keychain = keychain.accessibility(.whenUnlockedThisDeviceOnly, authenticationPolicy: .userPresence)
                }
                
                if try keychain.contains(key) == true {
                    keychain = keychain.authenticationPrompt(authenticationPrompt ?? "Authenticate to update your credential")
                }
                
                try keychain
                    .set(credential,
                         key: key)
                DispatchQueue.main.async {
                    completion(.success("true"))
                }
            }
            catch let error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    func getCredential(for key: String, with authenticationPrompt: String?, completion: @escaping BiometricKeychainResult) {
        DispatchQueue.global().async {
            do {
                guard try self.keychain.contains(key) == true,
                    let credential = try self.keychain.authenticationPrompt(authenticationPrompt ?? "Authenticate to login to your account").get(key) else {
                    completion(.failure(NSError(domain: "Biometric Keychain", code: -1, userInfo: [NSLocalizedDescriptionKey: "Fetching credential failed"])))
                    return
                }
                DispatchQueue.main.async {
                    completion(.success(credential))
                }
            }
            catch let error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    func deleteCredential(for key: String, completion: @escaping BiometricKeychainResult) {
        DispatchQueue.global().async {
            do {
                guard try self.keychain.contains(key) == true else {
                    completion(.failure(NSError(domain: "Biometric Keychain", code: -1, userInfo: [NSLocalizedDescriptionKey: "Keychain credential not found"])))
                    return
                }
                try self.keychain.remove(key)
                DispatchQueue.main.async {
                    completion(.success("true"))
                }
            }
            catch let error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    func contains(key: String) -> Bool {
        return keychain.allKeys().contains(key)
    }
    
    private func deleteAll() throws {
        try keychain.allKeys().forEach { (key) in
            try keychain.remove(key)
        }
    }
}
