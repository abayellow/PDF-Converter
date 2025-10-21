//
//  PDFNameAlert.swift
//  PDF Converter
//
//  Created by Alexander Abanshin on 21.10.2025.
//

import SwiftUI

struct PDFNameAlert: View {
    @Binding var isPresented: Bool
    @Binding var pdfName: String
    var onSave: () -> Void
    
    var body: some View {
        if isPresented {
            ZStack {
                // затемнение фона
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation { isPresented = false }
                    }
                
                VStack(spacing: 16) {
                    Text("Save PDF")
                        .font(.headline)
                    
                    TextField("Enter file name", text: $pdfName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                    
                    HStack {
                        Button("Cancel") {
                            withAnimation { isPresented = false }
                        }
                        .foregroundColor(.red)
                        
                        Spacer()
                        
                        Button("Save") {
                            withAnimation {
                                isPresented = false
                                onSave()
                            }
                        }
//                        .bold()
                    }
                    .padding(.horizontal)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .frame(maxWidth: 300)
                .shadow(radius: 20)
            }
            .transition(.opacity)
        }
    }
}


