//
//  GodotAVAudioSession.swift
//  GodotApplePlugins
//
//  Created by Miguel de Icaza on 11/15/25.
//
import SwiftGodotRuntime

extension AVAudioSession {
    enum SessionCategory: Int64, CaseIterable {
        case ambient
        case multiRoute
        case playAndRecord
        case playback
        case record
        case soloAmbient
        case unknown
    }
}
#if os(iOS) || os(tvOS) || os(visionOS)
import AVFoundation

extension AVAudioSession.SessionCategory {
    func toAVAudioSessionCategory() -> AVFoundation.AVAudioSession.Category {
        switch self {
        case .ambient:
            return .ambient
        case .multiRoute:
            return .multiRoute
        case .playAndRecord:
            return .playAndRecord
        case .playback:
            return .playback
        case .record:
            return .record
        case .soloAmbient:
            return .soloAmbient
        case .unknown:
            return .ambient
        }
    }
}

@Godot
public class AVAudioSession: RefCounted, @unchecked Sendable {
    @Export var category: SessionCategory {
        get {
            switch AVFoundation.AVAudioSession.sharedInstance().category {
            case .ambient:
                return .ambient
            case .multiRoute:
                return .multiRoute
            case .playback:
                return .playback
            case .playAndRecord:
                return .playAndRecord
            case .soloAmbient:
                return .soloAmbient
            default:
                return .unknown
            }
        }
        set {
            try? AVFoundation.AVAudioSession.sharedInstance().setCategory(newValue.toAVAudioSessionCategory())
        }
    }
}
#else
@Godot
public class AVAudioSession: RefCounted, @unchecked Sendable {
    @Export var category: SessionCategory {
        get {
            return .unknown
        }
        set {
            // ignore
        }
    }
}
#endif
