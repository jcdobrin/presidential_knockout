extends Node

var GameMode=''
var FightLevel=''
var Records={
	'Version':1,
	'Easy': {
		'Level 1': {
			'HIGHSCORE':0,
			'ACHIEVEMENTS':{},
		},
		'Level 2':{
			'HIGHSCORE':0,
			'ACHIEVEMENTS':{},
		},
		'Level 3':{
			'HIGHSCORE':0,
			'ACHIEVEMENTS':{},
		},
	},
	'Normal':{
		'Level 1':{
			'HIGHSCORE':0,
			'ACHIEVEMENTS':{},
		},
		'Level 2':{
			'HIGHSCORE':0,
			'ACHIEVEMENTS':{},
		},
		'Level 3':{
			'HIGHSCORE':0,
			'ACHIEVEMENTS':{},
		},
	},
	'Hard':{
		'Level 1':{
			'HIGHSCORE':0,
			'ACHIEVEMENTS':{},
		},
		'Level 2':{
			'HIGHSCORE':0,
			'ACHIEVEMENTS':{},
		},
		'Level 3':{
			'HIGHSCORE':0,
			'ACHIEVEMENTS':{},
		},
	},
	'Story':{
		'Level 1':{
			'HIGHSCORE':0,
			'ACHIEVEMENTS':{},
		},
		'Level 2':{
			'HIGHSCORE':0,
			'ACHIEVEMENTS':{},
		},
		'Level 3':{
			'HIGHSCORE':0,
			'ACHIEVEMENTS':{},
		},
	},
}
var EarlyAccessSupport = false

onready var MenuMusic = get_node("MenuMusic")


func loadRecords():
	var save_game = File.new()
	if not save_game.file_exists("user://records.save"):
		
		return # Error! We don't have a save to load.
		
	save_game.open("user://records.save", File.READ)
	while save_game.get_position() < save_game.get_len():
		# Get the saved dictionary from the next line in the save file
		Records = parse_json(save_game.get_line())
	pass

func writeRecords():
	var save_game = File.new()
	save_game.open("user://records.save", File.WRITE)
	save_game.store_line(to_json(Records))
	pass

func writeScore(score):
	if(Records[GameMode][FightLevel]['HIGHSCORE'] < score):
		Records[GameMode][FightLevel]['HIGHSCORE'] = score
		writeRecords()




#google pay plugin
var payment
func _ready():
	loadRecords()
	var screen_size = OS.get_screen_size(0)
	var window_size = OS.get_window_size()
	#OS.set_window_position(screen_size*0.5 - window_size*0.5)
	
	if Engine.has_singleton("GodotGooglePlayBilling"):
		payment = Engine.get_singleton("GodotGooglePlayBilling")

		# These are all signals supported by the API
		# You can drop some of these based on your needs
		payment.connect("connected", self, "_on_connected") # No params
		payment.connect("disconnected", self, "_on_disconnected") # No params
		payment.connect("connect_error", self, "_on_connect_error") # Response ID (int), Debug message (string)
		payment.connect("purchases_updated", self, "_on_purchases_updated") # Purchases (Dictionary[])
		payment.connect("purchase_error", self, "_on_purchase_error") # Response ID (int), Debug message (string)
		payment.connect("sku_details_query_completed", self, "_on_sku_details_query_completed") # SKUs (Dictionary[])
		payment.connect("sku_details_query_error", self, "_on_sku_details_query_error") # Response ID (int), Debug message (string), Queried SKUs (string[])
		payment.connect("purchase_acknowledged", self, "_on_purchase_acknowledged") # Purchase token (string)
		payment.connect("purchase_acknowledgement_error", self, "_on_purchase_acknowledgement_error") # Response ID (int), Debug message (string), Purchase token (string)
		payment.connect("purchase_consumed", self, "_on_purchase_consumed") # Purchase token (string)
		payment.connect("purchase_consumption_error", self, "_on_purchase_consumption_error") # Response ID (int), Debug message (string), Purchase token (string)

		payment.startConnection()
	else:
		print("Android IAP support is not enabled. Make sure you have enabled 'Custom Build' and the GodotGooglePlayBilling plugin in your Android export settings! IAP will not work.")

func _on_connected():
	payment.querySkuDetails(["early_access_support"], "inapp") # "subs" for subscriptions

func _on_sku_details_query_completed(sku_details):
	for available_sku in sku_details:
		print(available_sku)

func paymentReady():
	if payment != null:
		return payment.isReady()
	return false

func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		get_tree().quit() # default behavior

func checkPurchases():
	if paymentReady():
		var query = payment.queryPurchases("inapp")
		if(query.status == OK):
			for purchase in query.purchases:
				if(purchase.sku == 'early_access_support'):
					EarlyAccessSupport = true
					if !purchase.is_acknowledged:
						payment.acknowledgePurchase(purchase.purchase_token)
	pass
