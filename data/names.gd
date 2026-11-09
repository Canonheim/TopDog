class_name NameGen
extends RefCounted
## Climber names: "First the Title", from our own word lists.

const FIRST := [
	"Aldric", "Bertram", "Cuthbert", "Dunstan", "Edwin", "Fulk", "Godric", "Humbert",
	"Ingram", "Jory", "Kenric", "Leofric", "Merrick", "Norbert", "Osric", "Percival",
	"Quentin", "Roderick", "Sigurd", "Tobias", "Ulric", "Valen", "Wystan", "Yorick",
	"Agnes", "Beatrix", "Cecily", "Edith", "Gisela", "Hilda", "Isolde", "Matilda",
	"Rowena", "Sibyl", "Winifred", "Elspeth", "Maud", "Odette", "Brunhild", "Tamsin",
	"Dango",
]
const THING := [
	"Barrel", "Ladder", "Turnip", "Goose", "Bucket", "Anvil", "Cabbage", "Kettle",
	"Rampart", "Tankard", "Haystack", "Drawbridge", "Pudding", "Cart", "Lantern", "Mitten",
	"Gatepost", "Herring", "Saddle", "Shovel", "Teacup", "Banner", "Bell", "Pickle",
]
const DOER := [
	"Hugger", "Climber", "Wrangler", "Toppler", "Stacker", "Clinger", "Dangler", "Flinger",
	"Grappler", "Scaler", "Wobbler", "Hoister", "Squeezer", "Botherer", "Snatcher", "Tumbler",
	"Mounter", "Squasher", "Tickler", "Juggler", "Balancer", "Leaper", "Scrambler", "Teeterer",
]
const TINTS := [
	Color(0.85, 0.25, 0.22), Color(0.22, 0.45, 0.85), Color(0.95, 0.75, 0.2), Color(0.3, 0.7, 0.35),
	Color(0.65, 0.35, 0.8), Color(0.95, 0.5, 0.15), Color(0.2, 0.75, 0.75), Color(0.85, 0.4, 0.6),
]


## TITLES THAT STAND ALONE (Parker 11-09): picked like any THING, but no DOER is added,
## so anyone can be "Edith the Wretch".
const ALONE := ["Wretch"]


static func make() -> String:
	var first: String = FIRST.pick_random()
	var title: String = (THING + ALONE).pick_random()
	if title in ALONE:
		return "%s the %s" % [first, title]
	return "%s the %s-%s" % [first, title, DOER.pick_random()]


static func tint(i: int) -> Color:
	return TINTS[i % TINTS.size()]
