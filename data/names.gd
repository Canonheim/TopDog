class_name NameGen
extends RefCounted
## Climber names: "[Describer] First the Thing Doer" (or "... the Wretch"), from our own word lists.

const FIRST := [
	"Aldric", "Bertram", "Cuthbert", "Dunstan", "Edwin", "Fulk", "Godric", "Humbert",
	"Ingram", "Jory", "Kenric", "Leofric", "Merrick", "Norbert", "Osric", "Percival",
	"Quentin", "Roderick", "Sigurd", "Tobias", "Ulric", "Valen", "Wystan", "Yorick",
	"Agnes", "Beatrix", "Cecily", "Edith", "Gisela", "Hilda", "Isolde", "Matilda",
	"Rowena", "Sibyl", "Winifred", "Elspeth", "Maud", "Odette", "Brunhild", "Tamsin",
	"Dango", "Benny", "Alec", "Yordun", "Colin", "Nick", "Anthony",
	"Don'Key", "Specky", "Adam", "Craig", "Tony", "Jefe", "Juan", "Stephan",
	"Gordito", "P.K.", "Mohamad", "Xavier", "Timmy", "Tim", "Tom", "Tommy",
	"Danny", "Dan", "John", "Johnny", "Jonny", "Jonaline", "Ethan", "Daniel",
	"Jorge", "George", "Austin", "Jesus", "Brandon",
	"Horatio", "Horace", "Seamus O'Hool", "O'Leary", "Reginald", "Bort", "Bob", "Billy",
	"Bingus", "Sally", "Steven", "Steve", "Weston", "Carsen",
]
const THING := [
	"Barrel", "Ladder", "Turnip", "Goose", "Bucket", "Anvil", "Cabbage", "Kettle",
	"Rampart", "Tankard", "Haystack", "Drawbridge", "Pudding", "Cart", "Lantern", "Mitten",
	"Gatepost", "Herring", "Saddle", "Shovel", "Teacup", "Banner", "Bell", "Pickle",
	"Cat", "Dog", "Turtle", "Horse", "Donkey", "Goat", "Grape", "Book",
	"Teeth", "Bone", "Elbow", "Foot", "Melon", "Gold", "Egg", "Letter", "Giant", "Tiny",
	"Barf", "Boot", "Shirt", "Pants", "Skin",
]
const DOER := [
	"Hugger", "Climber", "Wrangler", "Toppler", "Stacker", "Clinger", "Dangler", "Flinger",
	"Grappler", "Scaler", "Wobbler", "Hoister", "Squeezer", "Botherer", "Snatcher", "Tumbler",
	"Mounter", "Squasher", "Tickler", "Juggler", "Balancer", "Leaper", "Scrambler", "Teeterer",
	"Fiddler", "Juicer", "Toucher", "Clapper", "Slapper", "Delivery Boy",
]
const TINTS := [
	Color(0.85, 0.25, 0.22), Color(0.22, 0.45, 0.85), Color(0.95, 0.75, 0.2), Color(0.3, 0.7, 0.35),
	Color(0.65, 0.35, 0.8), Color(0.95, 0.5, 0.15), Color(0.2, 0.75, 0.75), Color(0.85, 0.4, 0.6),
]


## THE FRONT WORD (Parker 11-10): half of all climbers get a describer before the
## first name, "Stinky Tony the Goose Toppler". Parker's list first, then ours.
const ADJECTIVE := [
	"El", "Big", "Tiny", "Stinky", "Violent", "Slimy", "Slick", "Skinny",
	"Fat", "Pretty", "Nostalgic", "Lovely", "Melancholy",
	"Sweaty", "Soggy", "Wobbly", "Grumpy", "Crusty", "Sneaky", "Damp", "Greasy",
	"Lumpy", "Clumsy", "Moist", "Sassy", "Spicy", "Chunky", "Saucy", "Dizzy",
	"Wiggly", "Hairy", "Sleepy", "Squeaky", "Feral", "Humble", "Unwashed", "Haunted",
	"Itchy", "Bashful", "Captain", "Master", "Enormous", "Happy", "Obtuse",
]
const ADJECTIVE_CHANCE := 0.5


## TITLES THAT STAND ALONE (Parker 11-09): picked like any THING, but no DOER is added,
## so anyone can be "Edith the Wretch".
const ALONE := ["Wretch"]


static func make() -> String:
	var first: String = FIRST.pick_random()
	if randf() < ADJECTIVE_CHANCE:
		first = "%s %s" % [ADJECTIVE.pick_random(), first]
	var title: String = (THING + ALONE).pick_random()
	if title in ALONE:
		return "%s the %s" % [first, title]
	return "%s the %s %s" % [first, title, DOER.pick_random()]  # no dash (Parker 11-10)


static func tint(i: int) -> Color:
	return TINTS[i % TINTS.size()]
