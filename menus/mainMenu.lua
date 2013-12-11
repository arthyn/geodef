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

local function newGameButtonRelease()
	return true
end

local function settingsButtonRelease()
	storyboard.gotoScene("settings")
	return true
end

local function helpButtonRelease()
	storyboard.gotoScene("help")
	return true
end

local function multiplayerButtonRelease()
	storyboard.gotoScene("newGame")
	return true
end

local function creditsButtonRelease()
	storyboard.gotoScene("creditsScreen")
	return true
end

function scene:createScene( event )
	local group = self.view

	-- create all items here

	local background = display.newImage( "wallpaper.png")
	background:translate(0,0)
	background:setFillColor(math.random(50, 255), math.random(50, 255), math.random(50, 255))

	local name = display.newText("geodef", 0, 0, native.systemFont, 100)
	name.x = display.contentWidth * .5
	name.y = display.contentHeight * (4/13)

	local newGameButton = createButton("Single Player", newGameButtonRelease)
	newGameButton.x = display.contentWidth * .25
	newGameButton.y = display.contentHeight * (4/8)
	


	local multiplayerButton = createButton("Multiplayer", multiplayerButtonRelease)
	multiplayerButton.x = display.contentWidth * .75
	multiplayerButton.y = display.contentHeight * (4/8)

	local settingsButton = createButton("Settings", settingsButtonRelease)
	settingsButton.x = display.contentWidth * .80
	settingsButton.y = display.contentHeight * (6/8)

	local helpButton = createButton("Help", helpButtonRelease)
	helpButton.x = display.contentWidth * .20
	helpButton.y = display.contentHeight * (6/8)

	local creditsButton = createButton("Credits", creditsButtonRelease)
	creditsButton.x = display.contentWidth * .50
	creditsButton.y = display.contentHeight * (6/8)
	

	-- insert all objects here
	group:insert(background)
	group:insert(creditsButton)
	group:insert(multiplayerButton)
	group:insert(name)
	group:insert(newGameButton)
	group:insert(settingsButton)
	group:insert(helpButton)

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
