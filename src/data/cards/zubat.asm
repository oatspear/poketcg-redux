IF ZUBAT_VARIANT == 1

ZubatCard:
	db TYPE_PKMN_DARKNESS ; type
	gfx ZubatCardGfx ; gfx
	tx ZubatName ; name
	db CIRCLE ; rarity
	db LABORATORY | FOSSIL ; sets
	db ZUBAT
	db 140 ; hp
	db BASIC ; stage
	dw NONE ; pre-evo name

	; (D) Astonish 10
	; Choose a random card from your opponent's hand.
	; Your opponent reveals that cards and shuffles it into their deck.

	; attack 1
	energy COLORLESS, 1 ; energies
	tx SupersonicName ; name
	tx InflictConfusionDescription ; description
	dw NONE ; description (cont)
	db 0 ; damage
	db RESIDUAL ; category
	dw InflictConfusionEffectCommands ; effect commands
	db INFLICT_CONFUSION ; flags 1
	db NONE ; flags 2
	db NONE ; flags 3
	db 0
	db ATK_ANIM_SUPERSONIC ; animation

	; attack 2
	energy DARKNESS, 1, COLORLESS, 1 ; energies
	tx SwarmName ; name
	tx SwarmDescription ; description
	tx SwarmDescriptionCont ; description (cont)
	db 10 ; damage
	db DAMAGE_PLUS ; category
	dw SwarmEffectCommands ; effect commands
	db NONE ; flags 1
	db NONE ; flags 2
	db NONE ; flags 3
	db 3
	db ATK_ANIM_HIT ; animation

	db 0 ; retreat cost
	db WR_LIGHTNING ; weakness
	db WR_FIGHTING ; resistance
	tx BatName ; category
	db 41 ; Pokedex number
	db 0
	db 10 ; level
	db 2, 7 ; length
	dw 17 * 10 ; weight
	tx ZubatDescription ; description
	db 16

ELSE

ZubatCard:
	db TYPE_PKMN_DARKNESS ; type
	gfx ZubatCardGfx ; gfx
	tx ZubatName ; name
	db CIRCLE ; rarity
	db LABORATORY | FOSSIL ; sets
	db ZUBAT
	db 40 ; hp
	db BASIC ; stage
	dw NONE ; pre-evo name

	; (D) Astonish 10
	; Choose a random card from your opponent's hand.
	; Your opponent reveals that cards and shuffles it into their deck.

	; attack 1
	energy COLORLESS, 1 ; energies
	tx SupersonicName ; name
	tx InflictConfusionDescription ; description
	dw NONE ; description (cont)
	db 0 ; damage
	db RESIDUAL ; category
	dw InflictConfusionEffectCommands ; effect commands
	db INFLICT_CONFUSION ; flags 1
	db NONE ; flags 2
	db NONE ; flags 3
	db 0
	db ATK_ANIM_SUPERSONIC ; animation

	; attack 2
	energy DARKNESS, 1, COLORLESS, 1 ; energies
	tx SwarmName ; name
	tx SwarmDescription ; description
	tx SwarmDescriptionCont ; description (cont)
	db 10 ; damage
	db DAMAGE_PLUS ; category
	dw SwarmEffectCommands ; effect commands
	db NONE ; flags 1
	db NONE ; flags 2
	db NONE ; flags 3
	db 3
	db ATK_ANIM_HIT ; animation

	db 0 ; retreat cost
	db WR_LIGHTNING ; weakness
	db WR_FIGHTING ; resistance
	tx BatName ; category
	db 41 ; Pokedex number
	db 0
	db 10 ; level
	db 2, 7 ; length
	dw 17 * 10 ; weight
	tx ZubatDescription ; description
	db 16

ENDC
