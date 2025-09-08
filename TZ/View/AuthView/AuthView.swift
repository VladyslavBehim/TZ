//
//  AuthView.swift
//  TZ
//
//  Created by Vladyslav Behim on 07.09.2025.
//

import SwiftUI

struct AuthView: View {
    @State private var loading = false
    @State private var userName = ""
    @State private var showNextView : Bool = false
    @EnvironmentObject var db: DatabaseManager

    var body: some View {
        VStack(spacing: 20) {
            Text("Welcome to Roulette")
                .font(.largeTitle).bold()
            if !self.showNextView{
                TextField("Enter your name", text: $userName)
                    .padding()
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                Button {
                    withAnimation(.default) {
                        self.showNextView = true
                    }
                } label: {
                    Text("Next page")
                        .padding()
                        .frame(maxWidth:.infinity , alignment:.center)
                        .background(self.userName.isEmpty ? Color(.systemGray6) : Color.orange)
                        .foregroundStyle(self.userName.isEmpty ? Color(.systemGray) : Color.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .fontWeight(.bold)

                }
                .disabled(self.userName.isEmpty)

            }else{
                Button {
                    loading = true
                    AuthManager.shared.signInAnonymously { result in
                        DispatchQueue.main.async { loading = false }
                    }
                    db.nameOfUser = userName
                } label: {
                    Text("Play as \(self.userName)")
                    .padding()
                    .frame(maxWidth:.infinity , alignment:.center)
                    .background(Color.orange)
                    .foregroundStyle(Color.primary)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .fontWeight(.bold)
                }
                .disabled(loading)
                .transition(.move(edge: .leading))

            }
            
        }
        .padding()
    }
}

#Preview {
    AuthView()
}
