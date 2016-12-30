class Chapters extends BarBase
	minWidth = settings['chapter-marker-width']*100
	maxWidth = settings['chapter-marker-width-active']*100
	maxHeight = settings['bar-height-active']*100
	maxHeightFrac = settings['chapter-marker-active-height-fraction']

	new: =>
		super!
		@line = { }
		@markers = { }
		@animation = Animation 0, 1, @animationDuration, @\animate

	createMarkers: =>
		@line = { }
		@markers = { }

		-- small number to avoid division by 0
		totalTime = mp.get_property_number 'duration', 0.01
		chapters = mp.get_property_native 'chapter-list', { }

		markerHeight = @active and maxHeight*maxHeightFrac or BarBase.animationMinHeight
		markerWidth = @active and maxWidth or minWidth
		for chapter in *chapters
			marker = ChapterMarker chapter.time/totalTime, markerWidth, markerHeight
			table.insert @markers, marker
			table.insert @line, marker\stringify!
		@needsUpdate = true

	resize: =>
		for i, marker in ipairs @markers
			marker\resize!
			@line[i] = marker\stringify!
		@needsUpdate = true

	animate: ( value ) =>
		width = (maxWidth - minWidth)*value + minWidth
		height = (maxHeight*maxHeightFrac - BarBase.animationMinHeight)*value + BarBase.animationMinHeight
		for i, marker in ipairs @markers
			marker\animate width, height
			@line[i] = marker\stringify!

		@needsUpdate = true

	redraw: =>
		super!
		currentPosition = mp.get_property_number( 'percent-pos', 0 )*0.01
		update = false
		for i, marker in ipairs @markers
			if marker\redraw currentPosition
				@line[i] = marker\stringify!
				update = true

		return @needsUpdate or update
