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
            SettingsView().tabItem { Label("Settings", systemImage: "gear") }
        }
    }
}

#Preview {
    MainTabView()
}
