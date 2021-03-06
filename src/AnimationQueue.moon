class AnimationQueue

	animationList = Stack 'active'
	deletionQueue = { }

	@addAnimation: ( animation ) ->
		unless animation.active
			animationList\insert animation

	@removeAnimation: ( animation ) ->
		if animation.active
			animationList\remove animation

	@destroyAnimationStack: ->
		animationList\clear!

	@animate: ->
		if #animationList == 0
			return
		currentTime = mp.get_time!
		for _, animation in ipairs animationList
			if animation\update currentTime
				table.insert deletionQueue, animation

		if #deletionQueue > 0
			animationList\removeSortedList deletionQueue

	@active: ->
		return #animationList > 0
