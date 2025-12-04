//
//  StoreProduct.swift
//  GodotApplePlugins
//
//  Created by Miguel de Icaza on 11/21/25.
//

@preconcurrency import SwiftGodotRuntime
import StoreKit

@Godot
class StoreProduct: RefCounted, @unchecked Sendable {
    var product: Product?

    convenience init(_ product: Product) {
        self.init()
        self.product = product
    }
    
    @Export var productId: String { product?.id ?? "" }
    @Export var displayName: String { product?.displayName ?? "" }
    @Export var descriptionValue: String { product?.description ?? "" }
    @Export var price: Double { 
        guard let product else { return 0.0 }
        return Double(truncating: product.price as NSNumber)
    }
    @Export var displayPrice: String { product?.displayPrice ?? "" }
    @Export var isFamilyShareable: Bool { product?.isFamilyShareable ?? false }
    
    // Helper to get the JSON representation if needed for more details
    @Export var jsonRepresentation: String {
        guard let product else { return "" }
        return "\(product)"
    }
}
