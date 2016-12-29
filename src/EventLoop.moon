class EventLoop

	new: =>
		@script = { }
		@uiElements = Stack!
		@activityZones = Stack!
		@displayRequested = false

		@updateTimer = mp.add_periodic_timer settings['redraw-period'], @\redraw

		mp.register_event 'shutdown', ->
			@updateTimer\kill!

		local displayRequestTimer
		displayDuration = settings['request-display-duration']

		mp.add_key_binding "tab", "request-display",
			( event ) ->
				-- Complex bindings will always fire repeat events and the best we can
				-- do is to quickly return.
				if event.event == "repeat"
					return
				-- The "press" event happens when a simulated keypress happens through
				-- the JSON IPC, the client API and through the mpv command interface. I
				-- don't know if it will ever happen with an actual key event.
				if event.event == "down" or event.event == "press"
					if displayRequestTimer
						displayRequestTimer\kill!
					@displayRequested = true
				if event.event == "up" or event.event == "press"
					if displayDuration == 0
						@displayRequested = false
					else
						displayRequestTimer = mp.add_timeout displayDuration, ->
							@displayRequested = false,
			{ complex: true }

	addZone: ( zone ) =>
		if zone == nil
			return
		@activityZones\insert zone

	removeZone: ( zone ) =>
		if zone == nil
			return
		@activityZones\remove zone

	generateUIFromZones: =>
		seenUIElements = { }
		for _, zone in ipairs @activityZones
			for _, uiElement in ipairs zone.elements
				unless seenUIElements[uiElement]
					@addUIElement uiElement
					seenUIElements[uiElement] = true

	addUIElement: ( uiElement ) =>
		if uiElement == nil
			error 'nil UIElement added.'
		@uiElements\insert uiElement
		table.insert @script, ''

	removeUIElement: ( uiElement ) =>
		if uiElement == nil
			error 'nil UIElement removed.'
		-- this is kind of janky as it relies on an implementation detail of Stack
		-- (i.e. that it stores the element index in the under the hashtable key of
		-- the stack instance itself)
		table.remove @script, uiElement[@uiElements]
		@uiElements\remove uiElement

	redraw: ( forceRedraw ) =>
		clickPending = Mouse\update!
		needsResize = Window\update!

		for index, zone in @activityZones
			if needsResize
				zone\resize!
			if zone\update( @displayRequested, clickPending ) and not forceRedraw
				forceRedraw = true

		if forceRedraw or AnimationQueue.active!
			AnimationQueue.animate!
			for index, uiElement in ipairs @uiElements
				if uiElement.active and uiElement\redraw!
					if needsResize
						uiElement\resize!
					@script[index] = uiElement\stringify!
			mp.set_osd_ass Window.w, Window.h, table.concat @script, '\n'
