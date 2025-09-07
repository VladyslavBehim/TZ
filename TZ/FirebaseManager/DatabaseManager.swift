//
//  DatabaseManager.swift
//  TZ
//
//  Created by Vladyslav Behim on 07.09.2025.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth


final class DatabaseManager : ObservableObject {
    @Published var player: Player?
    static let shared = DatabaseManager()
    private let db = Firestore.firestore()
    private var uid: String? { Auth.auth().currentUser?.uid }
    
    func createUserIfNeeded(username: String = "Player", completion: @escaping (Result<Void, Error>) -> Void) {
          guard let uid = uid else { completion(.failure(NSError(domain:"DB", code:-1))); return }
          let ref = db.collection("users").document(uid)
          ref.getDocument { document, error in
              if let error = error {
                  completion(.failure(error))
                  return
              }
              if let document = document, document.exists {
                  self.fetchPlayer(completion: completion)
              } else {
                  let newPlayer = Player(username: username, chips: 2000, wins: 0, losses: 0, totalSpins: 0, winRate: 0.0)
                  do {
                      let data = try JSONEncoder().encode(newPlayer)
                      let dict = try JSONSerialization.jsonObject(with: data) as? [String:Any] ?? [:]
                      ref.setData(dict) { error in
                          if let e = error { completion(.failure(e)); return }
                          self.player = newPlayer
                          completion(.success(()))
                      }
                  } catch {
                      completion(.failure(error))
                  }
              }
          }
      }
    func fetchPlayer(completion: @escaping (Result<Void, Error>) -> Void = {_ in}) {
           guard let uid = uid else { completion(.failure(NSError(domain:"DB", code:-1))); return }
           let ref = db.collection("users").document(uid)
           ref.getDocument { snapshot, error in
               if let error = error {
                   completion(.failure(error))
                   return
               }
               guard let data = snapshot?.data() else { completion(.failure(NSError(domain:"DB", code:-1))); return }
               do {
                   let jsonData = try JSONSerialization.data(withJSONObject: data)
                   let p = try JSONDecoder().decode(Player.self, from: jsonData)
                   DispatchQueue.main.async { self.player = p; completion(.success(())) }
               } catch {
                   completion(.failure(error))
               }
           }
       }
    func updatePlayer(_ player: Player, completion: ((Error?)->Void)? = nil) {
           guard let uid = uid else { completion?(NSError(domain:"DB", code:-1)); return }
           let ref = db.collection("users").document(uid)
           do {
               let data = try JSONEncoder().encode(player)
               let dict = try JSONSerialization.jsonObject(with: data) as? [String:Any] ?? [:]
               ref.setData(dict) { error in completion?(error) }
           } catch {
               completion?(error)
           }
       }
       
       func deletePlayerDB(completion: @escaping (Error?)->Void) {
           guard let uid = uid else { completion(NSError(domain:"DB", code:-1)); return }
           db.collection("users").document(uid).delete(completion: { error in completion(error) })
       }
       
}
