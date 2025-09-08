//
//  RatingView.swift
//  TZ
//
//  Created by Vladyslav Behim on 08.09.2025.
//

import SwiftUI
import FirebaseFirestore

struct RatingView: View {
    @State private var top: [Player] = []
    var body: some View {
        NavigationView{
            List {
                ForEach(top.indices, id:\.self) { i in
                    HStack {
                        Text("\(i+1).")
                        Text(top[i].username)
                        Spacer()
                        VStack(alignment:.trailing){
                            Text("coins : \(top[i].chips)")
                            Text("win rate: \(String(format: "%.2f", top[i].winRate))")
                        }
                    }
                }
            }
            .onAppear(perform: loadTop)
            .navigationTitle("Ratings")

        }
        
    }
    
    func loadTop() {
        let db = Firestore.firestore()
        db.collection("users")
            .order(by: "chips", descending: true)
            .limit(to: 50)
            .getDocuments { querySnapshot, error in
                var arr: [Player] = []
                if let documents = querySnapshot?.documents {
                    for doc in documents {
                        let dict = doc.data()
                        if let data = try? JSONSerialization.data(withJSONObject: dict),
                           let p = try? JSONDecoder().decode(Player.self, from: data) {
                            arr.append(p)
                        }
                    }
                }
                top = arr.sorted { $0.chips > $1.chips }
            }
    }
}

#Preview {
    RatingView()
}
