HandText: ; 3630a (d:630a)
	text "Hand"
	done

CheckText: ; 36310 (d:6310)
	text "Check"
	done

AttackText: ; 36317 (d:6317)
	text "Attack"
	done

PKMNPowerText: ; 3631f (d:631f)
	text "PKMN Power"
	done

DoneText: ; 3632b (d:632b)
	text "Done"
	done

TypeText: ; 36331 (d:6331)
	text "Type"
	done

RetreatText: ; 36337 (d:6337)
	text "Retreat"
	done

WeaknessText: ; 36340 (d:6340)
	text "Weakness"
	done

ResistanceText: ; 3634a (d:634a)
	text "Resistance"
	done

NumberText:
	text "No"
	done

PKMNPWRText: ; 36356 (d:6356)
	text "PKMN PWR"
	done

; Text000b: ; 36360 (d:6360)
; 	textfw0 "ポケモンカ—ド"
; 	done

LengthText: ; 36368 (d:6368)
	text "Length"
	done

WeightText: ; 36370 (d:6370)
	text "Weight"
	done

PokemonText: ; 36378 (d:6378)
	text " Pokémon"
	done

ItemText:
	text "Item"
	done

ToolText:
	text "Tool"
	done

SupporterText:
	text "Supporter"
	done

StadiumText:
	text "Stadium"
	done

MetresText: ; 36382 (d:6382)
	textfw3 "m"
	done

LbsText: ; 36385 (d:6385)
	text "lbs."
	done

PromostarRarityText: ; 3638b (d:638b)
	textfw3 "☆"
	done

CircleRarityText: ; 3638d (d:638d)
	textfw3 "●"
	done

DiamondRarityText: ; 36390 (d:6390)
	textfw3 "◆"
	done

StarRarityText: ; 36393 (d:6393)
	textfw3 "★"
	done

AllCardsOwnedText: ; 36396 (d:6396)
	text " All cards owned:"
	done

TotalNumberOfCardsText: ; 363a9 (d:63a9)
	text "Total number of cards"
	done

TypesOfCardsText: ; 363c0 (d:63c0)
	text "Types of cards"
	done

GrassPokemonText: ; 363d0 (d:63d0)
	text "Grass Pokémon"
	done

FirePokemonText: ; 363df (d:63df)
	text "Fire Pokémon"
	done

WaterPokemonText: ; 363ed (d:63ed)
	text "Water Pokémon"
	done

LightningPokemonText: ; 363fc (d:63fc)
	text "Lightning Pokémon"
	done

FightingPokemonText: ; 3640f (d:640f)
	text "Fighting Pokémon"
	done

PsychicPokemonText: ; 36421 (d:6421)
	text "Psychic Pokémon"
	done

DarknessPokemonText: ; 36421 (d:6421)
	text "Darkness Pokémon"
	done

ColorlessPokemonText: ; 36432 (d:6432)
	text "Colorless Pokémon"
	done

TrainerCardText: ; 36445 (d:6445)
	text "Trainer Card"
	done

EnergyCardText: ; 36453 (d:6453)
	text "Energy Card"
	done

DeckPrinterText: ; 36460 (d:6460)
	text "Deck"
	done

NoPokemonOnTheBenchText: ; 3646e (d:646e)
	text "No Pokémon on the Bench."
	done

UnableDueToParalysisText:
IF CC_IS_COIN_FLIP
	text "Unable to due to Flinch."
ELSE
	text "Unable to due to Paralysis."
ENDC
	done

ReceivedDamageDueToPoisonText:
	text "<RAMTEXT> received"
	line "<RAMNUM> damage due to Poison."
	done

ReceivedDamageDueToBurnText:
	text "<RAMTEXT> received"
	line "<RAMNUM> damage due to Burn."
	done

PokemonFlinchedText:
	text "<RAMTEXT> flinched!"
	done

AccuracyCheckText:
	text "Accuracy check!"
	line "If Tails, Attack is unsuccessful."
	done

AttackUnsuccessfulText:
	text "Attack unsuccessful."
	done

IsLostInConfusionText:
	text "<RAMTEXT> is"
	line "lost in Confusion."
	done

