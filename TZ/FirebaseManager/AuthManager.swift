//
//  AuthManager.swift
//  TZ
//
//  Created by Vladyslav Behim on 07.09.2025.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase


final class AuthManager: ObservableObject {
    static let shared = AuthManager()
    @Published var user: User?
    
    private var handle: AuthStateDidChangeListenerHandle?
    
    private init() {
        handle = Auth.auth().addStateDidChangeListener { [weak self] _, fbUser in
            self?.user = fbUser
        }
    }
    
    func signInAnonymously(completion: @escaping (Result<User, Error>) -> Void) {
        Auth.auth().signInAnonymously { authResult, error in
            if let err = error { completion(.failure(err)); return }
            guard let u = authResult?.user else { completion(.failure(NSError(domain:"Auth", code:-1))); return }
            completion(.success(u))
        }
    }
    
    func signOut() throws {
        try Auth.auth().signOut()
    }
    
    func deleteAccount(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let user = Auth.auth().currentUser else { completion(.failure(NSError(domain:"Auth", code:-1))); return }
        user.delete { error in
            if let err = error { completion(.failure(err)); return }
            completion(.success(()))
        }
    }
}
