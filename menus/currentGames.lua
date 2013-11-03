local storyboard = require "storyboard"
local scene = storyboard.newScene()
local widget = require "widget"

local function tableViewListener( event )
	local phase = event.phase
	local row = event.target
end

local function onRowRender( event )
	local phase = event.phase
	local row = event.row

	--get title and set size
	local rowTitle = display.newText( row, row.index, 0, 0, nil, 14 )
end

local function onRowTouch( event )
	local phase = event.phase

	if "press" == phase then
		print("row ", event.target.index)
	end
end

local gamesView

function scene:createScene( event )
	local group = self.view

	local tableView = widget.newTableView{
	    listener = tableViewListener,
	    onRowRender = onRowRender,
	    onRowTouch = onRowTouch
	}

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