IsFullyParalyzedText:
	text "<RAMTEXT> is"
	line "fully Paralyzed."
	done

IsFastAsleepText:
	text "<RAMTEXT> is"
	line "fast Asleep."
	done

IsCuredOfSleepText:
	text "<RAMTEXT> is"
	line "cured of Drowsiness."
	done

IsCuredOfParalysisText:
	text "<RAMTEXT> is"
	line "cured of Paralysis."
	done

IsCuredOfConfusionText:
	text "<RAMTEXT> is"
	line "cured of Confusion."
	done

IsNoLongerFlinchingText:
	text "<RAMTEXT> is"
	line "no longer Flinching."
	done

IsCuredOfBurnText:
	text "<RAMTEXT> is"
	line "cured of Burn."
	done

IsCuredOfStatusText:
	text "<RAMTEXT> is"
	line "cured of Special Conditions."
	done

BetweenTurnsText: ; 36553 (d:6553)
	text "Between Turns."
	done

NoEnergyCardsText: ; 36576 (d:6576)
	text "No Energy cards."
	done

IsThisOKText: ; 36588 (d:6588)
	text "Is this OK?"
	done

YesOrNoText: ; 36595 (d:6595)
	text "Yes     No"
	done

DiscardName: ; 365a1 (d:65a1)
	text "Discard"
	done

IncompleteText: ; 365aa (d:65aa)
	text "Incomplete"
	done

UsedText: ; 365be (d:65be)
	text "Used <RAMTEXT>."
	done

PokemonsAttackText: ; 365d8 (d:65d8)
	text "<RAMTEXT>'s"
	line ""
	text "<RAMTEXT>!"
	done

ResistanceLessDamageText: ; 365e1 (d:65e1)
	text "<RAMTEXT> received"
	line "<RAMNUM> damage due to Resistance!"
	done

WeaknessMoreDamageText: ; 36609 (d:6609)
	text "<RAMTEXT> received"
	line "<RAMNUM> damage due to Weakness!"
	done

ResistanceNoDamageText: ; 36655 (d:6655)
	text "<RAMTEXT> did not"
	line "receive damage due to Resistance."
	done

AttackDamageText: ; 36682 (d:6682)
	text "<RAMTEXT> took"
	line "<RAMNUM> damage."
	done

NoDamageText: ; 36694 (d:6694)
	text "<RAMTEXT> did not"
	line "receive damage!"
	done

NoSelectableAttackText: ; 366af (d:66af)
	text "No selectable Attack"
	done

UnableToRetreatText: ; 366c5 (d:66c5)
	text "Unable to Retreat."
	done

MayOnlyAttachOneEnergyCardText: ; 366d9 (d:66d9)
	text "You may only attach 1 Energy card"
	line "per turn."
	done

MayOnlyUseOneSupporterCardText:
	; text "You may only use 1 Supporter card"
	; line "per turn."
	text "You already used a Supporter card"
	line "this turn."
	done

MayOnlyUseOneStadiumCardText:
	text "You already used a Stadium card"
	line "this turn."
	done

UseThisPokemonPowerText: ; 36706 (d:6706)
	text "Use this Pokémon Power?"
	done

PokemonPowerSelectNotRequiredText: ; 3671f (d:671f)
	text "You do not need to select the"
	line "Pokémon Power to use it."
	done

DiscardDescription: ; 36757 (d:6757)
	text "You may discard this card during"
	line "your turn."
	line "It will be counted as a Knock Out"
	line "(This Discard is not"
	line "a Pokémon Power)"
	done

WillDrawNPrizesText: ; 367cc (d:67cc)
	text "<RAMNAME> will draw <RAMNUM> Prize(s)."
	done

DrewNPrizesText: ; 367e5 (d:67e5)
	text "<RAMNAME> drew <RAMNUM> Prize(s)."
	done

DuelistPlacedACardText: ; 367f9 (d:67f9)
	text "<RAMNAME> placed"
	line "a <RAMTEXT>."
	done

UnableToSelectText: ; 36808 (d:6808)
	text "Unable to select."
	done

ColorListText: ; 3681b (d:681b)
	text "Grass"
	line "Fire"
	line "Water"
	line "Lightning"
	line "Fighting"
	line "Psychic"
	line "Darkness"
	done

