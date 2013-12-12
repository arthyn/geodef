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


	network1 = createClient()

	network1:connect()

	spinner = widget.newSpinner{
		top = display.contentHeight * (2/8),
		left = display.contentWidth * (.5),
		time = 10000
	}
	

	spinner:start()

	waiting = display.newText( "Connecting to server...", 0, 0, native.systemFont, 50)
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

function stuff()
	    while not network1:isJoinedToRoom() do
	        network1:timer()
	        socket.sleep(1)
	    end
		waiting.text = "Waiting for an opponent..."

	    if table.getn(network1:myRoomActors()) == 1 then
	    	network1.host = true
	    end
end

function stuff2( )
	    while table.getn(network1:myRoomActors()) < 2 do
	        network1:timer()
	        socket.sleep(1)
	    end
		waiting.text = "Found opponent"
end

function scene:enterScene( event )
	local group = self.view
	--networking code should go here
	--when an opponent is found, transition to gameScreen

-- local client = LoadBalancingClient.new(appInfo.MasterAddress, appInfo.AppId, appInfo.AppVersion)


	--if display then
--	    network1.logger:info("Start")
--	    timer.performWithDelay( 1000, client, 0)
--	else

--	end

	    timer.performWithDelay( 1000, stuff, 0)


	    timer.performWithDelay( 2000, stuff2, 0)



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
	--storyboard.gotoScene("gameScreen", options)



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




function createClient()

	local client = LoadBalancingClient.new(appInfo.MasterAddress, appInfo.AppId, appInfo.AppVersion)

	local lastErrMess = ""

	math.randomseed( os.time() )

	client.mState = "Init"
	client.value = 1
	--client.sendvalue = 1
	client.mSendCount = 0
	client.mReceiveCount = 0
	client.mRunning = true
	client.id = math.random(100)
	client.host = false

	function client:onOperationResponse(errorCode, errorMsg, code, content)
	    self.logger:debug("onOperationResponse", errorCode, errorMsg, code, tableutil.toStringReq(content))
	    if errorCode ~= 0 then
	        if code == LoadBalancingConstants.OperationCode.JoinRandomGame then  -- master random room fail - try create
	            self.logger:info("createRoom")
	            self:createRoom("NetworkSwap")
	        end
	        if code == LoadBalancingConstants.OperationCode.CreateGame then -- master create room fail - try join random
	            self.logger:info("joinRandomRoom - 2")
	            self:joinRandomRoom(  )
	        end
	        if code == LoadBalancingConstants.OperationCode.JoinGame then -- game join room fail (probably removed while reconnected from master to game) - reconnect
	            self.logger:info("reconnect")
	            self:disconnect()
	        end
	    end
	end

	function client:onStateChange(state)
	    self.logger:debug("Demo: onStateChange " .. state .. ": " .. tostring(LoadBalancingClient.StateToName(state)))
	    if state == LoadBalancingClient.State.JoinedLobby then
	        self.logger:info("joinRandomRoom - 1")
	        self:joinRandomRoom(  )
	    end
	end

	function client:onError(errorCode, errorMsg)
	    if errorCode == LoadBalancingClient.PeerErrorCode.MasterAuthenticationFailed then
	        errorMsg = errorMsg .. " with appId = " .. self.appId .. "\nCheck app settings in cloud-app-info.lua"
	    end
	    self.logger:error(errorCode, errorMsg)
	    lastErrMess = errorMsg;
	end

	function client:onEvent(code, content, actorNr)
	    self.logger:debug("on event", code, tableutil.toStringReq(content))
	    print("RECEVIED EVENT")
	        client.mReceiveCount = client.mReceiveCount + 1
	        self.value = content[1]
	        if client.mReceiveCount == 500 then
	            self.mState = "Data Received"  
	            client:disconnect();
	        end
	end

	function client:update()
	    self:sendData()
	    self:service()
	end

	--local num = 1
	function client:sendData()
	    if self:isJoinedToRoom() then
	        self.mState = "Data Sending"    
	        local data = {}
	        data[1] =  self.value+self.id --math.random(1000)

	        self:raiseEvent( 10, data, { receivers = LoadBalancingConstants.ReceiverGroup.Others } ) 

	        self.mSendCount = self.mSendCount + 1
	        if self.mSendCount >= 500 then
	            self.mState = "Data Sent"
	        end
	    end
	end


	function client:getStateString()
	  --  num = self.value
	  return "ID: " .. self.id .. "  Data: " .. self.value
	end


	function client:timer(event)
	    local str = nil
	    if self.mRunning then
	        self:update()
	    else
	        timer.cancel(event.source)
	        self.mState = "Stopped"
	    end

	    str = client:getStateString()

	  --  stateText.text = LoadBalancingClient.StateToName(self.state)
	  --  thingText.text = str
	  --  countText.text = self.mSendCount

	end

	return client

end



return scene