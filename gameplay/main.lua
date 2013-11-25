-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- Your code here

function ChangeColor(event)
	event.target:setFillColor(25,25,25)

	print("click")
	--Open tower color selection menu
	return true

end


function BuildGrid(points,grid,height, width)

	local screenWidth = display.contentWidth
	local screenHeight = display.contentHeight

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
		rectangle:addEventListener("tap", ChangeColor)
		grid[x][y] = rectangle
		print(top1.x .. " ".. top1.y .. " To " .. bottom1.x .. " " .. bottom1.y)
		
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

function BuildPath(grid, height, width, path)
	--Build a path based off of the grid and put that into path
	math.randomseed( os.time() ) --seed random number generator
	math.random() --randomly generate a value
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

		print(direction .. " " .. lastDirection .. " X: " .. randomPlace.x .. " Y: " .. randomPlace.y)
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
		end
		
		direction = math.random(0, 2)
	end
	if count < (height * width)/3 then 
		for index = 0, count-1 do
			table.remove( path )
		end
		BuildPath(grid,height,width,path) --rebuild path
	end
	return count
	
end

function DrawPath(path, pathSize, grid)

	print(pathSize)
	for index = 0, pathSize-1 do
		print(path[index].x .. " " .. path[index].y)
		grid[path[index].x][path[index].y]:setFillColor(255,255,255)
		grid[path[index].x][path[index].y]:removeEventListener("tap", ChangeColor)

	end




end


function SpawnTroops( grid, path, pathSize, troops, troopCount )
	-- Spawns troops on the first cell of the path
	for createdTroops = 0, troopCount-1  do
		troops[createdTroops] = {}
		troops[createdTroops].hp = {}
		troops[createdTroops].hp = 100
		troops[createdTroops].maxhp = {}
		troops[createdTroops].maxhp = 100
		troops[createdTroops].troop = {} 
		troops[createdTroops].troop = display.newCircle( grid[path[0].x][path[0].y].x, grid[path[0].x][path[0].y].y, 10 )
		troops[createdTroops].troop:setFillColor(55,125,35)
	end

end

function MoveTroops(...)
	-- moves troops along the path
	arg = ...
	grid = arg[1]
	path = arg[2]
	cell = arg[3]
	troops = arg[4]
	pathSize = arg[5]
	index = arg[6]
	--transition the alpha to HP/(MAX HP) this way when a troop is hit, he will fade out
	if cell+1 < pathSize then
		arg[3] = arg[3] + 1
		transition.to(troops[index].troop, {x=grid[path[cell].x][path[cell].y].x, y=grid[path[cell].x][path[cell].y].y, time=500, delay=arg[3]*600 + index*300, alpha = troops[index].hp/troops[index].maxhp, onComplete = MoveTroops(...)})
	else if cell < pathSize then
		arg[3] = arg[3] + 1
		transition.to(troops[index].troop, {x=grid[path[cell].x][path[cell].y].x, y=grid[path[cell].x][path[cell].y].y, time=500, delay=arg[3]*600 + index*300, onComplete = completeListener})
	end
	end
end

function completeListener(event)
	print("Reached The base") --this is where we decrement the HP
		--put a check here to see if toops[index].hp is greater than zero. 
end

function TowerCanHit( troops, grid )
	-- determines wheter the tower can hit any of the troops
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

function showTowerColorPopup(towers)
	-- spawn a popup allowing the user to select which type of tower they are selecting
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







local points = {} --this is a list of all the points on the game
local grid = {} --this is a list of squares
local path = {} --this is the path object that the troops walk on
local troops = {} --this is a list of all the troops the enemy has sent at you
local towers = {} --this is a list of all the towers 0 represents no tower, 1,2,3 represents color
local height = 5 --change this to alter how many cells for height
local width = 10	--change this to alter how many cells per width
local coins = 0 --change this to alter how much money you start with
local health = 100 --decrease this when a troop makes it to your base
BuildGrid(points,grid,height,width)
local pathSize = BuildPath(grid,height,width,path)
DrawPath(path,pathSize,grid)
SpawnTroops( grid, path, pathSize, troops, 5 )
for index = 0, 4 do
	troops[index].hp = troops[index].hp - index * 20 -- testing damaging of troops
	MoveTroops({grid,path,1,troops,pathSize, index})
end
