eventLoop = EventLoop!
activeHeight = settings['hover-zone-height']
bottomZone = ActivityZone =>
	@reset 0, Window.h - activeHeight, Window.w, activeHeight

topZone = ActivityZone =>
		@reset 0, 0, Window.w, activeHeight,
	=>
		if Mouse.inWindow or not Mouse.dead
			return @containsPoint Mouse.x, Mouse.y
		else
			return false

-- This is kind of ugly but I have gone insane and don't care any more.
-- Watch the rapidly declining quality of this codebase in realtime.
local chapters, progressBar, barCache, barBackground, elapsedTime, remainingTime, hoverTime

if settings['enable-bar']
	progressBar = ProgressBar!
	barCache = ProgressBarCache!
	barBackground = ProgressBarBackground!
	bottomZone\addUIElement barBackground
	bottomZone\addUIElement progressBar
	bottomZone\addUIElement barCache

	mp.add_key_binding "c", "toggle-inactive-bar", ->
		BarBase.toggleInactiveVisibility!

if settings['enable-chapter-markers']
	chapters = Chapters!
	bottomZone\addUIElement chapters

if settings['enable-elapsed-time']
	elapsedTime = TimeElapsed!
	bottomZone\addUIElement elapsedTime

if settings['enable-remaining-time']
	remainingTime = TimeRemaining!
	bottomZone\addUIElement remainingTime

if settings['enable-hover-time']
	hoverTime = HoverTime!
	bottomZone\addUIElement hoverTime

title = nil
if settings['enable-title']
	title = Title!
	bottomZone\addUIElement title
	topZone\addUIElement title

if settings['enable-system-time']
	systemTime = SystemTime!
	bottomZone\addUIElement systemTime
	topZone\addUIElement title

-- The order of these is important, because the order that elements are added to
-- eventLoop matters, because that controls how they are layered (first element
-- on the bottom).
eventLoop\addZone bottomZone
eventLoop\addZone topZone
eventLoop\generateUIFromZones!

notFrameStepping = false
if settings['pause-indicator']
	PauseIndicatorWrapper = ( event, paused ) ->
		if notFrameStepping
			PauseIndicator eventLoop, paused
		elseif paused
			notFrameStepping = true

	mp.add_key_binding '.', 'step-forward',
		->
			notFrameStepping = false
			mp.commandv 'frame_step',
		{ repeatable: true }

	mp.add_key_binding ',', 'step-backward',
		->
			notFrameStepping = false
			mp.commandv 'frame_back_step',
		{ repeatable: true }

	mp.observe_property 'pause', 'bool', PauseIndicatorWrapper

streamMode = false
initDraw = ->
	mp.unregister_event initDraw
	-- this forces sizing activityzones and ui elements
	eventLoop\update!
	if chapters
		chapters\createMarkers!
	if title
		title\updatePlaylistInfo!
	notFrameStepping = true
	-- duration is nil for streams of indeterminate length
	duration = mp.get_property 'duration'
	if not (streamMode or duration)
		BarAccent.changeBarSize 0
		if progressBar
			eventLoop\removeSubscriber progressBar.index
			eventLoop\removeSubscriber barCache.index
			eventLoop\removeSubscriber barBackground.index
		if chapters
			eventLoop\removeSubscriber chapters.index
		if hoverTime
			eventLoop\removeSubscriber hoverTime.index
		if remainingTime
			eventLoop\removeSubscriber remainingTime.index
		streamMode = true
	elseif streamMode and duration
		BarAccent.changeBarSize settings['bar-height-active']
		if progressBar
			eventLoop\addSubscriber barBackground
			eventLoop\addSubscriber barCache
			eventLoop\addSubscriber progressBar
		if chapters
			eventLoop\addSubscriber chapters
		if hoverTime
			eventLoop\addSubscriber hoverTime
		if remainingTime
			eventLoop\addSubscriber remainingTime
		eventLoop\forceResize!
		streamMode = false

	mp.command 'script-message-to osc disable-osc'

fileLoaded = ->
	mp.register_event 'playback-restart', initDraw

mp.register_event 'file-loaded', fileLoaded
