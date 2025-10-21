//
//  EmtyView.swift
//  PDF Converter
//
//  Created by Alexander Abanshin on 21.10.2025.
//

import SwiftUI

struct EmptyView: View {
    var body: some View {
        VStack(spacing: 10) {
            Image(.pdf)
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .padding(20)
//                .background(Color.blue.opacity(0.2))
//                .clipShape(Circle())

            Text("There's nothing here yet")
                .font(.headline)

            Text("Click on \"+\" to convert your files to PDF, formatting and saving of received documents")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 300) // ограничение ширины для переноса
        }
        .padding()
//        .background(Color.gray.opacity(0.2))
//        .cornerRadius(12)
    }
}

#Preview {
    EmptyView()
        .padding()
}
