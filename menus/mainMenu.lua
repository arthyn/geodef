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
	path = {}
	height = 10
	width = 20
	pathSize = BuildPath(height,width,path)
	while pathSize < (height * width)/4 do  --if it doesn't use at least 1/3 of the grid
		for index = 0, pathSize-1 do
			table.remove( path )
		end
		pathSize = BuildPath(height,width,path) --rebuild path
	end
	local options = {
		params = {
			pathSend = path, sizeSend=pathSize
		}
	}
	storyboard.gotoScene("singlePlayer", options)
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
	path = {}
	height = 10
	width = 20
	pathSize = BuildPath(height,width,path)
	local options = {
		params = {
			pathSend = path, sizeSend=pathSize
		}
	}
	storyboard.gotoScene("gameScreen", options)
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

function BuildPath(height, width, path)
	--Build a path based off of the grid and put that into path
	
	starty = math.random(0,height-1) --generate between 0 and max height
	randomPlace = {}
	randomPlace.x = 0
	randomPlace.y = starty
	
	count = 0
	path[count]={}
	path[count].x = randomPlace.x
	path[count].y = randomPlace.y
	count = count + 1

	-- loop, choosing random direction until you get to grid[width-1][y]
	-- 0 for down, 1 for up 2 for right
		direction = math.random(0, 2)
		lastDirection = direction
	while randomPlace.x ~= width-1  do


		if direction == 0 and lastDirection ~= 1 then --down and just didn't go up
			if randomPlace.y < height-1 then  --not the bottom
				randomPlace.y = randomPlace.y + 1
				path[count]={}
				path[count].x = randomPlace.x
				path[count].y = randomPlace.y
				count = count + 1
				lastDirection = direction
			end

		end

		if direction == 1  and lastDirection ~= 0 then --up and just didn't go down
			if randomPlace.y > 0 then -- not the top
				randomPlace.y = randomPlace.y - 1
				path[count]={}
				path[count].x = randomPlace.x
				path[count].y = randomPlace.y
				count = count + 1
				lastDirection = direction
			end
		end

		if direction == 2 then
			if randomPlace.x < width-1 then --right
				randomPlace.x = randomPlace.x + 1
				path[count]={}
				path[count].x = randomPlace.x
				path[count].y = randomPlace.y
				count = count + 1
				lastDirection = direction
			end
			if randomPlace.x < width-1 then --right
				randomPlace.x = randomPlace.x + 1
				path[count]={}
				path[count].x = randomPlace.x
				path[count].y = randomPlace.y
				count = count + 1
				lastDirection = direction
			end
		end
		
		direction = math.random(0, 2)
	end
	return count
	
end

return scene
