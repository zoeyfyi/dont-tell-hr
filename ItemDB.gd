class_name ItemDB

static var StunPen: Dictionary = {
	"id": "stun_pen",
	"texture": preload("res://assets/pen.png"),
	"text": "Stun Pen\n[b]1[/b] [color=red]damage[/color]",
	"slot": Main.Slot.SLOT_WEAPON,
	"damage": 1,
	"scene": "res://ShockPen.tscn",
}

static var BBGun: Dictionary = {
	"id": "bb_gun",
	"texture": preload("res://assets/pen.png"),
	"text": "BB Gun\n[b]3[/b] [color=red]damage[/color]",
	"slot": Main.Slot.SLOT_WEAPON,
	"damage": 3,
	"scene": "res://BBGun.tscn",
}

static var PaperHat: Dictionary = {
	"id": "paper_hat",
	"texture": preload("res://icon.svg"),
	"text": "Paper Hat\n[b]1[/b] [color=silver]armor[/color]",
	"slot": Main.Slot.SLOT_HEAD,
	"armor": 1,
}

static var StrawHat: Dictionary = {
	"id": "straw_hat",
	"texture": preload("res://icon.svg"),
	"text": "Straw Hat\n[b]2[/b] [color=silver]armor[/color]",
	"slot": Main.Slot.SLOT_HEAD,
	"armor": 2,
}

static var CycleHelmet: Dictionary = {
	"id": "cycle_helmet",
	"texture": preload("res://icon.svg"),
	"text": "Cycle Helmet\n[b]5[/b] [color=silver]armor[/color]",
	"slot": Main.Slot.SLOT_HEAD,
	"armor": 5,
}

static var SkaterHelmet: Dictionary = {
	"id": "skater_helmet",
	"texture": preload("res://icon.svg"),
	"text": "Skater Helmet\n[b]8[/b] [color=silver]armor[/color]",
	"slot": Main.Slot.SLOT_HEAD,
	"armor": 8,
}

static var Hoodie: Dictionary = {
	"id": "hoodie",
	"texture": preload("res://icon.svg"),
	"text": "Hoodie\n[b]2[/b] [color=silver]armor[/color]",
	"slot": Main.Slot.SLOT_CHEST,
	"armor": 2,
}

static var PufferJacket: Dictionary = {
	"id": "puffer_jacket",
	"texture": preload("res://icon.svg"),
	"text": "Puffer Jacket\n[b]4[/b] [color=silver]armor[/color]",
	"slot": Main.Slot.SLOT_CHEST,
	"armor": 4,
}

static var Shorts: Dictionary = {
	"id": "shorts",
	"texture": preload("res://icon.svg"),
	"text": "Shorts\n[b]1[/b] [color=silver]armor[/color]",
	"slot": Main.Slot.SLOT_LEG,
	"armor": 1,
}

static var Jeans: Dictionary = {
	"id": "jeans",
	"texture": preload("res://icon.svg"),
	"text": "Jeans\n[b]3[/b] [color=silver]armor[/color]",
	"slot": Main.Slot.SLOT_LEG,
	"armor": 3,
}

static var InsulatedTrousers: Dictionary = {
	"id": "insulated_trousers",
	"texture": preload("res://icon.svg"),
	"text": "Insulated Trousers\n[b]6[/b] [color=silver]armor[/color]",
	"slot": Main.Slot.SLOT_LEG,
	"armor": 6,
}

static var FlipFlops: Dictionary = {
	"id": "flip_flops",
	"texture": preload("res://icon.svg"),
	"text": "Flip flops\n[b]1[/b] [color=silver]armor[/color]",
	"slot": Main.Slot.SLOT_SHOE,
	"armor": 1,
}

static var Trainers: Dictionary = {
	"id": "trainers",
	"texture": preload("res://icon.svg"),
	"text": "Trainers\n[b]3[/b] [color=silver]armor[/color]",
	"slot": Main.Slot.SLOT_SHOE,
	"armor": 3,
}

static var SteelToeBoots: Dictionary = {
	"id": "steel_toe_boots",
	"texture": preload("res://icon.svg"),
	"text": "Steel Toe Boots\n[b]10[/b] [color=silver]armor[/color]",
	"slot": Main.Slot.SLOT_SHOE,
	"armor": 10,
}

static var armor_distribution = {
	PaperHat["id"]: 20,
	StrawHat["id"]: 15,
	CycleHelmet["id"]: 10,
	SkaterHelmet["id"]: 5,
	Hoodie["id"]: 15,
	PufferJacket["id"]: 10,
	Shorts["id"]: 20,
	Jeans["id"]: 10,
	InsulatedTrousers["id"]: 5,
	FlipFlops["id"]: 30,
	Trainers["id"]: 15,
	SteelToeBoots["id"]: 5
}

static var armor = {
	PaperHat["id"]: PaperHat,
	StrawHat["id"]: StrawHat,
	CycleHelmet["id"]: CycleHelmet,
	SkaterHelmet["id"]: SkaterHelmet,
	Hoodie["id"]: Hoodie,
	PufferJacket["id"]: PufferJacket,
	Shorts["id"]: Shorts,
	Jeans["id"]: Jeans,
	InsulatedTrousers["id"]: InsulatedTrousers,
	FlipFlops["id"]: FlipFlops,
	Trainers["id"]: Trainers,
	SteelToeBoots["id"]: SteelToeBoots
}

static var weapon_distribution = {
	BBGun["id"]: 10,
}

static var weapons = {
	BBGun["id"]: BBGun,
}

static func roll_armor(count: int) -> Dictionary:
	var choices = []
	for key in armor_distribution.keys():
		for i in armor_distribution[key]:
			choices.append(key)
	choices.shuffle()
	
	var d: Dictionary = {}
	
	for i in count:
		var choice = choices.pop_back()
		d[choice] = armor[choice]

	return d
	
static func roll_weapons(count: int) -> Dictionary:
	var choices = []
	for key in weapon_distribution.keys():
		for i in weapons[key]:
			choices.append(key)
	choices.shuffle()
	
	var d: Dictionary = {}
	
	for i in count:
		var choice = choices.pop_back()
		d[choice] = weapons[choice]
		
	return d
