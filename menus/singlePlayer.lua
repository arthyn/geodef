local storyboard = require "storyboard"
local scene = storyboard.newScene()
local widget = require "widget"
local function createButton(buttonLabel, release)
	local button = widget.newButton{
		label = buttonLabel,
		labelColor = { default={255}, over={128} },
		fontSize = 20,
		width = 150,
		height = 60,
		onRelease = release,
		defaultFile = "button.png"
	}
	return button
end

function quitButtonRelease()
	troops = {}
	troopCount = 0
	storyboard.gotoScene("mainMenu")
end

function scene:createScene( event )
	local group = self.view

	coins = 10
	health = 100 --decrease this when a troop makes it to your base

	local quitButton = createButton("Quit", quitButtonRelease)
	quitButton.x = display.contentWidth * (.15)
	quitButton.y = display.contentHeight * (.9)

	healthDisplay = display.newText(health .. " HP", 0, 0, native.systemFont, 40)
	healthDisplay.x = display.contentWidth * (.3)
	healthDisplay.y = display.contentHeight * (.9)

	coinsDisplay = display.newText(coins.. " Coins", 0, 0, native.systemFont, 40)
	coinsDisplay.x = display.contentWidth * (.7)
	coinsDisplay.y = display.contentHeight * (.9)

	group:insert(quitButton)
	group:insert(coinsDisplay)
	group:insert(healthDisplay)

end

function scene:enterScene( event )
	local group = self.view
	path = event.params.pathSend
	pathSize = event.params.sizeSend
	gridGroup = display.newGroup()
	if event.params.towerSend == nil then
		print("Entry from first screen")
		
		towers = {} --this is a list of all the towers 0 represents no tower, 1,2,3 represents color
		grid = {} --this is a list of squares
		towerCount = 0 --keep track of how many towers you have
		
		BuildGrid(points,grid,height,width)
	end
		DrawPath(path,pathSize,grid)

	spawnList = {}
	for i=1,10 do
		temp = math.random(1,3)
		if temp==1 then
			spawnList[i] = "red"
		elseif temp == 2 then
			spawnList[i] = "green"
		elseif temp == 3 then
			spawnList[i] = "blue"
		end
	end

	GameLogic(spawnList)
end

function scene:exitScene( event )
	local group = self.view
	display.remove( gridGroup )
	
end

function scene:destroyScene( event )
	local group = self.view

end

scene:addEventListener("createScene", scene)
scene:addEventListener("enterScene", scene)
scene:addEventListener("exitScene", scene)
scene:addEventListener("destroyScene", scene)



function ChangeColor(event)

	--toggle color on tap

	if event.target.color == "none" and coins > 0 then
		event.target.color = "red"
		grid[event.target.xPos][event.target.yPos].color = "red"
		event.target.index = towerCount --so next time its clicked you know what index number it is in the tower array
		towers[towerCount] = event.target
		towers[towerCount].coolDown = 5
		towerCount = towerCount + 1
		coins = coins - 1
		coinsDisplay.text = coins .. " Coins"
		event.target:setFillColor(255,0,0)
		event.target.strokeWidth = 2
		event.target:setStrokeColor(0,255,255)

	elseif event.target.color == "red" then
		event.target.color = "blue"
		grid[event.target.xPos][event.target.yPos].color = "blue"
		event.target:setFillColor(0,0,255)
		event.target.strokeWidth = 2
		event.target:setStrokeColor(255,0,0)
	elseif event.target.color == "blue" then
		event.target.color = "green"

		event.target:setFillColor(55,125,35)
		event.target.strokeWidth = 2
		event.target:setStrokeColor(170,85,187)
	else
		event.target.color = "none"
		grid[event.target.xPos][event.target.yPos].color = "none"
		event.target:setFillColor(0,0,0,0)
		event.target.strokeWidth = 1
		event.target:setStrokeColor(255,255,255,25)
		table.remove(towers,event.target.index)
		event.target.index = 0
		towerCount = towerCount - 1
		coins = coins + 1		
		coinsDisplay.text = coins .. " Coins"
		 
	end
	return true

