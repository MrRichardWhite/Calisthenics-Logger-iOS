//
//  HeaderView.swift
//  Calisthenics Logger
//
//  Created by Richard Weiss on 27.09.23.
//

import SwiftUI

struct HeaderView: View {
    let title: String
    let subtitle: String
    let background: Color

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 0)
                .foregroundColor(background)
            
            VStack {
                Text(title)
                    .font(.system(size: 30))
                    .foregroundColor(Color.white)
                    .bold()
                Text(subtitle)
                    .font(.system(size: 20))
                    .foregroundColor(Color.white)
            }
            .padding(.top, 50)
        }
        .frame(height: 150)
    }
}

#Preview {
    HeaderView(
        title: "Title",
        subtitle: "Subtitle",
        background: .yellow
    )
}
