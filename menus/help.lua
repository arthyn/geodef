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
		onRelease = release,
		defaultFile = "button.png"
	}
	return button
end

local function backButtonRelease()
	storyboard.gotoScene("mainMenu")
end

function scene:createScene( event )
	local group = self.view

	local background = display.newImage( "wallpaper.png")
	--background:translate(0,0)
	background:setFillColor(math.random(50, 255), math.random(50, 255), math.random(50, 255))
	background.width = display.contentWidth
	background.height = display.contentHeight
	background.x = display.contentWidth/2
	background.y = display.contentHeight/2
	--local name = display.newText("geodef", 0, 0, native.systemFont, 100)
	--name.x = display.contentWidth * .5
	--name.y = display.contentHeight * (4/13)

	local logo = display.newImage( "logo.png")
	logo:setFillColor(math.random(50, 255), math.random(50, 255), math.random(50, 255))
	logo:scale(1.5,1.5 ) 
	logo:translate(0,0)
	logo.x = display.contentWidth * .5
	logo.y = display.contentHeight * (4/14)

	local text = display.newText(" ~ Tap to place the default tower type \n ~ Keep taping to change tower type \n ~ Towers do more damage to same type troops \n ~ Troops reduce health if they reach the base \n ~ Player loses when they run out of health \n ~ In multiplayer, you win when opponent loses \n ~ In single player, you play until you lose ", display.contentWidth/5, display.contentHeight/2.3, display.contentWidth, display.contentHeight, native.systemFont, 25)

	local backButton = createButton("Back", backButtonRelease)
	backButton.x = display.contentWidth * (.5)
	backButton.y = display.contentHeight * (.9)

	group:insert(background)
	group:insert(text)
	group:insert(backButton)
	group:insert(logo)

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