//
//  ContentView.swift
//  TZ
//
//  Created by Vladyslav Behim on 07.09.2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject var auth = AuthManager.shared
    @StateObject var db = DatabaseManager.shared
    
    var body: some View {
        Group{
            if auth.user == nil{
                AuthView()
            }else{
                if db.player == nil{
                    ProgressView("Loading player...")
                        .onAppear(perform: {
                            db.createUserIfNeeded(username: "Test") { res in
                                switch res {
                                case .success(_):
                                    print("OK")
                                case .failure(let failure):
                                    print(failure)
                                }
                            }
                        })
                }else{
                    VStack{
                        Text("All good")
                    }
                }
            }
        }
    }
}


#Preview {
    ContentView()
}
