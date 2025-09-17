OverworldMapTilemap::
	db $14 ; width
	db $12 ; height
	dw NULL
	db TRUE ; cgb mode
	INCBIN "data/maps/tiles/overworld_map_cgb.bin"

MasonLaboratoryTilemap::
	db $1c ; width
	db $1e ; height
	dw MasonLaboratoryPermissions
	db TRUE ; cgb mode
	INCBIN "data/maps/tiles/mason_laboratory_cgb.bin"
MasonLaboratoryPermissions:
	INCBIN "data/maps/permissions/mason_laboratory_cgb.bin"

ChallengeMachineMapEventTilemap::
	db $04 ; width
	db $06 ; height
	dw ChallengeMachineMapEventPermissions
	db TRUE ; cgb mode
	INCBIN "data/maps/tiles/challenge_machine_map_event_cgb.bin"
ChallengeMachineMapEventPermissions:
	INCBIN "data/maps/permissions/challenge_machine_map_event_cgb.bin"

DeckMachineRoomTilemap::
	db $18 ; width
	db $1e ; height
	dw DeckMachineRoomPermissions
	db TRUE ; cgb mode
	INCBIN "data/maps/tiles/deck_machine_room_cgb.bin"
DeckMachineRoomPermissions:
	INCBIN "data/maps/permissions/deck_machine_room_cgb.bin"

DeckMachineMapEventTilemap::
	db $04 ; width
	db $01 ; height
	dw DeckMachineMapEventPermissions
	db TRUE ; cgb mode
	INCBIN "data/maps/tiles/deck_machine_map_event_cgb.bin"
DeckMachineMapEventPermissions:
	INCBIN "data/maps/permissions/deck_machine_map_event_cgb.bin"

IshiharaTilemap::
	db $14 ; width
	db $18 ; height
	dw IshiharaPermissions
	db TRUE ; cgb mode
	INCBIN "data/maps/tiles/ishihara_cgb.bin"
IshiharaPermissions:
	INCBIN "data/maps/permissions/ishihara_cgb.bin"

FightingClubEntranceTilemap::
	db $14 ; width
	db $12 ; height
	dw FightingClubEntrancePermissions
	db TRUE ; cgb mode
	INCBIN "data/maps/tiles/fighting_club_entrance_cgb.bin"
FightingClubEntrancePermissions:
	INCBIN "data/maps/permissions/fighting_club_entrance_cgb.bin"

RockClubEntranceTilemap::
	db $14 ; width
	db $12 ; height
	dw RockClubEntrancePermissions
	db TRUE ; cgb mode
	INCBIN "data/maps/tiles/rock_club_entrance_cgb.bin"
RockClubEntrancePermissions:
	INCBIN "data/maps/permissions/rock_club_entrance_cgb.bin"

WaterClubEntranceTilemap::
	db $14 ; width
	db $12 ; height
	dw WaterClubEntrancePermissions
	db TRUE ; cgb mode
	INCBIN "data/maps/tiles/water_club_entrance_cgb.bin"
WaterClubEntrancePermissions:
	INCBIN "data/maps/permissions/water_club_entrance_cgb.bin"

LightningClubEntranceTilemap::
	db $14 ; width
	db $12 ; height
	dw LightningClubEntrancePermissions
	db TRUE ; cgb mode
	INCBIN "data/maps/tiles/lightning_club_entrance_cgb.bin"
LightningClubEntrancePermissions:
	INCBIN "data/maps/permissions/lightning_club_entrance_cgb.bin"

GrassClubEntranceTilemap::
	db $14 ; width
	db $12 ; height
	dw GrassClubEntrancePermissions
	db TRUE ; cgb mode
	INCBIN "data/maps/tiles/grass_club_entrance_cgb.bin"
GrassClubEntrancePermissions:
	INCBIN "data/maps/permissions/grass_club_entrance_cgb.bin"

PsychicClubEntranceTilemap::
	db $14 ; width
	db $12 ; height
	dw PsychicClubEntrancePermissions
	db TRUE ; cgb mode
	INCBIN "data/maps/tiles/psychic_club_entrance_cgb.bin"
PsychicClubEntrancePermissions:
	INCBIN "data/maps/permissions/psychic_club_entrance_cgb.bin"

ScienceClubEntranceTilemap::
	db $14 ; width
	db $12 ; height
	dw ScienceClubEntrancePermissions
	db TRUE ; cgb mode
	INCBIN "data/maps/tiles/science_club_entrance_cgb.bin"
ScienceClubEntrancePermissions:
	INCBIN "data/maps/permissions/science_club_entrance_cgb.bin"

FireClubEntranceTilemap::
	db $14 ; width
	db $12 ; height
	dw FireClubEntrancePermissions
	db TRUE ; cgb mode
	INCBIN "data/maps/tiles/fire_club_entrance_cgb.bin"
FireClubEntrancePermissions:
	INCBIN "data/maps/permissions/fire_club_entrance_cgb.bin"

ChallengeHallEntranceTilemap::
	db $14 ; width
	db $12 ; height
	dw ChallengeHallEntrancePermissions
	db TRUE ; cgb mode
	INCBIN "data/maps/tiles/challenge_hall_entrance_cgb.bin"
ChallengeHallEntrancePermissions:
	INCBIN "data/maps/permissions/challenge_hall_entrance_cgb.bin"

ClubLobbyTilemap::
	db $1c ; width
	db $1a ; height
	dw ClubLobbyPermissions
	db TRUE ; cgb mode
	INCBIN "data/maps/tiles/club_lobby_cgb.bin"
ClubLobbyPermissions:
	INCBIN "data/maps/permissions/club_lobby_cgb.bin"

FightingClubTilemap::
	db $18 ; width
	db $12 ; height
	dw FightingClubPermissions
	db TRUE ; cgb mode
	INCBIN "data/maps/tiles/fighting_club_cgb.bin"
FightingClubPermissions:
	INCBIN "data/maps/permissions/fighting_club_cgb.bin"

RockClubTilemap::
	db $1c ; width
	db $1e ; height
	dw RockClubPermissions
	db TRUE ; cgb mode
	INCBIN "data/maps/tiles/rock_club_cgb.bin"
RockClubPermissions:
	INCBIN "data/maps/permissions/rock_club_cgb.bin"

PokemonDomeDoorMapEventTilemap::
	db $04 ; width
	db $03 ; height
	dw PokemonDomeDoorMapEventPermissions
	db TRUE ; cgb mode
	INCBIN "data/maps/tiles/pokemon_dome_door_map_event_cgb.bin"
PokemonDomeDoorMapEventPermissions:
	INCBIN "data/maps/permissions/pokemon_dome_door_map_event_cgb.bin"

HallOfHonorDoorMapEventTilemap::
	db $04 ; width
	db $03 ; height
	dw HallOfHonorDoorMapEventPermissions
	db TRUE ; cgb mode
	INCBIN "data/maps/tiles/hall_of_honor_door_map_event_cgb.bin"
HallOfHonorDoorMapEventPermissions:
	INCBIN "data/maps/permissions/hall_of_honor_door_map_event_cgb.bin"

GrassMedalTilemap::
	db $03 ; width
	db $03 ; height
	dw NULL
	db TRUE ; cgb mode
	INCBIN "data/maps/tiles/grass_medal.bin"

AnimData1::
	frame_table AnimFrameTable0
	frame_data 3, 16, 0, 0
	frame_data 4, 16, 0, 0
	frame_data 0, 0, 0, 0

Palette110::
	db $00, $00
