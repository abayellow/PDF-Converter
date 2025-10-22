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
        VStack(spacing: 0) {
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color.white.opacity(0.3))
                .edgesIgnoringSafeArea(.horizontal)

            HStack {
                Spacer()
                Button(action: action) {
                    ZStack {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 60, height: 60)
                            .shadow(radius: 5)

                        Image(systemName: "plus")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                Spacer()
            }
            .frame(height: 80)
            .background(Color(.systemGray6))
        }
    }
}

#Preview {
    CustomTabBar(action: {})
}

