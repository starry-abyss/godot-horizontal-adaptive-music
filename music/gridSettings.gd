extends AudioStreamPlayer

export (int, "OFF", "8", "7", "6", "5", "4", "3", "2", "1", "1/2", "1/4", "1/8", "1/16", "1/32") var quantizationInterval = INTERVAL_1
export (float) var BPM = 140
export (int, "2/4", "3/4", "4/4") var timeSignature = SIGNATURE_4_4

enum { INTERVAL_OFF, INTERVAL_8, INTERVAL_7, INTERVAL_6, INTERVAL_5, INTERVAL_4, INTERVAL_3, 
INTERVAL_2, INTERVAL_1, INTERVAL_1_2, INTERVAL_1_4, INTERVAL_1_8, INTERVAL_1_16, INTERVAL_1_32 }

enum { SIGNATURE_2_4, SIGNATURE_3_4, SIGNATURE_4_4 }

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
