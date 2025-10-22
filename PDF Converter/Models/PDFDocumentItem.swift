//
//  PDFDocumentItem.swift
//  PDF Converter
//
//  Created by Alexander Abanshin on 21.10.2025.
//

import Foundation
import UIKit

struct PDFDocumentItem: Identifiable {
    let id: UUID
    let name: String
    var url: URL
    var preview: UIImage
    var date: Date
    
    init(id: UUID = UUID(), name: String, url: URL, preview: UIImage, date: Date) {
        self.id = id
        self.name = name
        self.url = url
        self.preview = preview
        self.date = date
    }
}
