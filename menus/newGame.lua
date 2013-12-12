local storyboard = require "storyboard"
local scene = storyboard.newScene()
local widget = require "widget"
local LoadBalancingClient
local LoadBalancingConstants
local Logger
local tableutil
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

math.randomseed(os.time())

Constants = {
    SendPath = 1,
    SendTroops = 2,
    GameResult = 3,
    LogLevel = Logger.Level.INFO,
}

local appInfo = require("cloud-app-info")

local function createClient()
    local client = LoadBalancingClient.new(appInfo.MasterAddress, appInfo.AppId, appInfo.AppVersion)

    -- connect to random room or create new one automatocally
    -- close button click sets this to false
    client.autoconnect = true

    client.logger:info("Init", appInfo.MasterAddress, appInfo.AppId, appInfo.AppVersion)
    client.logger:setPrefix("Game")
    client:setLogLevel(Constants.LogLevel)
    client:myActor():setName(math.floor(math.random() * 100))

    function client:start()
        self.winCondition = false
        self:connect()
        print(self:isConnectedToMaster())
        print(self:isInLobby())
    end

    function client:service1()
            self:service()
        end

    function client:onStateChange(state)
            local info = nil
            if state == LoadBalancingClient.State.Joined then
                info =  self:myRoom().name
            end

            if state == LoadBalancingClient.State.JoinedLobby then
                print("Joined Lobby, Joining Random Room")
                if self.autoconnect then
                    self:joinRandomRoom()
                end
            elseif state == LoadBalancingClient.State.Error then
                self:reset(true)
            end
        end

    function client:onJoinRoom()
        self.logger:info("Joined Room: ", self:myRoom().name)
        self.logger:info("onJoinRoom myRoom", self:myRoom())
        self.logger:info("onJoinRoom myActor", self:myActor())
        self.logger:info("onJoinRoom myRoomActors", self:myRoomActors())
        
    end


    function client:onEvent(code, content, actorNr)
            if code == Constants.SendPath then
                client.params = content
            elseif code == Constants.SendTroops then
                client.spawnList = content
            elseif code == Constants.GameResult then
                client.winCondition = content[1]
            end
            self.logger:debug("Game: onEvent", code, "content:", content, "actor:", actorNr)
        end

   function client:onError(errorCode, errorMsg)
    	if errorCode == LoadBalancingClient.PeerErrorCode.MasterAuthenticationFailed then
    		errorMsg = errorMsg .. " with appId = " .. self.appId
    	end
        self.logger:error(errorCode, errorMsg)
    end

    function client:onOperationResponse(errorCode, errorMsg, code, content)
        self.logger:info("onOperationResponse", errorCode, errorMsg, code, tableutil.toStringReq(content))
        if errorCode ~= 0 then
            if code == LoadBalancingConstants.OperationCode.JoinRandomGame then  -- master random room fail - try create
                self.logger:info("createRoom")
                self:createRoom("autochat")
            end
            if code == LoadBalancingConstants.OperationCode.CreateGame then -- master create room fail - try join random
                self.logger:info("joinRandomRoom - 2")
                self:joinRandomRoom()
            end
            if code == LoadBalancingConstants.OperationCode.JoinGame then -- game join room fail (probably removed while reconnected from master to game) - reconnect
                self.logger:info("reconnect")
                self:disconnect()
            end
        end
    end

    return client
end

local client = createClient()
client:start()
client:service1()
timer.performWithDelay( 100, function() client:service1() end, 0)

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
	
	client.params = {}

	--If you are player one generate the path and send it to the other player
	actorList = client:myRoomActors()
	if(table.getn(actorList) == 1) then
		path = {}
		height = 10
		width = 20
		pathSize = BuildPath(height,width,path)
		params = {pathSend = path, sizeSend=pathSize}
		client.params = params
		client:raiseEvent(Constants.SendPath, params, {receivers = LoadBalancingConstants.ReceiverGroup.Others})
	end
	table.insert(client.params, client)
	local options = {client.params}
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