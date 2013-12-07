local storyboard = require "storyboard"
local scene = storyboard.newScene()
local widget = require "widget"

local function createButton(buttonLabel, release)
	local button = widget.newButton{
		label = buttonLabel,
		labelColor = { default={255}, over={128} },
		fontSize = 30,
		width = 300,
		height = 100,
		onRelease = release
	}
	return button
end

local function cancelButtonRelease()
	storyboard.gotoScene("mainMenu")
	print("cancel")
	return true
end

function scene:createScene( event )
	local group = self.view

	local bg = display.newRect( 0, 0, display.contentWidth, display.contentHeight)
	bg:setFillColor(197, 197, 197)

	local spinner = widget.newSpinner{
		top = display.contentHeight * (2/8),
		left = display.contentWidth * (.5),
		time = 10000
	}
	spinner:start()

	local waiting = display.newText( "Waiting for an opponent...", 0, 0, native.systemFont, 50)
	waiting.x = display.contentWidth * (.5)
	waiting.y = display.contentHeight * (.5)

	local cancelButton = createButton("Cancel", cancelButtonRelease)
	cancelButton.x = display.contentWidth * (.5)
	cancelButton.y = display.contentHeight * (6/8)

	group:insert(bg)
	group:insert(spinner)
	group:insert(waiting)
	group:insert(cancelButton)

end

function scene:enterScene( event )
	local group = self.view

end

function scene:exitScene( event )
	local group = self.view
	
end

function scene:destroyScene( event )
	local group = self.view

end

scene:addEventListener("createScene", scene)
scene:addEventListener("enterScene", scene)
scene:addEventListener("exitScene", scene)
scene:addEventListener("destroyScene", scene)

return scene