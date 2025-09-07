//
//  SettingsView.swift
//  TZ
//
//  Created by Vladyslav Behim on 07.09.2025.
//

import SwiftUI
import StoreKit

struct SettingsView: View {
    @EnvironmentObject var db: DatabaseManager
    @State private var showShare = false
    @State private var showConfirmDelete = false
    @State private var showConfirmLogout = false
    
    var body: some View {
        NavigationView{
            List{
                SettingButton(iconOfButton: "star.fill", text: "Rate App", color: Color.blue) {
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                        SKStoreReviewController.requestReview(in: windowScene)
                    } else {
                        SKStoreReviewController.requestReview()
                    }
                }
                SettingButton(iconOfButton: "square.and.arrow.up", text: "Share App", color: Color.orange) {
                    shareApp()
                }
                SettingButton(iconOfButton: "rectangle.portrait.and.arrow.right", text: "Log out", color: Color.red) {
                    logout()
                }
                SettingButton(iconOfButton: "person.fill.xmark", text: "Delete Account", color: Color.red) {
                    showConfirmDelete = true
                }
              
            }
            .confirmationDialog("Are you sure?", isPresented: $showConfirmDelete, titleVisibility: .visible) {
                Button("Delete account", role: .destructive) {
                    deleteAccount()
                }
                Button("Cancel", role: .cancel) {}
                    
            }
            .navigationTitle("Settings")
        }
        
    }
    
    func shareApp() {
        let url = URL(string: "https://apps.apple.com/ee/app/vocablitz/id6743963334")!
        let vc = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        let scenes = UIApplication.shared.connectedScenes
        if let windowScene = scenes.first as? UIWindowScene,
           let root = windowScene.windows.first?.rootViewController {
            root.present(vc, animated: true)
        }
    }
    
    func logout() {
        do {
            try AuthManager.shared.signOut()
        } catch {
            print("SignOut error: \(error)")
        }
    }
    
    func deleteAccount() {
        DatabaseManager.shared.deletePlayerDB { err in
            if let e = err { print("Error deleting DB: \(e)") }
            AuthManager.shared.deleteAccount { res in
                switch res {
                case .success:
                    print("Account deleted")
                case .failure(let error):
                    print("Error deleting account: \(error)")
                }
            }
        }
    }
}

#Preview {
    SettingsView()
}