end
function reBuildGrid(copiedGrid, height, width)
	local screenWidth = display.contentWidth 
	local screenHeight = display.contentHeight - 100  --The subtraction is for menu space
	towerCount = 0
	for xPiece = 0, width do
		points[xPiece] = {}
		for yPiece = 0, height do
			points[xPiece][yPiece] = {}
			points[xPiece][yPiece].x = xPiece*screenWidth/width
			points[xPiece][yPiece].y = yPiece*screenHeight/height	
		end
	end


	local count = 0
	for x = 0, width - 1 do
		for y = 0, height - 1 do
			top1 = points[x][y]
			top2 = points[x+1][y]
			bottom1 = points[x][y+1]
			bottom2 = points[x+1][y+1]
			rectangle = display.newRect(gridGroup, top1.x +2, top1.y +2, screenWidth/width -2, screenHeight/height - 2)
			rectangle:setFillColor(0,0,0,0)
			rectangle.strokeWidth = 1
			rectangle:setStrokeColor(255,255,255, 25)
			rectangle.color = copiedGrid[x][y].rect.color
			rectangle.xPos = x
			rectangle.yPos = y
			grid[x][y].rect = {}
			
			if rectangle.color == "green" then
				towers[towerCount] = rectangle
				towerCount = towerCount + 1
				rectangle:setFillColor(55,125,35)
				rectangle.strokeWidth = 2
				rectangle:setStrokeColor(170,85,187)
			elseif rectangle.color == "red" then
				towers[towerCount] = rectangle
				towerCount = towerCount + 1
				rectangle:setFillColor(255,0,0)
				rectangle.strokeWidth = 2
				rectangle:setStrokeColor(0,255,255)
			elseif rectangle.color == "blue" then
				towers[towerCount] = rectangle
				towerCount = towerCount + 1
				rectangle:setFillColor(0,0,255)
				rectangle.strokeWidth = 2
				rectangle:setStrokeColor(255,255,0)
			else 
				rectangle.color = "none"
			rectangle:setFillColor(0,0,0,0)
			rectangle.strokeWidth = 1
			rectangle:setStrokeColor(255,255,255, 25)
			end
			rectangle:addEventListener("tap", ChangeColor)
			grid[x][y].rect = rectangle
			count = count + 1 
		end
	end
--[[	for x = 0, width do
		for y = 0, height do
			
			local myCircle = display.newCircle(gridGroup, points[x][y].x, points[x][y].y, 5 )
			myCircle:setFillColor(128,128,128)
			myCircle.alpha = 0;
			transition.to( myCircle, {time=1000, alpha=1})
		end
	end
]]
end

function BuildGrid(points,grid,height, width)

	local screenWidth = display.contentWidth 
	local screenHeight = display.contentHeight - 100  --The subtraction is for menu space

	for xPiece = 0, width do
		points[xPiece] = {}
		for yPiece = 0, height do
			points[xPiece][yPiece] = {}
			points[xPiece][yPiece].x = xPiece*screenWidth/width
			points[xPiece][yPiece].y = yPiece*screenHeight/height	
		end
	end


	local count = 0
	for x = 0, width - 1 do
		grid[x] = {}
		for y = 0, height - 1 do

			top1 = points[x][y]
			top2 = points[x+1][y]
			bottom1 = points[x][y+1]
			bottom2 = points[x+1][y+1]
			grid[x][y] = {} 
			rectangle = display.newRect(gridGroup, top1.x +2, top1.y +2, screenWidth/width -2, screenHeight/height - 2)
			rectangle:setFillColor(0,0,0,0)
			rectangle.strokeWidth = 1
			rectangle:setStrokeColor(255,255,255, 25)
			rectangle.color = "none"
			rectangle.xPos = x
			rectangle.yPos = y
			grid[x][y].rect = {}
			grid[x][y].rect = rectangle
			rectangle:addEventListener("tap", ChangeColor)
			count = count + 1 
		end
	end
	--[[for x = 0, width do
		for y = 0, height do
			
			local myCircle = display.newCircle(gridGroup, points[x][y].x, points[x][y].y, 5 )
			myCircle:setFillColor(128,128,128)
			myCircle.alpha = 0;
			transition.to( myCircle, {time=1000, alpha=1})
		end
	end
]]
end

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

