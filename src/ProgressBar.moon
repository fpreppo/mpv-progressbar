class ProgressBar extends Rect

	new: ( @aggregator, @animationQueue ) =>
		super 0, 0, 0, 0

		@line = {
			[[{\an1\bord0\c&FC799E&\p3\pos(]]
			0
			[[)\fscx]]
			0
			[[\fscy]]
			100
			[[}m 0 0 l ]]
			0
		}

		@needsUpdate = false
		@animationCb = @\animateHeight
		@heightAnimation = Animation 100, 400, 0.25, @animationCb
		@aggregator\addSubscriber @

	__tostring: =>
		return table.concat @line

	bar_height = 2
	hover_zone = 20
	updateSize: ( w, h ) =>
		@y = h - hover_zone*bar_height
		@w, @h = w, hover_zone*bar_height

		@line[2] = ([[%d,%d]])\format 0, h
		@line[8] = ([[%d 0 %d %d 0 %d]])\format w*4, w*4, bar_height*4, bar_height*4
		return true

	animateHeight: ( animation, value ) =>
		@line[6] = ([[%g]])\format value
		@needsUpdate = true

	lastPosition = 0
	update: ( mouseX, mouseY ) =>
		update = @needsUpdate
		if @containsPoint mouseX, mouseY
			unless @hovered
				update = true
				@hovered = true
				if @heightAnimation.isReversed
					@heightAnimation\reverse!
				unless @heightAnimation.isRegistered
					@heightAnimation\restart!
					@animationQueue\registerAnimation @heightAnimation
		else
			if @hovered
				update = true
				@hovered = false
				unless @heightAnimation.isReversed
					@heightAnimation\reverse!
				unless @heightAnimation.isRegistered
					@heightAnimation\restart!
					@animationQueue\registerAnimation @heightAnimation

		position = mp.get_property_number( 'percent-pos' )
		if position != lastPosition
			update = true
			@line[4] = ([[%g]])\format position or 0
			lastPosition = position

		@needsUpdate = false
		return update
