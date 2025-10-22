//
//  CustomTabBar.swift
//  PDF Converter
//
//  Created by Alexander Abanshin on 21.10.2025.
//

import SwiftUI

struct CustomTabBar: View {
    var action: () -> Void

    var body: some View {
        Rectangle()
            .frame(height: 1)
            .foregroundColor(Color.white.opacity(0.5)) 
            .edgesIgnoringSafeArea(.horizontal)
        
        HStack {
            Spacer()
            Button(action: action) {
                Image(systemName: "plus.circle.fill")
                    .resizable()
                    .frame(width: 60, height: 60)
                    .foregroundColor(.blue)
                    .shadow(radius: 4)
            }
            Spacer()
        }
        .frame(height: 80)
        .background(Color(.systemGray6))
    }
}

#Preview {
    CustomTabBar(action: {})
}
