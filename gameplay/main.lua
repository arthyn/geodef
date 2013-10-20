-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- Your code here

function ChangeColor(event)
	event.target:setFillColor(25,25,25)
	print("click")
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
		for y = 0, height - 1 do
		grid[count] = {}
		top1 = points[x][y]
		top2 = points[x+1][y]
		bottom1 = points[x][y+1]
		bottom2 = points[x+1][y+1]
		rectangle = display.newRect(top1.x +2, top1.y +2, screenWidth/width -2, screenHeight/height - 2)
		rectangle:setFillColor(140,140,140)
		rectangle:addEventListener("touch", ChangeColor)
		grid[count] = rectangle
		print(top1.x .. " ".. top1.y .. " To " .. bottom1.x .. " " .. bottom1.y)
		display.newLine(top1.x + 3, top1.y, top2.x -3, top2.y)
		display.newLine(bottom1.x +3, bottom1.y , bottom2.x+3, bottom2.y)
		display.newLine(top1.x+1, top1.y, bottom1.x+1, bottom1.y)
		display.newLine(top2.x-1 , top2.y , bottom2.x-1, bottom2.y)
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





local points = {}
local grid = {}
local height = 10
local width = 5
BuildGrid(points,grid,height,width)


