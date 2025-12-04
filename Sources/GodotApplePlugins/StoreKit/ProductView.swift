//
//  ProductView.swift
//  GodotApplePlugins
//
//  Created by Miguel de Icaza on 11/21/25.
//

@preconcurrency import SwiftGodotRuntime
import StoreKit
import SwiftUI

@Godot
class ProductView: RefCounted, @unchecked Sendable {
    @Export var productId: String = ""
    @Export var prefersPromotionalIcon: Bool = false
    @Export var systemIconName: String = "cart"

    // Enum for ProductViewStyle
    enum ViewStyle: Int, CaseIterable {
        case automatic = 0
        case compact = 1
        case large = 2
        case regular = 3
    }
    
    @Export(.enum) var style: ViewStyle = .automatic
    
    @Callable
    func present() {
        guard !productId.isEmpty else { return }
        
        Task { @MainActor in
            let view = StoreKit.ProductView(id: productId) {
                Image(systemName: systemIconName)
            }
            
            switch style {
            case .automatic:
                self.presentWrapped(view.productViewStyle(.automatic))
            case .compact:
                self.presentWrapped(view.productViewStyle(.compact))
            case .large:
                self.presentWrapped(view.productViewStyle(.large))
            case .regular:
                self.presentWrapped(view.productViewStyle(.regular))
            }
        }
    }
    
    @MainActor
    private func presentWrapped<V: View>(_ view: V) {
        let wrappedView = NavigationView {
            view
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Close") {
                            dismissTopView()
                        }
                    }
                }
        }
        presentView(wrappedView)
    }
    
    @Callable
    func dismiss() {
        Task { @MainActor in
            dismissTopView()
        }
    }
}
