# Using Apple's GameKit APIs with Godot

This is a quick guide on using the APIs in this Godot addon to access
Apple's GameKit APIs.  For an overview of what you can do with
GameKit, check [Apple's GameKit
Documentation](https://developer.apple.com/documentation/gamekit/)

One of the design choices in this binding has been to surface the same
class names that Apple uses for their own data types to simplify
looking things up and finding resources online.  The method names on
the other hand reflect the Godot naming scheme.

So instead of calling `loadPhoto` on GKPlayer, you would use the
`load_photo` method.  And instead of the property `gamePlayerID`, you
would access `game_player_id`.

# Table of Contents

* [Installation]
* [Players]

## Installation

### Installing in your project

Make sure that you have added the directory containing the
"GodotApplePlugins" to your project, it should contain both a
`godot_apple_plugins.gdextension` and a `bin` directory with the
native libraries that you will use.

The APIs have been exposed to both MacOS and iOS, so you can iterate
quickly on your projects.

### Entitlements

For your sofwtare to be able to use the GameKit APIs, you will need
your Godot engine to have the `com.apple.developer.game-center`
entitlements.  The easiest way to do this is to use Xcode to add the
entitlement to your iOS project.

See the file [Entitlements](Entitlements.md) for additional directions
- without this, calling the APIs won't do much.

## Authentication

Create an instance of GameCenterManager, and then you can connect to
the `authentication_error` and `authentication_result` signals to
track the authentication state.

Then call the `authenticate()` method to trigger the authentication:

```gdscript
var gameCenter: GameCenterManager

func _ready() -> void:
	gameCenter = GameCenterManager.new()

	gameCenter.authentication_error.connect(func(error: String) -> void:
		print("Received error %s" % error)
	)
	gameCenter.authentication_result.connect(func(status: bool) -> void:
		print("Authentication updated, status: %s" % status
	)
```

The `local_player` is a special version of `GKPlayer` with properties
that track the local player state.

## Players

Apple Documentation:

* [GKLocalPlayer](https://developer.apple.com/documentation/gamekit/gklocalplayer)

### Fetch the Local Player

From the GameCenterManager, you can call `local_player`, this returns
a `GKLocalPlayer`, which is a subclass of `GKPlayer` and represents
the player using your game.

```gdscript
var local: GKLocalPlayer

func _ready() -> void:
	gameCenter = GameCenterManager.new()
	local = gameCenter.local_player
	print("ONREADY: local, is auth: %s" % local.is_authenticated)
	print("ONREADY: local, player ID: %s" % local.game_player_id)
```

There are a number of interesting properties in local_player that you
might want to use in your game like `is_authenticated`, `is_underage`,
`is_multiplayer_gaming_restricted` and so on.

### Loading Player Photo


```gdscript
	# Here, we put the image inside an existing TextureRect, named $texture_rect:
	local_player.load_photo(true, func(image: Image, error: Variant)->void:
		if error == null:
			$texture_rect.texture = ImageTexture.create_from_image(image)
	)
```

### GKPlayer

* [GKPlayer]((https://developer.apple.com/documentation/gamekit/gkplayer)

