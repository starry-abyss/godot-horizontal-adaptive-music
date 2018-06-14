extends Node

var gridSettingsScript = preload("res://music/gridSettings.gd")
export (bool) var showDebug = true

#export var capturedEvents = PoolStringArray()

#export var BPM = 140
#export var N_slash_4 = 4

#export (AudioStream) var stinger = null
#export (NodePath) var stinger = null
var stinger = null
# for stingers
var stingerPlayer = null

export (NodePath) var currentMusic = null
var previousMusic = null

var events = {}

var queuedEvent = null

var musicTransitionStartTime = -1
var musicGridSize = -1

#onready var eventTester = $eventTester

enum { STATE_MUSIC_ENDED, STATE_MUSIC, STATE_STINGER }

var currentState = STATE_MUSIC_ENDED

func stopMusic():
	for player in get_children():
		if player is AudioStreamPlayer:
			player.autoplay = false
			player.stop()
			
	previousMusic = null
	currentMusic = null

func _ready():
	if !showDebug:
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		$trackInfo.hide()
		$eventTester.hide()
	else:
		$trackInfo.show()
		$eventTester.show()
	
	if stinger != null:
		#stingerPlayer = AudioStreamPlayer.new()
		#stingerPlayer.stream = stinger
		#stinger.loop = false
		
		stingerPlayer = get_node(stinger)
		
		print("stinger init")
		
	for player in get_children():
		if player is AudioStreamPlayer:
			player.autoplay = false
			player.stop()
			
			player.connect("finished", self, "updateMusic")
			
		# add events to the event tester widget and to the table of events
		for event in player.get_children():
			#if event is musicTransitionScript:
				
			var children = event.get_children()
				
			if children.size() > 0:
				#var musicAfterTransition = event.musicAfterTransition
				var musicAfterTransition = NodePath(children[0].name)
				
				if !$eventTester.has_node(event.name):
					var button = Button.new()
					button.name = event.name
					button.text = event.name
					button.connect("pressed", self, "receiveEvent", [event.name])
					
					$eventTester.add_child(button)
				
				events[player.name + "_" + event.name] = { "stinger": event, "transition": musicAfterTransition }
				
		#$eventTester.update()

	pass
	
func processEvent(event):
	if event.stinger.stream == null:
		stingerPlayer = null
	else:
		stingerPlayer = event.stinger
	
	currentMusic = event.transition
	
	#if previousMusic != currentMusic:
	updateGrid()

	queuedEvent = null
	
func receiveEvent(eventName):
	var musicPlayer = get_node(currentMusic)
	
	if !events.has(musicPlayer.name + "_" + eventName):
		return
	
	var event = events[musicPlayer.name + "_" + eventName]
	
	#assert(musicPlayer != null)
			
	#var event = events[eventName]
	
	assert(event != null)
	
	#if event != null:
	if stingerPlayer == null || !stingerPlayer.playing:
		processEvent(event)
	else:
		queuedEvent = event
	
func enterState(state):
	match (state):
		STATE_MUSIC_ENDED:
			stopMusic()
			
		STATE_MUSIC:
			var musicPlayer = get_node(currentMusic)
			
			assert(musicPlayer != null)
			
			if musicPlayer.stream is AudioStreamOGGVorbis:
				musicPlayer.stream.loop = false
			else:
				musicPlayer.stream.loop_mode = AudioStreamSample.LOOP_DISABLED
			
			musicPlayer.play()
			print("music switch end")
			
			previousMusic = currentMusic
			
			stingerPlayer = null
			
			musicTransitionStartTime = -1
			musicGridSize = -1
			
			#get_node("/root/runner").setBPM(musicPlayer.BPM)
			
			#updateGrid()
			
			if queuedEvent != null:
				processEvent(queuedEvent)
			
		STATE_STINGER:
			if stingerPlayer == null:
				enterState(STATE_MUSIC)
			else:
				if stingerPlayer.stream is AudioStreamOGGVorbis:
					stingerPlayer.stream.loop = false
				else:
					stingerPlayer.stream.loop_mode = AudioStreamSample.LOOP_DISABLED
				
				stingerPlayer.play()
				
				print("stinger")
			
	currentState = state
	updateHint()
	
