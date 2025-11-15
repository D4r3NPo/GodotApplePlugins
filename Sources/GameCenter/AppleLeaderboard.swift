//
//  AppleLeaderboard.swift
//  GodotApplePlugins
//
//  Created by Miguel de Icaza on 11/15/25.
//
@preconcurrency import SwiftGodotRuntime
import SwiftUI
#if canImport(UIKit)
import UIKit
#else
import AppKit
#endif

import GameKit

enum AppleLeaderboardType: Int, CaseIterable {
    case classic
    case recurring
    case unknown
}

@Godot
class AppleLeaderboard: RefCounted, @unchecked Sendable {
    var board: GKLeaderboard

    required init(_ context: InitContext) {
        fatalError("AppleLeaderboard should only be constructed via GameCenterManager")
    }

    init?(board: GKLeaderboard) {
        self.board = board
        guard let ctx = InitContext.createObject(className: AppleLeaderboard.godotClassName) else {
            return nil
        }
        super.init(ctx)
    }

    @Export var title: String { board.title ?? "" }
    @Export(.enum) var type: AppleLeaderboardType {
        switch board.type {
        case .classic: return .classic
        case .recurring: return .recurring
        default: return .unknown
        }
    }

    @Export var groupIdentifier: String { board.groupIdentifier ?? "" }

    // Not sure how to surface dates to Godot
    //@Export var startDate:
    //@Export var endDate:
    @Export var duration: Double { board.duration }
}
