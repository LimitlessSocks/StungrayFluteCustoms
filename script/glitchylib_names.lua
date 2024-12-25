--Custom Cards associated with custom effects

--[[This effect must be assigned to monsters that cannot be Special Summoned from the banishment due to specific card effects and restrictions.
Named after "Mx. Music", this effect is necessary to correctly handle interactions with effects that banish a monster and Special Summon the same monster right after.
It is the banishment analogue of the CARD_CLOCK_LIZARD effect, which handles Summons from the Extra Deck instead (see "Clock Lizard")]]
CARD_MX_MUSIC							=	130000022	

--While this effect is applied to a card, that card will only be affected by the effect of EFFECT_NECRO_VALLEY that prevents the change of Type/Attribute											
CARD_HIDDEN_MONASTERY_OF_NECROVALLEY	=	130000000

--Custom Archetypes
SET_MOBLINS					=	0x300
SET_WICCINK					=	0x301

--Official Cards/Custom Cards
CARD_AMPLIFIER				=	303660
CARD_DHERO_DRILLDARK		=	91691605
CARD_FIREWING_PEGASUS		=	27054370
CARD_GAIA_THE_FIERCE_KNIGHT	=	6368038
CARD_KAISER_DRAGON			=	94566432
CARD_MIRACLE_STONE			=	31461282
CARD_ZOMBIE_WORLD			=	4064256

CARD_ADIRA_APOTHEOSIZED		=   130000020
CARD_ADIRAS_WILL			=	130000021
CARD_HIERATIC_AWAKENING		=	130000069
CARD_NUMBERS_REVOLUTION		=	130000015
CARD_REGRESSED_RITUAL_ART	=	130000003

--Custom Tokens
TOKEN_WICCINK				=	130000050

--Custom Counters

--Desc
STRING_ACTIVATE_PENDULUM			=	4003
STRING_ADD_TO_HAND					=	1105
STRING_BANISH_REDIRECT				=	3300
STRING_CHANGE_POSITION				=	aux.Stringid(130000010,2)
STRING_DETACH						=	4004
STRING_RELEASE						=	500

STRING_AVOID_BATTLE_DAMAGE								=	3210
STRING_CANNOT_ATTACK									=	3206
STRING_CANNOT_BE_DESTROYED								=	3008
STRING_CANNOT_BE_DESTROYED_BY_BATTLE					=	3000
STRING_CANNOT_BE_DESTROYED_BY_EFFECTS					=	3001
STRING_CANNOT_BE_DESTROYED_OR_TARGETED_BY_EFFECTS		=	3009
STRING_CANNOT_BE_DESTROYED_OR_TARGETED_BY_EFFECTS_OPPO	=	3067
STRING_CANNOT_BE_DESTROYED_AT_ALL						=	4000
STRING_CANNOT_BE_TRIBUTED								=	3303

STRING_BOTTOM_OF_DECK_REDIRECT							=	4002
STRING_SHUFFLE_INTO_DECK_REDIRECT						=	3301
STRING_TOP_OF_DECK_REDIRECT								=	4001

STRING_ASK_POSITION										=	5000

----Hint messages
HINTMSG_ATTACHTO					=	aux.Stringid(130000015,2)