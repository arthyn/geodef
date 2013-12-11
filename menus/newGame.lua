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

	--networking code should go here
	--when an opponent is found, transition to gameScreen


	--If you are player one generate the path and send it to the other player
	path = {}
	height = 10
	width = 20
	pathSize = BuildPath(height,width,path)
	print(pathSize)
	local options = {
		params = {
			pathSend = path, sizeSend=pathSize
		}
	}
	storyboard.gotoScene("gameScreen", options)



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
	if count < (height * width)/4 then  --if it doesn't use at least 1/3 of the grid
		for index = 0, count-1 do
			table.remove( path )
		end
		BuildPath(height,width,path) --rebuild path
	end
	return count
	
end



return scene