GrassSymbolText: ; 36848 (d:6848)
	textfw0 "<GRASS>"
	done

FireSymbolText: ; 3684b (d:684b)
	textfw0 "<FIRE>"
	done

WaterSymbolText: ; 3684e (d:684e)
	textfw0 "<WATER>"
	done

LightningSymbolText: ; 36851 (d:6851)
	textfw0 "<LIGHTNING>"
	done

FightingSymbolText: ; 36854 (d:6854)
	textfw0 "<FIGHTING>"
	done

PsychicSymbolText: ; 36857 (d:6857)
	textfw0 "<PSYCHIC>"
	done

DarknessSymbolText: ; 36857 (d:6857)
	textfw0 "<DARKNESS>"
	done

BenchText: ; 3685a (d:685a)
	text "Bench"
	done

KnockOutText: ; 36861 (d:6861)
	text "Knock Out"
	done

DamageToSelfDueToConfusionText: ; 3686c (d:686c)
	text "10 damage due to Confusion."
	done

ChooseEnergyCardToDiscardText: ; 36891 (d:6891)
	text "Choose the Energy card"
	line "you wish to discard."
	done

ChooseNextActivePokemonText: ; 368be (d:68be)
	text "The Active Pokémon was Knocked Out."
	line "Choose the next Pokémon."
	done

PressStartWhenReadyText: ; 36903 (d:6903)
	text "Press START"
	line "When you are ready."
	done

YouPlayFirstText: ; 36924 (d:6924)
	text "You play first."
	done

YouPlaySecondText: ; 36935 (d:6935)
	text "You play second."
	done

TransmissionErrorText: ; 36947 (d:6947)
	text "Transmission Error."
	line "Start again from the beginning."
	done

ChooseTheCardYouWishToExamineText: ; 3697c (d:697c)
	text "Choose the card"
	line "you wish to examine."
	done

TransmittingDataText: ; 369a2 (d:69a2)
	text "Transmitting data..."
	done

WaitingHandExamineText: ; 369b8 (d:69b8)
	text "Waiting..."
	line "    Hand        Examine"
	done

SelectingBenchPokemonHandExamineBackText: ; 369dc (d:69dc)
	text "Selecting Bench Pokémon..."
	line "    Hand        Examine     Back"
	done

RetreatedToTheBenchText: ; 36a19 (d:6a19)
	text "<RAMTEXT>"
	line "Retreated to the Bench."
	done

RetreatWasUnsuccessfulText: ; 36a34 (d:6a34)
	text "<RAMTEXT>'s"
	line "Retreat was unsuccessful."
	done

WillUseThePokemonPowerText: ; 36a53 (d:6a53)
	text "<RAMTEXT> will use the"
	line "Pokémon Power <RAMTEXT>."
	done

FinishedTurnWithoutAttackingText: ; 36a74 (d:6a74)
	text "Finished the Turn"
	line "without Attacking."
	done

DuelistTurnText: ; 36a9a (d:6a9a)
	text "<RAMNAME>'s Turn."
	done

DuelistTurnEndsText:
	text "<RAMNAME>'s turn ends."
	done

AttachedEnergyToPokemonText: ; 36aa5 (d:6aa5)
	text "Attached <RAMTEXT>"
	line "to <RAMTEXT>."
	done

GenericAttachedEnergyToPokemonText:
	text "Attached Energy"
	line "to <RAMTEXT>."
	done

PokemonEvolvedIntoPokemonText: ; 36ab7 (d:6ab7)
	text "<RAMTEXT> evolved"
	line "into <RAMTEXT>."
	done

PlacedOnTheBenchText: ; 36aca (d:6aca)
	text "Placed <RAMTEXT>"
	line "on the Bench."
	done

PlacedInTheArenaText: ; 36ae2 (d:6ae2)
	text "<RAMTEXT>"
	line "was placed in the Arena."
	done

ShufflesTheDeckText: ; 36afe (d:6afe)
	text "<RAMNAME> shuffles the Deck."
	done

EachPlayerShuffleOpponentsDeckText: ; 36b4b (d:6b4b)
	text "Each player will"
	line "shuffle the opponent's Deck."
	done

