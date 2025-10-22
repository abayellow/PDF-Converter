//
//  ConvertButton.swift
//  PDF Converter
//
//  Created by Alexander Abanshin on 22.10.2025.
//

import SwiftUI

struct ConvertButtonView: View {
    let action: () -> Void

    var body: some View {
        Button("Convert") {
            action()
        }
        .font(.headline)
        .foregroundColor(.white)
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.blue)
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

#Preview {
    ConvertButtonView() {
        print("")
    }
}
