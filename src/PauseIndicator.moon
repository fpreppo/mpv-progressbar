class PauseIndicator

	scaleMultiplier = settings['pause-indicator-scale']

	new: ( @eventLoop, paused ) =>
		w, h = mp.get_osd_size!
		w, h = 0.5*w, 0.5*h
		@line = {
			[[{\an5\bord0\c&H%s&]]\format settings['pause-indicator-background']
			[[\fscx0\fscy0]]           --  2
			[[\alpha&H]]               --  3
			0                          --  4
			[[&\pos(]]                 --  5
			[[%g,%g]]\format w, h      --  6
			[[)\p1}]]                  --  7
			0                          --  8
			[[{\an5\bord0\c&H%s&]]\format settings['pause-indicator-foreground']
			[[\fscx0\fscy0]]           -- 10
			[[\alpha&H]]               -- 11
			0                          -- 12
			[[&\pos(]]                 -- 13
			[[%g,%g]]\format w, h      -- 14
			[[)\p1}]]                  -- 15
			0                          -- 16
		}
		if paused
			@line[8]  = 'm 15 0 l 60 0 b 75 0 75 0 75 15 l 75 60 b 75 75 75 75 60 75 l 15 75 b 0 75 0 75 0 60 l 0 15 b 0 0 0 0 15 0 m 23 20 l 23 55 33 55 33 20 m 42 20 l 42 55 52 55 52 20\n'
			@line[16] = 'm 0 0 m 75 75 m 23 20 l 23 55 33 55 33 20 m 42 20 l 42 55 52 55 52 20'
		else
			@line[8]  = 'm 15 0 l 60 0 b 75 0 75 0 75 15 l 75 60 b 75 75 75 75 60 75 l 15 75 b 0 75 0 75 0 60 l 0 15 b 0 0 0 0 15 0 m 23 18 l 23 57 58 37.5\n'
			@line[16] = 'm 0 0 m 75 75 m 23 18 l 23 57 58 37.5'

		@animationCb = @\animate
		@finishedCb = @\destroy

		AnimationQueue.registerAnimation Animation 0, 1, 0.3, @animationCb, @finishedCb
		@eventLoop\addSubscriber @

	stringify: =>
		return table.concat @line

	updateSize: =>
		w, h = 0.5*Window.w, 0.5*Window.h
		@line[6]  = [[%g,%g]]\format w, h
		@line[14] = [[%g,%g]]\format w, h
		return true

	update: ->
		return true

	animate: ( animation, value ) =>
		scale = (value*50 + 100)*scaleMultiplier
		scaleStr = [[\fscx%g\fscy%g]]\format scale, scale
		alphaStr = '%02X'\format value*value*255
		@line[2]  = scaleStr
		@line[10] = scaleStr
		@line[4]  = alphaStr
		@line[12] = alphaStr

	destroy: ( animation ) =>
		@eventLoop\removeSubscriber @eventLoopIndex
