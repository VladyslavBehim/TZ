//
//  GameView.swift
//  TZ
//
//  Created by Vladyslav Behim on 07.09.2025.
//

// GameView.swift

import SwiftUI

enum BetType : Equatable{
    case number(Int)
    case red
    case black
    case odd
    case even
}

struct GameView: View {
    @EnvironmentObject var db: DatabaseManager
    @State private var selectedNumber: Int? = nil
    @State private var selectedBetType: BetType? = nil
    @State private var betAmount: Int = 10
    @State private var lastSpinResult: Int? = nil
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var step: Int {
        max(1, (db.player?.chips ?? 0) / 10)
    }
    
    func getColor(number: Int, betType: BetType?) -> Color {
        switch betType {
        case .red:
            return isRed(number) ? Color.red : Color.gray.opacity(0.2)
        case .black:
            return !isRed(number) && number != 0 ? Color.black : Color.gray.opacity(0.2)
        case .odd:
            return number != 0 && number % 2 == 1 ? Color.red : Color.gray.opacity(0.2)
        case .even:
            return number != 0 && number % 2 == 0 ? Color.black : Color.gray.opacity(0.2)
        case .number(let n):
            return number == n ? Color.blue.opacity(0.7) : Color.gray.opacity(0.2)
        case .none:
            return isRed(number) ? Color.red.opacity(0.5) : Color.black.opacity(0.5)
        }
    }
    
    var body: some View {
        VStack {
            HStack {
                Text("Player: \(db.player?.username ?? "—")")
                Spacer()
                Text("Coins: \(db.player?.chips ?? 0)")
            }.padding()
            
            Divider()
            
            let columns = Array(repeating: GridItem(.flexible()), count: 6)
            ScrollView {
                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach(0...36, id: \.self) { n in
                        Button(action: {
                            withAnimation(.default) {
                                selectedNumber = n
                                selectedBetType = .number(n)
                            }
                            
                        }) {
                            Text("\(n)")
                                .frame(maxWidth: .infinity, minHeight: 44)
                                .background(getColor(number: n, betType: selectedBetType))
                                .cornerRadius(8)
                                .animation(.default)
                        }
                    }
                }.padding()
            }
            
            HStack {
                Button("Red") { selectedBetType = .red; selectedNumber = nil }
                Spacer()
                Button("Black") { selectedBetType = .black; selectedNumber = nil }
                Spacer()
                Button("Odd") { selectedBetType = .odd; selectedNumber = nil }
                Spacer()
                Button("Even") { selectedBetType = .even; selectedNumber = nil }
            }.padding()
            
            HStack {
                Text("Bet: \(betAmount)")
                Spacer()
                Stepper("", value: $betAmount, in: 1...max(1, db.player?.chips ?? 1), step: step)
                    .labelsHidden()
                Button {
                    betAmount = db.player?.chips ?? 0
                } label: {
                    Text("max")
                }

                
            }.padding()
            
            Button("Spin") {
                spin()
            }.padding()
            
            if let r = lastSpinResult {
                Text("Last spin: \(r)")
                    .padding()
            }
            
            Spacer()
        }
        .onAppear {
            if db.player == nil { db.fetchPlayer() }
            if let player = db.player {
                betAmount = max(1, player.chips > 0 ? min(10, player.chips/10) : 1)
            }
            
        }
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("Result"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
    
    func isRed(_ n: Int) -> Bool {
        let redSet: Set<Int> = [1,3,5,7,9,12,14,16,18,19,21,23,25,27,30,32,34,36]
        return redSet.contains(n)
    }
    
    func spin() {
        guard var player = db.player else { return }
        let chips = player.chips
        guard chips >= betAmount else {
            alertMessage = "Not enough coins"
            showingAlert = true
            return
        }
        player.chips -= betAmount
        let result = Int.random(in: 0...36)
        lastSpinResult = result
        var win = 0
        
        if let bet = selectedBetType {
            switch bet {
            case .number(let n):
                if n == result { win = betAmount * 35 + betAmount } // returns bet + winnings
            case .red:
                if result != 0 && isRed(result) { win = betAmount * 1 + betAmount }
            case .black:
                if result != 0 && !isRed(result) { win = betAmount * 1 + betAmount }
            case .odd:
                if result != 0 && result % 2 == 1 { win = betAmount * 1 + betAmount }
            case .even:
                if result != 0 && result % 2 == 0 { win = betAmount * 1 + betAmount }
            }
        } else {
            if let sel = selectedNumber, sel == result {
                win = betAmount * 35 + betAmount
            }
        }
        
        if win > 0 {
            player.chips += win
            player.wins += 1
            alertMessage = "You won \(win - betAmount) coins! (Returned \(win))"
        } else {
            player.losses += 1
            alertMessage = "You lost \(betAmount) coins."
        }
        player.totalSpins += 1
        player.winRate = player.totalSpins > 0 ? Double(player.wins) / Double(player.totalSpins) : 0.0
        
        if player.chips <= 0 {
            player.chips += 100
            alertMessage += "\nBalance was 0 — you got +100 coins to continue."
        }
        db.player = player
        DatabaseManager.shared.updatePlayer(player) { error in
            if let e = error {
                print("DB update err: \(e)")
            }
        }
        
        showingAlert = true
    }
}

#Preview {
    GameView()
}
