//
//  CustomTabBar.swift
//  PDF Converter
//
//  Created by Alexander Abanshin on 21.10.2025.
//

import SwiftUI


struct CustomTabBar: View {
    var action: () -> Void
    @State private var isPressed = false

    var body: some View {
        VStack(spacing: 0) {
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color.gray.opacity(0.3))
                .edgesIgnoringSafeArea(.horizontal)

            HStack {
                Spacer()
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        isPressed = true
                    }
                    action()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        withAnimation(.spring()) { isPressed = false }
                    }
                }) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.blue.opacity(0.9), Color.blue],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(width: 60, height: 60)
                            .shadow(color: Color.black.opacity(0.2), radius: 6, x: 0, y: 3)

                        Image(systemName: "plus")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                            .shadow(color: Color.black.opacity(0.25), radius: 1, x: 0, y: 1)
                    }
                    .scaleEffect(isPressed ? 0.85 : 1)
                }
                Spacer()
            }
            .frame(height: 80)
            .background(Color(.systemGray6))
        }
    }
}

//struct CustomTabBar: View {
//    var action: () -> Void
//
//    var body: some View {
//        VStack(spacing: 0) {
//            // Верхняя разделительная линия
//            Rectangle()
//                .frame(height: 1)
//                .foregroundColor(Color.white.opacity(0.3))
//                .edgesIgnoringSafeArea(.horizontal)
//
//            // Основная панель
//            HStack {
//                Spacer()
//                Button(action: action) {
//                    ZStack {
//                        Circle()
//                            .fill(Color.blue)
//                            .frame(width: 60, height: 60)
//                            .shadow(radius: 5)
//
//                        Image(systemName: "plus")
//                            .font(.system(size: 28, weight: .bold))
//                            .foregroundColor(.white)
//                    }
//                }
//                Spacer()
//            }
//            .frame(height: 80)
//            .background(Color(.systemGray6))
//        }
//    }
//}
//
#Preview {
    CustomTabBar(action: {})
}