function DrawPath(path, pathSize, grid)
	for index = 0, pathSize-1 do
		grid[path[index].x][path[index].y].rect:setFillColor(204,229,255)  --color of the path
		grid[path[index].x][path[index].y].rect.strokeWidth = 3            --width of the boarder around the path
		grid[path[index].x][path[index].y].rect:setStrokeColor(51,0,102) --boarder color
		grid[path[index].x][path[index].y].rect:removeEventListener("tap", ChangeColor)

	end
end


function SpawnTroop(color)
	-- Spawns troops on the first cell of the path
	-- could change the path index to spawn on another cell
		troops[troopCount] = {}
		troops[troopCount] = display.newCircle( gridGroup, grid[path[0].x][path[0].y].rect.x, grid[path[0].x][path[0].y].rect.y, 10 )
		troops[troopCount].hp = 100
		troops[troopCount].maxhp = 100
		troops[troopCount].location = 0
		troops[troopCount].color = color
		troops[troopCount].alive = true
		if color == "red" then
			troops[troopCount]:setFillColor(255,0,0)
			troops[troopCount].strokeWidth = 2
			troops[troopCount]:setStrokeColor(0,0,0)
		elseif color == "blue" then
			troops[troopCount]:setFillColor(0,0,255)
			troops[troopCount].strokeWidth = 2
			troops[troopCount]:setStrokeColor(0,0,0)
		else
			color = "green"
			troops[troopCount]:setFillColor(55,125,35)
			troops[troopCount].strokeWidth = 2
			troops[troopCount]:setStrokeColor(0,0,0)
		end
		
		troopCount = troopCount + 1

end

function MoveAllTroops()
	for index = 0, table.getn(troops) do -- loop through all spawned troops
		if troops[index].hp > 0  then --if troop is alive
		 	if troops[index].location ~= pathSize - 1 then -- and if its not on the last cell
				troops[index].location = troops[index].location + 1 --move a troop to the next cell
				current = troops[index].location
				TowersCanHit(troops[index])
				transition.to(troops[index],{  x=grid[path[current].x][path[current].y].rect.x, y=grid[path[current].x][path[current].y].rect.y}) --move the guy
			else --it is alive, and on the last cell
				if not troops[index].finished then
				troopFinishedMovingCount = troopFinishedMovingCount + 1
				troops[index].finished = true
					if health > 0 then
						health = health - 10
						print(health .. " Base damaged!") -- damage the base
						healthDisplay.text = health .. " HP"
					end
				end
			end

		else --if it is dead
			if troops[index].location ~= pathSize -1 then--if its not on the last cell and is dead
				troops[index].location = pathSize-1 -- move it to the end
				current = pathSize-1 
				troopFinishedMovingCount = troopFinishedMovingCount + 1 --update the finished moving count
				transition.to(troops[index],{  x=grid[path[current].x][path[current].y].rect.x, y=grid[path[current].x][path[current].y].rect.y}) --move the guy
			end
		end
		if troopFinishedMovingCount  >= troopCount then -- if all have reached the end
			print(troopFinishedMovingCount.. "   ".. troopCount)
			if RoundEnded == false then -- round ended
				print("round ended")
				coins = coins + 5
				troopFinishedMovingCount = 0
				RoundEnded = true
			end
		end
		coinsDisplay.text = coins .. " Coins" -- keep text field updated
		local restart = function () -- next loop of troops
			troops = {}
			troopCount = 0
			troopFinishedMovingCount = 0
			spawnList = {}
			for i=1, coins do
				temp = math.random(1,3)
				if temp==1 then
					spawnList[i] = "red"
				elseif temp == 2 then
					spawnList[i] = "green"
				elseif temp == 3 then
					spawnList[i] = "blue"
				end
			end
			print("Game Restarted")
			GameLogic(spawnList)
		end
		if index == troopCount - 1 and RoundEnded == true  then

			if health <= 0 then 
				timer.cancel( MoveTimer )
				local options = {params = {won = false}}
				--MoveAllTroopsToEnd()
				display.remove(gridGroup)
				storyboard.gotoScene( "endScreen", options ) --game over

			
			else
				waitedTime = 0
				timer.cancel( MoveTimer )
				--MoveAllTroopsToEnd()
				timer.performWithDelay( 10000, restart, 1)
			end
		end
	end
end

function MoveAllTroopsToEnd()
	current = pathSize - 1
	for i=0, table.getn(troops) do
		transition.to(troops[index],{  x=grid[path[current].x][path[current].y].rect.x, y=grid[path[current].x][path[current].y].rect.y}) --move the guy
	end