EachPlayerDraw7CardsText: ; 36b7a (d:6b7a)
	text "Each player will draw 7 cards."
	done

Drew7CardsText: ; 36b9a (d:6b9a)
	text "<RAMNAME>"
	line "drew 7 cards."
	done

DeckHasXCardsText: ; 36bab (d:6bab)
	text "<RAMNAME>'s deck has <RAMNUM> cards."
	done

ChooseBasicPkmnToPlaceInArenaText: ; 36bc2 (d:6bc2)
	text "Choose a Basic Pokémon"
	line "to place in the Arena."
	done

ThereAreNoBasicPokemonInHand: ; 36bf1 (d:6bf1)
	text "There are no Basic Pokémon"
	line "in <RAMNAME>'s hand."
	done

NeitherPlayerHasBasicPkmnText: ; 36c1a (d:6c1a)
	text "Neither player has any Basic"
	line "Pokémon in their hand."
	done

ReturnCardsToDeckAndDrawAgainText: ; 36c54 (d:6c54)
	text "Return the cards to the Deck"
	line "and draw again."
	done

ChooseUpTo5BasicPkmnToPlaceOnBenchText: ; 36c82 (d:6c82)
	text "You may choose up to 5 Basic Pokémon"
	line "to place on the Bench."
	done

PleaseChooseAnActivePokemonText: ; 36cbf (d:6cbf)
	text "Please choose an"
	line "Active Pokémon."
	done

ChooseYourBenchPokemonText: ; 36ce1 (d:6ce1)
	text "Choose your"
	line "Bench Pokémon."
	done

YouDrewText: ; 36cfd (d:6cfd)
	text "You drew <RAMTEXT>."
	done

YouCannotSelectThisCardText: ; 36d0a (d:6d0a)
	text "You cannot select this card."
	done

PlacingThePrizesText: ; 36d28 (d:6d28)
	text "Placing the Prizes..."
	done

PleasePlacePrizesText: ; 36d3f (d:6d3f)
	text "Please place"
	line "<RAMNUM> Prizes."
	done

IfHeadsDuelistPlaysFirstText: ; 36d57 (d:6d57)
	text "If heads,"
	line ""
	text "<RAMTEXT> plays first."
	done

CoinTossToDecideWhoPlaysFirstText: ; 36d72 (d:6d72)
	text "A coin will be tossed"
	line "to decide who plays first."
	done

DecisionText: ; 36da4 (d:6da4)
	text "Decision..."
	done

DuelWasADrawText: ; 36db1 (d:6db1)
	text "The Duel with <RAMNAME>"
	line "was a Draw!"
	done

WonDuelText: ; 36dce (d:6dce)
	text "You won the Duel with <RAMNAME>!"
	done

LostDuelText: ; 36de8 (d:6de8)
	text "You lost the Duel"
	line "with <RAMNAME>..."
	done

StartSuddenDeathMatchText: ; 36e05 (d:6e05)
	text "Start a Sudden-Death"
	line "Match for 1 Prize!"
	done

PrizesLeftActivePokemonCardsInDeckText: ; 36e2e (d:6e2e)
	text "Prizes Left"
	line "Active Pokémon"
	line "Cards in Deck"
	done

NoneText: ; 36e58 (d:6e58)
	text "None"
	done

YesText: ; 36e5e (d:6e5e)
	text "Yes"
	done

CardsText: ; 36e63 (d:6e63)
	text "Cards"
	done

TookAllThePrizesText: ; 36e6a (d:6e6a)
	text "<RAMNAME> took"
	line "all the Prizes!"
	done

ThereAreNoPokemonInPlayAreaText: ; 36e82 (d:6e82)
	text "There are no Pokémon"
	line "in <RAMNAME>'s Play Area!"
	done

WasKnockedOutText: ; 36eaa (d:6eaa)
	text "<RAMTEXT> was"
	line "Knocked Out!"
	done

HavePokemonPowerText: ; 36ebe (d:6ebe)
	text "<RAMTEXT> has"
	line "a Pokémon Power."
	done

UnableToUsePkmnPowerDueToDisableEffectText:
	text "Unable to use Pokémon Power due to"
	line "a disabling effect."
	done

