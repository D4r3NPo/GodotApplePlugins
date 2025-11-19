//
//  GKMatch.swift
//  GodotApplePlugins
//
//  Created by Miguel de Icaza on 11/18/25.
//


@preconcurrency import SwiftGodotRuntime
import SwiftUI
#if canImport(UIKit)
import UIKit
#else
import AppKit
#endif
import GameKit

@Godot
class GKMatch: RefCounted, @unchecked Sendable {
    var gkmatch = GameKit.GKMatch()

    enum SendDataMode: Int, CaseIterable {
        case reliable
        case unreliable
        func toGameKit() -> GameKit.GKMatch.SendDataMode {
            switch self {
            case .reliable: return .reliable
            case .unreliable: return .unreliable
            }
        }
    }
    convenience init(match: GameKit.GKMatch) {
        self.init()
        self.gkmatch = match
    }

    @Export var expected_player_count: Int { gkmatch.expectedPlayerCount }
    @Export var players: VariantArray {
        let result = VariantArray()
        for player in gkmatch.players {
            result.append(Variant(GKPlayer(player: player)))
        }
        return result
    }

    // TODO: these Godot errors could be better, or perhaps we should return a string?   But I do not like
    // the idea of returning an empty string to say "ok"
    @Callable
    func send(data: PackedByteArray, toPlayers: VariantArray, dataMode: SendDataMode) -> GodotError {
        guard let sdata = data.asData() else {
            return .failed
        }
        var to: [GameKit.GKPlayer] = []
        for po in toPlayers {
            guard let po, let player = po.asObject(GKPlayer.self) else {
                continue
            }
            to.append(player.player)
        }
        do {
            try gkmatch.send(sdata, to: to, dataMode: dataMode.toGameKit())
            return .ok
        } catch {
            return .failed
        }
    }

    @Callable
    func send_data_to_all_players(data: PackedByteArray, dataMode: SendDataMode) -> GodotError {
        guard let sdata = data.asData() else {
            return .failed
        }
        do {
            try gkmatch.sendData(toAllPlayers: sdata, with: dataMode.toGameKit())
            return .ok
        } catch {
            return .failed
        }
    }

    @Callable
    func disconnect() {
        gkmatch.disconnect()
    }
}
