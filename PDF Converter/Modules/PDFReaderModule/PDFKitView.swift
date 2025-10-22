////
////  PDFKitView.swift
////  PDF Converter
////
////  Created by Alexander Abanshin on 22.10.2025.
////

import SwiftUI
import PDFKit

struct PDFKitView: UIViewRepresentable {
    @Binding var document: PDFDocument
    @Binding var selectedPageIndex: Int?

    func makeUIView(context: Context) -> PDFKit.PDFView {
        let pdfView = PDFKit.PDFView()
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .vertical
        pdfView.document = document

        // Tap Gesture для выбора страницы
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.pageTapped(_:)))
        pdfView.addGestureRecognizer(tapGesture)

        return pdfView
    }

    func updateUIView(_ uiView: PDFKit.PDFView, context: Context) {
        uiView.document = document
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject {
        var parent: PDFKitView

        init(_ parent: PDFKitView) {
            self.parent = parent
        }

        @objc func pageTapped(_ sender: UITapGestureRecognizer) {
            guard let pdfView = sender.view as? PDFKit.PDFView else { return }
            let location = sender.location(in: pdfView)
            if let page = pdfView.page(for: location, nearest: true),
               let index = pdfView.document?.index(for: page) {
                parent.selectedPageIndex = index
            }
        }
    }
}
