-----------------------------------------------------------------------------------------
-- Course/Section: CMPS 453
-- Group: C
--
-- Create grid - MICAH RIGGAN / JAMIE JUNEAU
-- Create tower select popup - STEPHEN ROTEN / JAMIE JUNEAU
-- Spawn enemies - RAYMOND REED / ZACK THEVENOT
-- Create a path - JAMIE JUNEAU / ANGELOS PILLOS
-- Make enemies traverse path - RAYMOND REED / RYAN HALEY
-- Towers attack - TRAVIS DEROUEN / HUNTER MILLER
--
-- Certificate of Authenticity:
-- 
-- We certify that the code in this 
-- project is entirely our own work. 
--
-----------------------------------------------------------------------------------------

local redEnemy = display.newImage( "../images/enemy/red.png" )
local yellowEnemy = display.newImage( "../images/enemy/yellow.png" )
local greenEnemy = display.newImage( "../images/enemy/green.png" )
local pinkEnemy = display.newImage( "../images/enemy/pink.png" )
local blueEnemy = display.newImage( "../images/enemy/blue.png" )
local orangeEnemy = display.newImage( "../images/enemy/orange.png" )

local redTower = display.newImage( "../images/tower/red.png" )
local yellowTower = display.newImage( "../images/tower/yellow.png" )
local greenTower = display.newImage( "../images/tower/green.png" )
local pinkTower = display.newImage( "../images/tower/pink.png" )
local blueTower = display.newImage( "../images/tower/blue.png" )
local orangeTower = display.newImage( "../images/tower/orange.png" )

-- Prototype: function ChangeColor(event)
-- Description: Change the color of the towers when you tap
function ChangeColor(event)

	--toggle color on tap
	if event.target.color == "none" then
		event.target.color = "red"
		event.target.index = towerCount --so next time its clicked you know what index number it is in the tower array
		towers[towerCount] = event.target
		towerCount = towerCount + 1
		coins = coins - 1
		event.target:setFillColor(255,0,0)

	elseif event.target.color == "red" then
		event.target.color = "blue"
		event.target:setFillColor(0,0,255)
	elseif event.target.color == "blue" then
		event.target.color = "green"

		event.target:setFillColor(55,125,35)
	else
		 event.target.color = "none"
		 event.target:setFillColor(140,140,140)
		 table.remove(towers,event.target.index)
		 event.target.index = 0
		 towerCount = towerCount - 1
		
		 coins = coins + 1		
		 GameLogic(SpawnStack) --this will get called when you
	end
	return true

end

-- The following function builds the grid

function BuildGrid(points,grid,height, width)

	local screenWidth = display.contentWidth 
	local screenHeight = display.contentHeight  --The subtraction is for menu space

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
		grid[x][y] = {}
		top1 = points[x][y]
		top2 = points[x+1][y]
		bottom1 = points[x][y+1]
		bottom2 = points[x+1][y+1]
		rectangle = display.newRect(top1.x +2, top1.y +2, screenWidth/width -2, screenHeight/height - 2)
		rectangle:setFillColor(140,140,140)
		rectangle:setStrokeColor(255,255,255)
		rectangle.color = "none"
		rectangle.xPos = x
		rectangle.yPos = y
		grid[x][y].rect = {}
		grid[x][y].rect = rectangle
		rectangle:addEventListener("tap", ChangeColor)
		
		count = count + 1 
		end
	end
	for x = 0, width do
		for y = 0, height do
			
			local myCircle = display.newCircle( points[x][y].x, points[x][y].y, 5 )
			myCircle:setFillColor(128,128,128)
			myCircle.alpha = 0;
			transition.to( myCircle, {time=1000, alpha=1})
		end
	end

end

-- The following functions generates the array for drawing the path --

function BuildPath(grid, height, width, path)
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
            if randomPlace.x < width-1 then --right
				randomPlace.x = randomPlace.x + 1
				path[count]={}
				path[count].x = randomPlace.x
				path[count].y = randomPlace.y
				count = count + 1
                end

				lastDirection = direction
			end
		end
		
		direction = math.random(0, 2)
	end
	if count < (height * width)/4 then  --if it doesn't use at least 1/3 of the grid
		for index = 0, count-1 do
			table.remove( path )
		end
		BuildPath(grid,height,width,path) --rebuild path
	end
	return count
	
