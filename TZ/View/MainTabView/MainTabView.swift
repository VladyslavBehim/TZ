//
//  MainTabView.swift
//  TZ
//
//  Created by Vladyslav Behim on 07.09.2025.
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            GameView().tabItem { Label("Game", systemImage: "dice.fill") }
            RatingView().tabItem { Label("Rating", systemImage: "trophy.fill") }
            SettingsView().tabItem { Label("Settings", systemImage: "gearshape.fill") }
        }
    }
}

#Preview {
    MainTabView()
}
