//
//  PDFDocumentItem.swift
//  PDF Converter
//
//  Created by Alexander Abanshin on 21.10.2025.
//

import Foundation
import UIKit
struct PDFDocumentItem: Identifiable {
    let id = UUID()
    let name: String
    let url: URL
    var preview: UIImage
    var date: Date
}
