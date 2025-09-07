//
//  SettingButton.swift
//  TZ
//
//  Created by Vladyslav Behim on 07.09.2025.
//

import SwiftUI

struct SettingButton: View {
    @State var iconOfButton : String
    @State var text : String
    @State var color: Color
    var action: () -> Void
    var body: some View {
        Button {
            action()
        } label: {
            HStack{
                Image(systemName: "\(iconOfButton)")
                    .frame(width: 13 ,height: 13)
                    .padding(.all , 10)
                    .background(color)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                Text("\(text)")
                    .foregroundStyle(Color.primary)
                    .fontWeight(.semibold)
                Spacer()
            }
            .padding(.vertical , 7)
        }
    }
}

//
//#Preview {
//    SettingButton(iconOfButton: "trash", text: "Remove account", action: {})
//}

#Preview {
    SettingsView()
}