end

function GameLogic(spawnArray)
	--Take in array of troops to spawn, spawn one, move it, spawn another, move it
	RoundEnded = false
	--for num = 1, table.getn(spawnArray) do
	--	SpawnTroop(spawnArray[num])
	--	move = function() return MoveTroop(num-1) end
	--	timers[num] = timer.performWithDelay(500 , move, pathSize-1)
	--end
	troops = {}
	troopCount = 0
	spawnCount = 0
	troopFinishedMovingCount = 0
	spawnFunctionTimer = function () 
		spawnCount = spawnCount + 1
		return SpawnTroop(spawnArray[spawnCount])
	end
	timer.performWithDelay( 500 , spawnFunctionTimer, table.getn(spawnArray) )
	MoveTimer = timer.performWithDelay( 550 , MoveAllTroops, table.getn(spawnArray) + pathSize - 1)

	-- add funtion to shoot at the troops with a cool down of 1 second. 


	-- Tower array positions compared to troop array positions, if close enough, then shoot

end

function TowersCanHit(troop)
	--loop through all the towers and see if they can hit this troop
	--this function should get called every time a troop moves (MoveTroop function)
	if towerCount == 0 then
		return
	end

	if not troop.alive then
		return
	end

	for i=0,table.getn(towers) do
		xdistance = (troop.x - towers[i].x) ^ 2
		ydistance = (troop.y - towers[i].y) ^ 2
		troopDistance = (xdistance + ydistance)^(1/2)
		local minimumDistance = (display.contentWidth/width) * 2
		if troopDistance <= minimumDistance then
			towers[i].coolDown = towers[i].coolDown - 1
			if troop.hp > 0 then 
				if towers[i].coolDown <= 0 then
					laser = display.newLine(  towers[i].x, towers[i].y, troop.x, troop.y )
					laser.width = 3
					towers[i].coolDown = 5
					if towers[i].color == "red" then
						--if the color of the tower is red, then the laser is red
						laser:setColor(255,0,0)
						
					elseif towers[i].color == "blue" then
						--if the tower is blue then the laser is blue
						laser:setColor(0,0,255)


					elseif towers[i].color == "green" then
						--if the tower is green then the laser is green
						laser:setColor(55,125,35)
						

					end

					transition.to(laser,{alpha = 0, time = 100})

					if troop.color == towers[i].color then
						troop.hp = troop.hp - 20
					else  troop.hp = troop.hp - 4

					end

					if troop.hp <= 0 and troop.alive == true then
						troop.hp = 0
						troop.alive = false
						coins = coins + 1
						coinsDisplay.text = coins .. " Coins"
					end
				end
			--[[else 
				--audio.play(deathSound)
				troop.hp = 0
				if troop.alive == true then
					coins = coins + 1
					coinsDisplay.text = coins .. " Coins"
					troop.alive = false
				end]]

			end
		end
	end
end


function SendPathOverNetwork()
	-- If you are creator, send path
end

function ReceivePathOverNetwork()
	-- If you are not creator, receive path
end

function SendTroopsOverNetwork()
	-- At the end of your turn, send which type
end

function ReceiveTroopsOverNetwork()
	-- At the beginnning of your turn, receive where the enemy has placed their towers
end


function showTroopSelectPopup(troops)
	-- spawn a popup allowing the user to select what color troops they are sending 
end

function isRoundOver()
	-- determines if all the troops are dead
	--Build towers, select troops, send round done and array of troops
	--When you are done wait for the other player to send their troop array,
	--When they do, spawn troops and go. Once troops are done build towers and select troops
end





math.randomseed( os.time() ) --seed random number generator
math.random() --randomly generate a value
--deathSound = audio.loadStream("gameexplosion.wav")
points = {} --this is a list of all the points on the game

height = 10 --change this to alter how many cells for height
width = 20	--change this to alter how many cells per width
 --this is the path object that the troops walk on
troops = {} --this is a list of all the troops the enemy has sent at you
troopCount = 0 --this is to keep track of spawned troops
troopFinishedMovingCount = 0


--coins = 10 --change this to alter how much money you start with

--SpawnStack = {"red","blue","red","blue","green","blue","red","blue","green"}








return scene