PlayCheck1Text: ; 36f11 (d:6f11)
	text "  Play"
	line "  Check"
	done

PlayCheck2Text: ; 36f21 (d:6f21)
	text "  Play"
	line "  Check"
	done

SelectCheckText: ; 36f31 (d:6f31)
	text "  Select"
	line "  Check"
	done

DuelistIsThinkingText: ; 36f4a (d:6f4a)
	text "<RAMNAME> is thinking."
	done

ClearOpponentNameText: ; 36f5a (d:6f5a)
	textfw0 "          "
	done

SelectComputerOpponentText: ; 36f65 (d:6f65)
	text "Select a computer opponent."
	done

NumberOfPrizesText: ; 36f82 (d:6f82)
	text "Number of Prizes"
	done

Player2Text: ; 36fd4 (d:6fd4)
	text "Player 2"
	done

ResetBackUpRamText: ; 372a9 (d:72a9)
	text "Reset Back Up RAM?"
	done

YourDataWasDestroyedSomehowText: ; 372bd (d:72bd)
	text "Your Data was destroyed"
	line "somehow."
	line ""
	line "Please restart the game after"
	line "the Data is reset."
	done

NoCardsInHandText: ; 37348 (d:7348)
	text "No cards in hand."
	done

TheDiscardPileHasNoCardsText: ; 3735b (d:735b)
	text "The Discard Pile has no cards."
	done

PlayerDiscardPileText: ; 3737b (d:737b)
	text "Player's Discard Pile"
	done

DuelistHandText: ; 37392 (d:7392)
	text "<RAMNAME>'s Hand"
	done

DuelistPlayAreaText: ; 3739c (d:739c)
	text "<RAMNAME>'s Play Area"
	done

DuelistDeckText: ; 373ab (d:73ab)
	text "<RAMNAME>'s Deck"
	done

PleaseSelectHandText: ; 373b5 (d:73b5)
	text "Please select"
	line "Hand."
	done

PleaseSelectCardText: ; 373ca (d:73ca)
	text "Please select"
	line "Card."
	done

NoPokemonWithDamageCountersText: ; 373df (d:73df)
	text "There are no Pokémon"
	line "with Damage Counters."
	done

NoDamageCountersText: ; 3740b (d:740b)
	text "There are no Damage Counters."
	done

NoEnergyAttachedToOpponentsActiveText: ; 3742a (d:742a)
	text "No Energy cards are attached to"
	line "the opponent's Active Pokémon."
	done

ThereAreNoEnergyCardsInDiscardPileText: ; 3746a (d:746a)
	text "There are no Energy cards"
	line "in the the Discard Pile."
	done

ThereAreNoBasicEnergyCardsInDiscardPileText: ; 3749e (d:749e)
	text "There are no Basic Energy cards"
	line "in the Discard Pile."
	done

NoCardsLeftInTheDeckText: ; 374d4 (d:74d4)
	text "The Deck is empty."
	done

NoSpaceOnTheBenchText: ; 374fa (d:74fa)
	text "There is no space on the Bench."
	done

NoPokemonCapableOfEvolvingText: ; 3751b (d:751b)
	text "There are no Pokémon capable"
	line "of Evolving."
	done

CantEvolvePokemonInSameTurnItsPlacedText: ; 37546 (d:7546)
	text "You cannot Evolve a Pokémon"
	line "in the same turn it was placed."
	done

NotAffectedBySpecialConditionsText:
	text "Not affected by Special Conditions."
	done

NotEnoughCardsInHandText: ; 375bc (d:75bc)
	text "Not enough cards in Hand."
	done

EffectNoPokemonOnTheBenchText: ; 375d7 (d:75d7)
	text "No Pokémon on the Bench."
	done

ThereAreNoPokemonInDiscardPileText: ; 375f1 (d:75f1)
	text "There are no Pokémon"
	line "in the Discard Pile."
	done

ConditionsForEvolvingToStage2NotFulfilledText: ; 3761c (d:761c)
	text "Conditions for evolving to"
	line "Stage 2 not fulfilled."
	done

