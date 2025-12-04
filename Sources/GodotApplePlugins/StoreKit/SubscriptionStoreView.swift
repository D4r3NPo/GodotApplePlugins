//
//  SubscriptionStoreView.swift
//  GodotApplePlugins
//
//  Created by Miguel de Icaza on 11/21/25.
//

@preconcurrency import SwiftGodotRuntime
import StoreKit
import SwiftUI

@Godot
class SubscriptionStoreView: RefCounted, @unchecked Sendable {
    @Export var groupID: String = ""
    @Export var productIDs: PackedStringArray = PackedStringArray()
    
    // Enum for SubscriptionStoreControlStyle
    enum ControlStyle: Int, CaseIterable {
        case automatic
        case picker
        case buttons
        case compactPicker
        case prominentPicker
        case pagedPicker
        case pagedProminentPicker
    }
    
    @Export(.enum) var controlStyle: ControlStyle = .automatic
    
    struct ShowSubscriptionStoreView: View {
        @Environment(\.dismiss) private var dismiss
        var groupID: String
        var productIDs: [String]
    
        var controlStyle: ControlStyle
        var body: some View {
            Group {
                if groupID != "" {
                    StoreKit.SubscriptionStoreView(groupID: groupID)
                } else {
                    StoreKit.SubscriptionStoreView(productIDs: productIDs)
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    @Callable
    func present() {
        MainActor.assumeIsolated {
            var ids: [String] = []
            if productIDs.count > 0 {
                for id in productIDs {
                    ids.append(id)
                }
            }

            let wrappedView = NavigationView {
                // Ugly, but not sure what to do other than AnyViewing itall.
                Group {
                    switch controlStyle {
                    case .automatic:
                        if !groupID.isEmpty {
                            StoreKit.SubscriptionStoreView(groupID: groupID)
                                .subscriptionStoreControlStyle(.automatic)
                        } else {
                            StoreKit.SubscriptionStoreView(productIDs: ids)
                                .subscriptionStoreControlStyle(.automatic)
                        }
                    case .picker:
                        if !groupID.isEmpty {
                            StoreKit.SubscriptionStoreView(groupID: groupID)
                                .subscriptionStoreControlStyle(.automatic)
                        } else {
                            StoreKit.SubscriptionStoreView(productIDs: ids)
                                .subscriptionStoreControlStyle(.automatic)
                        }
                    case .buttons:
                        if !groupID.isEmpty {
                            StoreKit.SubscriptionStoreView(groupID: groupID)
                                .subscriptionStoreControlStyle(.automatic)
                        } else {
                            StoreKit.SubscriptionStoreView(productIDs: ids)
                                .subscriptionStoreControlStyle(.automatic)
                        }
                    case .compactPicker:
                        if !groupID.isEmpty {
                            StoreKit.SubscriptionStoreView(groupID: groupID)
                                .subscriptionStoreControlStyle(.automatic)
                        } else {
                            StoreKit.SubscriptionStoreView(productIDs: ids)
                                .subscriptionStoreControlStyle(.automatic)
                        }
                    case .prominentPicker:
                        if !groupID.isEmpty {
                            StoreKit.SubscriptionStoreView(groupID: groupID)
                                .subscriptionStoreControlStyle(.automatic)
                        } else {
                            StoreKit.SubscriptionStoreView(productIDs: ids)
                                .subscriptionStoreControlStyle(.automatic)
                        }
                    case .pagedPicker:
                        if !groupID.isEmpty {
                            StoreKit.SubscriptionStoreView(groupID: groupID)
                                .subscriptionStoreControlStyle(.automatic)
                        } else {
                            StoreKit.SubscriptionStoreView(productIDs: ids)
                                .subscriptionStoreControlStyle(.automatic)
                        }
                    case .pagedProminentPicker:
                        if !groupID.isEmpty {
                            StoreKit.SubscriptionStoreView(groupID: groupID)
                                .subscriptionStoreControlStyle(.automatic)
                        } else {
                            StoreKit.SubscriptionStoreView(productIDs: ids)
                                .subscriptionStoreControlStyle(.automatic)
                        }
                    }
                }
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
    }

    @Callable
    func dismiss() {
        Task { @MainActor in
            dismissTopView()
        }
    }
}
