local storyboard = require "storyboard"
local scene = storyboard.newScene()
local widget = require "widget"

local LoadBalancingClient
local LoadBalancingConstants
local tableutil
local Logger
local photon

if pcall(require,"plugin.photon") then -- try to load Corona photon plugin
    photon = require "plugin.photon"    
    LoadBalancingClient = photon.loadbalancing.LoadBalancingClient
    LoadBalancingConstants = photon.loadbalancing.constants
    Logger = photon.common.Logger
    tableutil = photon.common.util.tableutil    
else  -- or load photon.lua module
    photon = require("photon")
    LoadBalancingClient = require("photon.loadbalancing.LoadBalancingClient")
    LoadBalancingConstants = require("photon.loadbalancing.constants")
    Logger = require("photon.common.Logger")
    tableutil = require("photon.common.util.tableutil")    
end

local appInfo = require("cloud-app-info")

local net = require "network"


Constants = 
		{
			SendPath = 0,
			SendTroops = 1,
			GameResult = 2, 
			Ack = 99
		}

circles = display.newGroup()

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
	local options = {
		params = {
			pathSend = path,
			pathSizeSend = pathSize,
			coinSend = coins,
			hpSend = health,
			gridSend = grid,
			towerSend = towers,
			roundCountSend = roundCount,
			networkSend = network1
		}
	}
	storyboard.gotoScene( "gameScreen", options )
end

function checkJumpBack( )

	if(table.getn(network1.troops) == 0) then
		network1:service()
	else
		timer.cancel(jumpBack)

		print("sending path size " .. pathSize)
		local options = {
							params = {
								pathSend = path,
								hpSend = health,
								pathSizeSend = pathSize,
								coinSend = coins,
								gridSend = grid,
								towerSend = towers,
								roundCountSend = roundCount,
								spawnList = network1.troops,
								networkSend = network1
							}
						}
		local troops = {
			spawnList = troopsBought
		}		
		network1:raiseEvent(Constants.SendTroops, troops, { receivers = LoadBalancingConstants.ReceiverGroup.Others })
		network1:service()

		storyboard.gotoScene( "gameScreen", options )
	end
end

local function finishButtonRelease()
	
	local troops = {
			spawnList = troopsBought
		}

	--table.remove(params, networkSend)

	network1:raiseEvent(Constants.SendTroops, troops, { receivers = LoadBalancingConstants.ReceiverGroup.Others })
	network1:service()

	finishButton:setEnabled(false)

	jumpBack = timer.performWithDelay( 500, checkJumpBack, 0)


	-- while(table.getn(network1.troops) == 0) do
	-- 	network1:service()
	-- 	socket.sleep(5)
	-- end
	-- print("sending path size " .. pathSize)
	-- local options = {
	-- 	params = {
	-- 		pathSend = path,
	-- 		hpSend = health,
	-- 		pathSizeSend = pathSize,
	-- 		coinSend = coins,
	-- 		gridSend = grid,
	-- 		towerSend = towers,
	-- 		roundCountSend = roundCount,
	-- 		spawnList = network1.troops,
	-- 		networkSend = network1
	-- 	}
	-- }

	-- storyboard.gotoScene( "gameScreen", options )
end

function redTap(event)
	if coins > 0 then
		finishButton:setEnabled(true)
		table.insert( troopsBought, "red" )
		coins = coins - 1 
		coinsDisplay.text = coins .. " Coins"
		drawTroopList()
	end
end

function blueTap(event)
	if coins > 0 then
		finishButton:setEnabled(true)
		table.insert( troopsBought, "blue" )
		coins = coins - 1
		coinsDisplay.text = coins .. " Coins"
		drawTroopList()
	end
end

function greenTap(event)
	if coins > 0 then
		finishButton:setEnabled(true)
		table.insert( troopsBought, "green")
		coins = coins - 1
		coinsDisplay.text = coins .. " Coins"
		drawTroopList()
	end
end

function smallCircleTap(event)
	table.remove( troopsBought, event.target.index )
	coins = coins + 1
	coinsDisplay.text = coins .. " Coins"
	if(table.getn(troopsBought) == 0) then
		finishButton:setEnabled(false)
	end
	drawTroopList()
end

function drawTroopList()
	display.remove( circles )
	circles = display.newGroup( )
	local size = table.maxn( troopsBought )
	for i=1,size do
		circle = display.newCircle(display.contentWidth * (i/size) - 30,
			display.contentHeight * (.5), 30)
		if troopsBought[i] == "red" then
			circle:setFillColor(255, 0, 0)
			circle.strokeWidth = 2
			circle:setStrokeColor(0,0,0)
		elseif troopsBought[i] == "green" then
			circle:setFillColor(55, 125, 35)
			circle.strokeWidth = 2
			circle:setStrokeColor(0,0,0)
		elseif troopsBought[i] == "blue" then
			circle:setFillColor(0, 0, 255)
			circle.strokeWidth = 2
			circle:setStrokeColor(0,0,0)
		end
		circle.index = i
		circle:addEventListener("tap", smallCircleTap)
		circles:insert(circle)
	end
end

function scene:createScene( event )
	local group = self.view
	coins = event.params.coinsSend
	path = event.params.pathSend
	health = event.params.hpSend

	pathSize = event.params.pathSizeSend
	print("sending path size " .. pathSize)
	coins = event.params.coinsSend
	grid = event.params.gridSend
	towers = event.params.towerSend
	network1 = event.params.networkSend


	local redCircle = display.newCircle(display.contentWidth * (.3),
		display.contentHeight * (.1), 50)
	redCircle:setFillColor(255, 0, 0)
	redCircle.strokeWidth = 2
	redCircle:setStrokeColor(0,0,0)
	redCircle:addEventListener("tap", redTap)

	local greenCircle = display.newCircle(display.contentWidth * (.5),
		display.contentHeight * (.1), 50)
	greenCircle:setFillColor(55, 125, 35)
	greenCircle.strokeWidth = 2
	greenCircle:setStrokeColor(0,0,0)
	greenCircle:addEventListener("tap", greenTap)

	local blueCircle = display.newCircle(display.contentWidth * (.7),
		display.contentHeight * (.1), 50)
	blueCircle:setFillColor(0, 0, 255)
	blueCircle.strokeWidth = 2
	blueCircle:setStrokeColor(0,0,0)
	blueCircle:addEventListener("tap", blueTap)
	coinsDisplay = display.newText(coins.. " Coins", 0, 0, native.systemFont, 40)
	coinsDisplay.x = display.contentWidth * (.5)
	coinsDisplay.y = display.contentHeight * (.8)

	backButton = createButton("Back", backButtonRelease)
	backButton.x = display.contentWidth * (.15)
	backButton.y = display.contentHeight * (.8)

	finishButton = createButton("Attack!", finishButtonRelease)
	finishButton.x = display.contentWidth * (.85)
	finishButton.y = display.contentHeight * (.8)

	group:insert(redCircle)
	group:insert(blueCircle)
	group:insert(greenCircle)
	group:insert(coinsDisplay)
	group:insert(backButton)
	group:insert(finishButton)

end

function scene:enterScene( event )
	local group = self.view
	network1.troops = {}
	finishButton:setEnabled(false)
	troopsBought = {}

	
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