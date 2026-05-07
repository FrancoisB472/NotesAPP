extends Label
class_name Spashtext

var one_liners : PackedStringArray = [
"Protect trans Rights!!(ง ✧_✧)ง",
"Gay people are so cool! <3",
"You look great today! (✧ω✧)",
"Toast is bread that finally accepted its fate (¬‿¬)",
"Elevators are boxes practicing vertical teleportation ",
"Clouds are sky’s poorly organized thought bubbles (・・)",
"Zebras are horses running low on paint (￣▽￣)",
"Chairs are furniture that gave up standing ",
"(•‿•)Shoes are floor negotiators with straps ",
"Sandwiches are edible arguments stacked neatly (ʘ‿ʘ)",
"Traffic lights control human patience levels (・へ・)",
"Penguins are birds who chose fashion over flight (◕‿◕)",
"(－‸ლ)Books are paper portals with attitude (✧✧)",
"Rain boots are puddle warriors with ambition (ง •̀_•́)ง",
"Clouds rehearse weather before committing (￣ー￣)",
"(ಠ‿ಠ)Ice cream is happiness on a deadline (＾▽＾)",
"Doors are reality’s pause buttons (ಠ‿ಠ)",
"Spaghetti is tangled food that refused structure (¬¬)",
"Carpets are floor camouflage specialists (・・;)",
"Stars are light bulbs that forgot ownership (✧ω✧)",
"Umbrellas are portable sky disagreements (￣︿￣)",
"Ladders are stair prototypes gone public (°▽°)",
"Pancakes are edible discs of joy engineering (＾◡＾)",
"Windows are reality’s framed screenshots (••)",
"Clouds are sky sheep with identity issues ",
"(¬‿¬)Socks are foot prisons with personality (￣︶￣)",
"Cats are liquid managers of household chaos (≧▽≦)",
"Rivers are water ignoring straight lines (・へ・)",
"Chairs are silent traps for productivity ",
"Lightning is sky rage quitting briefly (ಠωಠ)",
"Trees are antennae for earth gossip (ʘ‿ʘ)",
"Bread crumbs are tiny navigation failures (・・)",
"Alarm clocks are betrayal machines in disguise (ಠ_ಠ)",
"Clouds are vaporized indecision (￣ー￣)",
"Mirrors are honesty turned inconvenient (ಠωಠ)",
"(ಠ‿ಠ)Shoes are personality containers for feet (•‿•)",
"Doors are selective reality filters (￣︿￣)",
"Sandwiches are architecture experiments in lunch form ",
"Shadows are introverted copies ",
"Wind is invisible mischief with timing issues (¬¬)",
"Stars are distant confetti leftovers (・へ・)",
"Toast is bread doing performance art (￣▽￣)",
"Chairs are resting places for thoughts too (••)",
"Clouds are sky’s deleted drafts (・・)",
"Zebras are barcode horses on strike (￣ー￣)",
"Umbrellas are rain negotiation tools (ಠ‿ಠ)",
"Books are thoughts pretending to be physical (✧ω✧)",
"Ice cubes are water in temporary retirement (￣︶￣)",
"Carpets are dust collection with ambition (¬‿¬)",
"Ladders are vertical confidence tests (ง •̀_•́)ง",
"Pancakes are edible sun simulations (＾◡＾)",
]

func _ready() -> void:
	pivot_offset = size * 0.5
	randomize()
	splash()
	_play_tween()

func splash():
	if !one_liners:
		text = "Mr.Stark I don't fₑₑₗ ˢᵒ ᵍᵒᵒᵈ"

	text = one_liners[randi() % one_liners.size()]

func _play_tween() -> void:
	var tween = create_tween()
	
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_parallel(false)
	tween.set_loops()
	
	tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.75)
	tween.tween_property(self, "scale", Vector2(0.9, 0.9), 0.75)