end

-- The following function draws the generated path --

function DrawPath(path, pathSize, grid)

	print(pathSize)
	for index = 0, pathSize-1 do

		grid[path[index].x][path[index].y].rect:setFillColor(255,255,255)
		grid[path[index].x][path[index].y].rect:removeEventListener("tap", ChangeColor)

	end




end


function SpawnTroop(color)
	-- Spawns troops on the first cell of the path
	-- could change the path index to spawn on another cell
		troops[troopCount] = {}
		troops[troopCount] = display.newCircle( grid[path[0].x][path[0].y].rect.x, grid[path[0].x][path[0].y].rect.y, 10 )
		troops[troopCount].hp = 100
		troops[troopCount].maxhp = 100
		troops[troopCount].location = 0
		troops[troopCount].color = color
		if color == "red" then
			troops[troopCount]:setFillColor(255,0,0)
		elseif color == "blue" then
			troops[troopCount]:setFillColor(0,0,255)
		else
			color = "green"
			troops[troopCount]:setFillColor(55,125,35)
		end
		
		troopCount = troopCount + 1

end


function MoveTroop(index)
	troops[index].location = troops[index].location + 1 --move a troop to the next cell
	current = troops[index].location
	TowersCanHit(troops[index])
	--if next cell isnt the end
	if current == pathSize-1 and troops[index].hp > 0  then
		health = health - 1
		print(health .. " Base damaged!")
		
	end
	transition.to(troops[index],{ delay = index * 350, x=grid[path[current].x][path[current].y].rect.x, y=grid[path[current].x][path[current].y].rect.y, alpha=troops[index].hp/troops[index].maxhp})
	-- if it is the end, damage the base

end

function GameLogic(spawnArray)
	--Take in array of troops to spawn, spawn one, move it, spawn another, move it
	for num = 1, table.getn(spawnArray) do
		SpawnTroop(spawnArray[num])
		move = function() return MoveTroop(num-1) end
		timer.performWithDelay(500, move, pathSize-1)
	end

	-- add funtion to shoot at the troops with a cool down of 1 second. 


	-- Tower array positions compared to troop array positions, if close enough, then shoot

end

function TowersCanHit(troop)
	--loop through all the towers and see if they can hit this troop
	--this function should get called every time a troop moves (MoveTroop function)
	for i=0,table.getn(towers) do
		xdistance = (troop.x - towers[i].x) ^ 2
		ydistance = (troop.y - towers[i].y) ^ 2
		troopDistance = (xdistance + ydistance)^(1/2)
		local minimumDistance = (display.contentWidth/width) * 3
		if troopDistance <= minimumDistance then
			if troop.hp > 0 then
				print(troop.hp)
				laser = display.newLine(  towers[i].x, towers[i].y, troop.x, troop.y )
				laser.width = 3
				if towers[i].color == "red" then
					laser:setColor(255,0,0)
				elseif towers[i].color == "blue" then
					laser:setColor(0,0,255)
				elseif towers[i].color == "green" then
					laser:setColor(55,125,35)
				end

				transition.to(laser,{alpha = 0, time = 100})

				if troop.color == towers[i].color then
					troop.hp = troop.hp - 4
				else
					troop.hp = troop.hp - 2
				end
				if troop.hp < 0 then
					troop.hp = 0
				end
			else 
				troop.hp = 0

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

points = {} --this is a list of all the points on the game
grid = {} --this is a list of squares
height = 10 --change this to alter how many cells for height
width = 20	--change this to alter how many cells per width
path = {} --this is the path object that the troops walk on
troops = {} --this is a list of all the troops the enemy has sent at you
troopCount = 0 --this is to keep track of spawned troops
towers = {} --this is a list of all the towers 0 represents no tower, 1,2,3 represents color
towerCount = 0 --keep track of how many towers you have
coins = 10 --change this to alter how much money you start with
health = 100 --decrease this when a troop makes it to your base
BuildGrid(points,grid,height,width)
pathSize = BuildPath(grid,height,width,path)
DrawPath(path,pathSize,grid)
SpawnStack = {"red","blue","red","blue","green","blue","red","blue","green"}


