local storyboard = require "storyboard"
local scene = storyboard.newScene()
local widget = require "widget"
troopsBought = {}
circles = display.newGroup()

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

local function backButtonRelease()
	storyboard.gotoScene( "gameScreen" )
end

function redTap(event)
	table.insert( troopsBought, "red" )
	drawTroopList()
end

function blueTap(event)
	table.insert( troopsBought, "blue" )
	drawTroopList()
end

function greenTap(event)
	table.insert( troopsBought, "green")
	drawTroopList()
end

function smallCircleTap(event)
	print("HEYYYYY")
	table.remove( troopsBought, event.target.index )
	drawTroopList()
end

function drawTroopList()
	display.remove( circles )
	circles = display.newGroup( )
	local size = table.maxn( troopsBought )
	for i=1,size do
		circle = display.newCircle(display.contentWidth * (i/size) - 30,
			display.contentHeight * (.5), 10)
		if troopsBought[i] == "red" then
			circle:setFillColor(255, 0, 0)
		elseif troopsBought[i] == "green" then
			circle:setFillColor(55, 125, 35)
		elseif troopsBought[i] == "blue" then
			circle:setFillColor(0, 0, 255)
		end
		circle.index = i
		circle:addEventListener("tap", smallCircleTap)
		circles:insert(circle)
	end
end

function scene:createScene( event )
	local group = self.view

	local redCircle = display.newCircle(display.contentWidth * (.3),
		display.contentHeight * (.1), 50)
	redCircle:setFillColor(255, 0, 0)
	redCircle:addEventListener("tap", redTap)

	local greenCircle = display.newCircle(display.contentWidth * (.5),
		display.contentHeight * (.1), 50)
	greenCircle:setFillColor(55, 125, 35)
	greenCircle:addEventListener("tap", greenTap)

	local blueCircle = display.newCircle(display.contentWidth * (.7),
		display.contentHeight * (.1), 50)
	blueCircle:setFillColor(0, 0, 255)
	blueCircle:addEventListener("tap", blueTap)

	coins = 100
	local coinsDisplay = display.newText(coins.. " coins", 0, 0, native.systemFont, 40)
	coinsDisplay.x = display.contentWidth * (.75)
	coinsDisplay.y = display.contentHeight * (.8)

	local backButton = createButton("Back", backButtonRelease)
	backButton.x = display.contentWidth * (.15)
	backButton.y = display.contentHeight * (.8)

	group:insert(redCircle)
	group:insert(blueCircle)
	group:insert(greenCircle)
	group:insert(coinsDisplay)
	group:insert(backButton)

end

function scene:enterScene( event )
	local group = self.view
	
end

function scene:exitScene( event )
	display.remove( circles )
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