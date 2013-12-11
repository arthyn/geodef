local storyboard = require "storyboard"
local scene = storyboard.newScene()
local widget = require "widget"

local function createButton(buttonLabel, release)
	local button = widget.newButton{
		label = buttonLabel,
		labelColor = { default={255}, over={128} },
		fontSize = 30,
		width = 200,
		height = 75,
		onRelease = release
	}
	return button
end

function quitButtonRelease()
	storyboard.gotoScene("mainMenu")
end

function troopsButtonRelease()
	storyboard.gotoScene("buyTroops")
end

function scene:createScene( event )
	local group = self.view

	local quitButton = createButton("Quit", quitButtonRelease)
	quitButton.x = display.contentWidth * (.15)
	quitButton.y = display.contentHeight * (.9)

	local troopsButton = createButton("Buy Troops", troopsButtonRelease)
	troopsButton.x = display.contentWidth * (.85)
	troopsButton.y = display.contentHeight * (.9)

	coins = 100
	local coinsDisplay = display.newText(coins.. " coins", 0, 0, native.systemFont, 40)
	coinsDisplay.x = display.contentWidth * (.5)
	coinsDisplay.y = display.contentHeight * (.9)

	group:insert(quitButton)
	group:insert(troopsButton)
	group:insert(coinsDisplay)

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