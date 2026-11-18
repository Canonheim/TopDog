extends RefCounted
const EFFECTS = {
  "game_night": {
    "pieces": 48,
    "variants": [
      "res://ui3d/common_effects/group3/assets/game_night_die_0.res",
      "res://ui3d/common_effects/group3/assets/game_night_die_1.res",
      "res://ui3d/common_effects/group3/assets/game_night_die_2.res",
      "res://ui3d/common_effects/group3/assets/game_night_domino_0.res",
      "res://ui3d/common_effects/group3/assets/game_night_domino_1.res",
      "res://ui3d/common_effects/group3/assets/game_night_domino_2.res",
      "res://ui3d/common_effects/group3/assets/game_night_checker_0.res",
      "res://ui3d/common_effects/group3/assets/game_night_checker_1.res"
    ]
  },
  "love_letters": {
    "pieces": 48,
    "variants": [
      "res://ui3d/common_effects/group3/assets/love_letters_envelope_0.res",
      "res://ui3d/common_effects/group3/assets/love_letters_envelope_1.res",
      "res://ui3d/common_effects/group3/assets/love_letters_envelope_2.res",
      "res://ui3d/common_effects/group3/assets/love_letters_envelope_3.res",
      "res://ui3d/common_effects/group3/assets/love_letters_envelope_4.res",
      "res://ui3d/common_effects/group3/assets/love_letters_envelope_5.res",
      "res://ui3d/common_effects/group3/assets/love_letters_fan_note_0.res",
      "res://ui3d/common_effects/group3/assets/love_letters_fan_note_1.res",
      "res://ui3d/common_effects/group3/assets/love_letters_fan_note_2.res",
      "res://ui3d/common_effects/group3/assets/love_letters_fan_note_3.res",
      "res://ui3d/common_effects/group3/assets/love_letters_fan_card_0.res",
      "res://ui3d/common_effects/group3/assets/love_letters_fan_card_1.res",
      "res://ui3d/common_effects/group3/assets/love_letters_phone_sticky_0.res",
      "res://ui3d/common_effects/group3/assets/love_letters_phone_sticky_1.res",
      "res://ui3d/common_effects/group3/assets/love_letters_phone_sticky_2.res",
      "res://ui3d/common_effects/group3/assets/love_letters_phone_sticky_3.res"
    ]
  },
  "music_notes": {
    "pieces": 36,
    "variants": [
      "res://ui3d/common_effects/group3/assets/music_notes_0.res",
      "res://ui3d/common_effects/group3/assets/music_notes_1.res",
      "res://ui3d/common_effects/group3/assets/music_notes_2.res",
      "res://ui3d/common_effects/group3/assets/music_notes_3.res",
      "res://ui3d/common_effects/group3/assets/music_notes_4.res",
      "res://ui3d/common_effects/group3/assets/music_notes_5.res"
    ]
  },
  "pencil_case": {
    "pieces": 48,
    "variants": [
      "res://ui3d/common_effects/group3/assets/pencil_case_pencil_0.res",
      "res://ui3d/common_effects/group3/assets/pencil_case_pencil_1.res",
      "res://ui3d/common_effects/group3/assets/pencil_case_pencil_2.res",
      "res://ui3d/common_effects/group3/assets/pencil_case_pencil_3.res",
      "res://ui3d/common_effects/group3/assets/pencil_case_eraser_0.res",
      "res://ui3d/common_effects/group3/assets/pencil_case_eraser_1.res",
      "res://ui3d/common_effects/group3/assets/pencil_case_ruler.res",
      "res://ui3d/common_effects/group3/assets/pencil_case_sharpener.res"
    ]
  },
  "playing_cards": {
    "pieces": 60,
    "variants": [
      "res://ui3d/common_effects/group3/assets/playing_cards_card_0.res",
      "res://ui3d/common_effects/group3/assets/playing_cards_card_1.res",
      "res://ui3d/common_effects/group3/assets/playing_cards_card_2.res",
      "res://ui3d/common_effects/group3/assets/playing_cards_card_3.res",
      "res://ui3d/common_effects/group3/assets/playing_cards_card_4.res",
      "res://ui3d/common_effects/group3/assets/playing_cards_card_5.res",
      "res://ui3d/common_effects/group3/assets/playing_cards_card_6.res",
      "res://ui3d/common_effects/group3/assets/playing_cards_card_7.res",
      "res://ui3d/common_effects/group3/assets/playing_cards_heart.res",
      "res://ui3d/common_effects/group3/assets/playing_cards_diamond.res",
      "res://ui3d/common_effects/group3/assets/playing_cards_club.res",
      "res://ui3d/common_effects/group3/assets/playing_cards_spade.res"
    ]
  },
  "puzzle_pieces": {
    "pieces": 60,
    "variants": [
      "res://ui3d/common_effects/group3/assets/puzzle_pieces_0.res",
      "res://ui3d/common_effects/group3/assets/puzzle_pieces_1.res",
      "res://ui3d/common_effects/group3/assets/puzzle_pieces_2.res",
      "res://ui3d/common_effects/group3/assets/puzzle_pieces_3.res",
      "res://ui3d/common_effects/group3/assets/puzzle_pieces_4.res",
      "res://ui3d/common_effects/group3/assets/puzzle_pieces_5.res"
    ]
  },
  "sewing_kit": {
    "pieces": 48,
    "variants": [
      "res://ui3d/common_effects/group3/assets/sewing_kit_button_0.res",
      "res://ui3d/common_effects/group3/assets/sewing_kit_button_1.res",
      "res://ui3d/common_effects/group3/assets/sewing_kit_button_2.res",
      "res://ui3d/common_effects/group3/assets/sewing_kit_button_3.res",
      "res://ui3d/common_effects/group3/assets/sewing_kit_spool_0.res",
      "res://ui3d/common_effects/group3/assets/sewing_kit_spool_1.res",
      "res://ui3d/common_effects/group3/assets/sewing_kit_needle.res",
      "res://ui3d/common_effects/group3/assets/sewing_kit_thimble.res"
    ]
  },
  "toolbox": {
    "pieces": 30,
    "variants": [
      "res://ui3d/common_effects/group3/assets/toolbox_hammer.res",
      "res://ui3d/common_effects/group3/assets/toolbox_wrench.res",
      "res://ui3d/common_effects/group3/assets/toolbox_screw.res",
      "res://ui3d/common_effects/group3/assets/toolbox_nut.res",
      "res://ui3d/common_effects/group3/assets/toolbox_screwdriver.res"
    ]
  },
  "bees": {
    "pieces": 36,
    "variants": [
      "res://ui3d/common_effects/group3/assets/bees_bee_0.res",
      "res://ui3d/common_effects/group3/assets/bees_bee_1.res",
      "res://ui3d/common_effects/group3/assets/bees_bee_2.res",
      "res://ui3d/common_effects/group3/assets/bees_comb_0.res",
      "res://ui3d/common_effects/group3/assets/bees_comb_1.res",
      "res://ui3d/common_effects/group3/assets/bees_comb_2.res"
    ]
  }
}