ThereAreNoCardsInHandThatYouCanChangeText: ; 3764f (d:764f)
	text "There are no cards in Hand"
	line "that you can change."
	done

ThereAreNoCardsInTheDiscardPileText: ; 37680 (d:7680)
	text "There are no cards in the"
	line "Discard Pile."
	done

ThereAreNoEvolvedPokemonInPlayAreaText:
	text "There are no Evolved Pokémon"
	line "in the Play Area."
	done

NoEnergyCardsAttachedToPokemonInYourPlayAreaText: ; 376d9 (d:76d9)
	text "No Energy cards are attached to"
	line "Pokémon in your Play Area."
	done

NoEnergyCardsAttachedToPokemonInOppPlayAreaText: ; 37715 (d:7715)
	text "No Energy cards attached to Pokémon"
	line "in your opponent's Play Area."
	done

EnergyCardsRequiredToRetreatText: ; 37758 (d:7758)
	text "<RAMNUM> Energy cards"
	line "are required to Retreat."
	done

NotEnoughEnergyCardsText: ; 37781 (d:7781)
	text "Not enough Energy cards."
	done

NotEnoughFireEnergyText:
	text "Not enough Fire Energy."
	done

NotEnoughLightningEnergyText:
	text "Not enough Lightning Energy."
	done

NotEnoughWaterEnergyText:
	text "Not enough Water Energy."
	done

NotEnoughPsychicEnergyText:
	text "Not enough Psychic Energy."
	done

ThereAreNoTrainerCardsInDiscardPileText: ; 377ea (d:77ea)
	text "There are no Trainer Cards"
	line "in the Discard Pile."
	done

NoAttackMayBeChoosenText: ; 3781b (d:781b)
	text "No Attacks may be choosen."
	done

NoWeaknessText: ; 37889 (d:7889)
	text "No Weakness."
	done

NoResistanceText: ; 37897 (d:7897)
	text "No Resistance."
	done

OnlyOncePerTurnText: ; 378a7 (d:78a7)
	text "Only once per turn."
	done

CannotUseDueToStatusText:
	text "Cannot use due to Drowsiness,"
	line "Paralysis or Confusion."
	done

CannotBeUsedInTurnWhichWasPlayedText: ; 378ef (d:78ef)
	text "Cannot be used in the turn in"
	line "which it was played."
	done

ThereIsNoEnergyCardAttachedText: ; 37923 (d:7923)
	text "There is no Energy card attached."
	done

NoGrassEnergyText: ; 37946 (d:7946)
	text "No Grass Energy."
	done

CannotUseBecauseItWillBeKnockedOutText: ; 37982 (d:7982)
	text "Cannot use because"
	line "it will be Knocked Out."
	done

CanOnlyBeUsedOnTheBenchText: ; 379ae (d:79ae)
	text "Can only be used on the Bench."
	done

ThereAreNoPokemonOnBenchText: ; 379ce (d:79ce)
	text "There are no Pokémon on the Bench."
	done

OpponentIsNotAsleepText:
	text "Opponent is not Drowsy."
	done

UnableToUsePkmnPowerText:
	text "Unable to use Pokémon Powers."
	done

BackUpIsBrokenText: ; 37a59 (d:7a59)
	text "Back Up is broken."
	done

PrinterIsNotConnectedText: ; 37a6d (d:7a6d)
	text "Error 02:"
	line "Printer is not connected."
	done

BatteriesHaveLostTheirChargeText: ; 37a96 (d:7a96)
	text "Error 01:"
	line "Empty batteries."
	done

PrinterPaperIsJammedText: ; 37ac7 (d:7ac7)
	text "Error 03:"
	line "Printer paper is jammed."
	done

CheckCableOrPrinterSwitchText: ; 37aef (d:7aef)
	text "Error 02:"
	line "Check cable or printer switch."
	done

PrinterPacketErrorText: ; 37b1d (d:7b1d)
	text "Error 04:"
	line "Printer Packet Error."
	done

PrintingWasInterruptedText: ; 37b42 (d:7b42)
	text "Printing was interrupted."
	done

CardPopCannotBePlayedWithTheGameBoyText: ; 37b5d (d:7b5d)
	text "Card Pop! can only be played"
	line "with a Game Boy Color."
	done