func processState(state):
		
	match (state):
		STATE_MUSIC_ENDED:
			if currentMusic != null:
				enterState(STATE_MUSIC)
			
		STATE_MUSIC:
			var musicPlayer = get_node(previousMusic)
			assert(musicPlayer != null)
			
			var transitionIsEnabled = false
			if musicTransitionStartTime >= 0 && musicGridSize > 0:
				var musicTransitionEndTime = musicTransitionStartTime + (musicGridSize - fmod(musicTransitionStartTime, musicGridSize))

				if musicPlayer.get_playback_position() >= musicTransitionEndTime:
					transitionIsEnabled = true

			if previousMusic != currentMusic:
			# && previousMusic != null:
				
				#print("music switch start", stingerPlayer)
				
				# previous is currently playing, current is next in queue
				if !musicPlayer.playing || transitionIsEnabled:
					musicPlayer.stop()
						
					#print("stinger player ", stingerPlayer)
						
					#if stingerPlayer != null && !stingerPlayer.playing:

					enterState(STATE_STINGER)
			#elif currentMusic != null:
			else:
			#&& previousMusic != null:
				#var musicPlayer = get_node(currentMusic)
			
				#assert(musicPlayer != null)
				
				if !musicPlayer.playing || transitionIsEnabled:
					enterState(STATE_MUSIC)
			
		STATE_STINGER:
			if stingerPlayer == null || !stingerPlayer.playing:
				enterState(STATE_MUSIC)
#			elif musicGridSize > 0:
#				assert(musicTransitionStartTime > 0)
#
#				var musicPlayerPrevious = get_node(previousMusic)
#				assert(musicPlayerPrevious != null)
#
#				musicTransitionStartTime 
				
	updateHint()
				
func updateMusic():
	processState(currentState)
	
func updateHint():
	var text = "Silence"
	
	if currentState == STATE_STINGER:
		text = "Stinger -> " + currentMusic.get_name(currentMusic.get_name_count() - 1)
	elif previousMusic != null:
		text = previousMusic.get_name(previousMusic.get_name_count() - 1)
		
		if currentMusic != previousMusic:
			if stingerPlayer != null && stingerPlayer.stream != null:
				#text = text + " (+stinger: " + stingerPlayer.stream + ")"
				text = text + " -> Stinger"

			text = text + " -> " + currentMusic.get_name(currentMusic.get_name_count() - 1)
	
	$trackInfo.text = text

func updateGrid():
	if previousMusic != null && previousMusic != currentMusic:
		var musicPlayer = get_node(previousMusic)
		
		assert(musicPlayer != null)
		
		if musicPlayer is gridSettingsScript:
			var quantizationIntervalMultiplier = 1.0
			var timeSignatureMultiplier = 1.0

			match musicPlayer.quantizationInterval:
				gridSettingsScript.INTERVAL_OFF:
					quantizationIntervalMultiplier = 0
				gridSettingsScript.INTERVAL_8:
					quantizationIntervalMultiplier = 8
				gridSettingsScript.INTERVAL_7:
					quantizationIntervalMultiplier = 7
				gridSettingsScript.INTERVAL_6:
					quantizationIntervalMultiplier = 6
				gridSettingsScript.INTERVAL_5:
					quantizationIntervalMultiplier = 5
				gridSettingsScript.INTERVAL_4:
					quantizationIntervalMultiplier = 4
				gridSettingsScript.INTERVAL_3:
					quantizationIntervalMultiplier = 3
				gridSettingsScript.INTERVAL_2:
					quantizationIntervalMultiplier = 2
				gridSettingsScript.INTERVAL_1:
					quantizationIntervalMultiplier = 1
				gridSettingsScript.INTERVAL_1_2:
					quantizationIntervalMultiplier = 1 / 2.0
				gridSettingsScript.INTERVAL_1_4:
					quantizationIntervalMultiplier = 1 / 4.0
				gridSettingsScript.INTERVAL_1_8:
					quantizationIntervalMultiplier = 1 / 8.0
				gridSettingsScript.INTERVAL_1_16:
					quantizationIntervalMultiplier = 1 / 16.0
				gridSettingsScript.INTERVAL_1_32:
					quantizationIntervalMultiplier = 1 / 32.0
			
			match musicPlayer.timeSignature:
				gridSettingsScript.SIGNATURE_2_4:
					timeSignatureMultiplier = 2
				gridSettingsScript.SIGNATURE_3_4:
					timeSignatureMultiplier = 3
				gridSettingsScript.SIGNATURE_4_4:
					timeSignatureMultiplier = 4
					
			#musicGridSize = musicPlayer.quantizationInterval / (musicPlayer.stream.get_length() / 60 * musicPlayer.BPM)
			musicGridSize = quantizationIntervalMultiplier * timeSignatureMultiplier / (musicPlayer.BPM / 60.0)
			
			#print("quantizationInterval: ", musicPlayer.quantizationInterval)
			#print("BPM: ", musicPlayer.BPM)
			print("grid period, s: ", musicGridSize)
		else:
			musicGridSize = -1
		
		if currentState == STATE_STINGER:
			musicTransitionStartTime = 0
		else:
			musicTransitionStartTime = musicPlayer.get_playback_position()
	else:
		musicTransitionStartTime = -1
		musicGridSize = -1

func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass

	updateMusic()
