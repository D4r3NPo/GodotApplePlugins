//
//  GKMatchMakerViewController.swift
//  GodotApplePlugins
//
//  Created by Miguel de Icaza on 11/17/25.
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
class GKMatchmakerViewController: RefCounted, @unchecked Sendable {
    class Proxy: NSObject, GameKit.GKMatchmakerViewControllerDelegate, GKLocalPlayerListener {
        func matchmakerViewControllerWasCancelled(_ viewController: GameKit.GKMatchmakerViewController) {
            base?.cancelled.emit("")
        }
        
        func matchmakerViewController(_ viewController: GameKit.GKMatchmakerViewController, didFailWithError error: any Error) {
            GD.print("GKMVC: didFailWithError")
            base?.failed_with_error.emit(String(describing: error))
        }

        func matchmakerViewController(_ viewController: GameKit.GKMatchmakerViewController, didFind match: GameKit.GKMatch) {
            base?.did_find_match.emit(GKMatch(match: match))
        }

        func matchmakerViewController(
            _ viewController: GameKit.GKMatchmakerViewController,
            didFindHostedPlayers players: [GameKit.GKPlayer]
        ) {
            let result = VariantArray()
            for player in players {
                result.append(Variant(GKPlayer(player: player)))
            }
            base?.did_find_hosted_players.emit(result)
        }



        weak var base: GKMatchmakerViewController?
        init(_ base: GKMatchmakerViewController) {
            self.base = base
        }
    }

    @Signal var cancelled: SignalWithArguments<String>


    /// Matchmaking has failed with an error
    @Signal var failed_with_error: SignalWithArguments<String>

    /// A peer-to-peer match has been found, the game should start
    @Signal var did_find_match: SignalWithArguments<GKMatch>

    /// Players have been found for a server-hosted game, the game should start, receives an array of GKPlayers
    @Signal var did_find_hosted_players: SignalWithArguments<VariantArray>

    var vc: GameKit.GKMatchmakerViewController?
    var proxy: Proxy?

    /// Returns a view controller for the specified request, configure the various callbacks, and then
    /// call present
    @Callable static func request(request: GKMatchRequest) -> GKMatchmakerViewController? {
        MainActor.assumeIsolated {
            if let vc = GameKit.GKMatchmakerViewController(matchRequest: request.request) {
                let v = GKMatchmakerViewController()
                let proxy = Proxy(v)

                v.vc = vc
                v.proxy = proxy

                vc.matchmakerDelegate = proxy
                return v
            }
            return nil
        }
    }

    @Callable func present() {
        guard let vc else {
            return
        }
        MainActor.assumeIsolated {
            presentOnTop(vc)
        }
    }
}
