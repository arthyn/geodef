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

local function cancelButtonRelease()
	storyboard.gotoScene("mainMenu")
	return true
end

function scene:createScene( event )
	local group = self.view

	local background = display.newImage( "wallpaper.png")
	--background:translate(0,0)
	background:setFillColor(math.random(50, 255), math.random(50, 255), math.random(50, 255))
	background.width = display.contentWidth
	background.height = display.contentHeight
	background.x = display.contentWidth/2
	background.y = display.contentHeight/2
	--background:scale(1602/display.contentWidth, 1) 

	local logo = display.newImage( "logo.png")
	logo:setFillColor(math.random(50, 255), math.random(50, 255), math.random(50, 255))
	logo:scale(1.5,1.5 ) 


	logo:translate(0,0)
	logo.x = display.contentWidth * .5
	logo.y = display.contentHeight * (4/14)
	

	network1 = createClient()

	network1:connect()

	spinner = widget.newSpinner{
		top = display.contentHeight * (3/5),
		left = display.contentWidth * .49,
		time = 10000
	}
	

	spinner:start()

	waiting = display.newText( "Connecting to server...", 0, 0, native.systemFont, 50)
	waiting.x = display.contentWidth * (.5)
	waiting.y = display.contentHeight * (.5)

	local cancelButton = createButton("Cancel", cancelButtonRelease)
	cancelButton.x = display.contentWidth * (.5)
	cancelButton.y = display.contentHeight * (6/8)

	group:insert(background)
	group:insert(logo)
	group:insert(spinner)
	group:insert(waiting)
	group:insert(cancelButton)


end

function JoinLobby()

	    while not network1:isJoinedToRoom() do
	        network1:timer()
	        socket.sleep(1)
	    end

		waiting.text = "Waiting for an opponent..."

	    if table.getn(network1:myRoomActors()) == 1 then
	    	network1.host = true
	    end
	    print(network1:myRoom())
	    print(network1:availableRooms())
	    ConnectToPlayer()
end

function ConnectToPlayer( )
	    while table.getn(network1:myRoomActors()) < 2 do
	    	print(table.getn(network1:myRoomActors()))
	        network1:timer()
	        socket.sleep(0.5)
	    end

	    print(table.getn(network1:myRoomActors()))

		waiting.text = "Found opponent"
		if network1.host then
			waiting.text = "Found opponent : Is host"
		end

		GoToGame()
end

function keepSendingEvent( )
	
    	network1:raiseEvent( Constants.SendPath, params, { receivers = LoadBalancingConstants.ReceiverGroup.Others } ) 
end

function GoToGame( )

	if network1.host then
		print("\n\n IS HOST \n\n")

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

		print(pathSize)
		-- local options = {
		-- 	params = {
		-- 		path, pathSize
		-- 	}
		-- }

  --       options = {
	 --        params = {
		--         pathSend = path,
		--         pathSizeSend = pathSize,
		--         networkSend = network1
	 --    	}
	 --    }
		--
        -- local data = {}
        -- data[1] =  path
        -- data[2] =  height

     --    while table.getn(network1:myRoomActors()) < 2 do
     --    	print("k");
     --    	network1:service()
	    --     socket.sleep(0.1)
     --    end

     --    socket.sleep(0.1)

    	-- network1:raiseEvent( Constants.SendPath, params, { receivers = LoadBalancingConstants.ReceiverGroup.Others } ) 


		-- print("\n\nGo to game scene - host\n\n")

	 --    storyboard.gotoScene("gameScreen", options)
	else
		while true do
			network1:service()
		end
	end

end

function f(  )
	-- body
	network1:timer()
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

    -- timer.performWithDelay( 1000, JoinLobby, 1)

    --timer.performWithDelay( 2000, ConnectToPlayer, 1)

    CONNECTIONTIMER = timer.performWithDelay( 1000, f, 0)

	--If you are player one generate the path and send it to the other player

	-- if network1.host then
	-- 	print("\n\n IS HOST \n\n")
	-- end

	-- if network1.host then

	-- 	path = {}
	-- 	height = 10
	-- 	width = 20
	-- 	pathSize = BuildPath(height,width,path)
	-- 	print(pathSize)
	-- 	local options = {
	-- 		params = {
	-- 			path, pathSize
	-- 		}
	-- 	}

	-- 	--
 --        -- local data = {}
 --        -- data[1] =  path
 --        -- data[2] =  height

 --        self:raiseEvent( Constants.SendPath, params, { receivers = LoadBalancingConstants.ReceiverGroup.Others } ) 

	--         options = {
	-- 	        params = {
	-- 		        pathSend = path,
	-- 		        pathSizeSend = pathSize,
	-- 		        networkSend = network1
	-- 	    	}
	-- 	    }


	-- 	print("\n\nGo to game scene - host\n\n")

	--     storyboard.gotoScene("gameScreen", options)
	-- end

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
	
	return count
	
end




function createClient()

	local client = LoadBalancingClient.new(appInfo.MasterAddress, appInfo.AppId, appInfo.AppVersion)

	local lastErrMess = ""
	client.win = false
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

        --client.mReceiveCount = client.mReceiveCount + 1
        
        --self.value = content[1]

        print("\nRECEVIED EVENT " .. code  )

        if code == Constants.SendPath then
	        

	    	--timer.cancel(CONNECTIONTIMER)

			if self.host == false then
				print("SENDING ACK TO HOST")
				-- for i=1,4 do
		    		self:raiseEvent( Constants.Ack, content, { receivers = LoadBalancingConstants.ReceiverGroup.Others } )
		    		-- socket.sleep(0.2)
		    							-- print(i)
				-- end

		    end

				    local options = {
				    					params = 
							        	{
									        pathSend = content.pathSend,
									        pathSizeSend = content.pathSizeSend,
									        networkSend = self
								    	}
				    				}

				    -- print("I am not hosting with pathsize of " .. options.params.pathSizeSend)
					storyboard.gotoScene("gameScreen", options)

	    end

	    if code == Constants.Ack and self.host == true then

	    	print("Host received ACK from client")
	    	timer.cancel(CONNECTIONTIMER)

			print("\n\nGo to game scene - host\n\n")

	         local options = {
		    					 params = 
					        	{
							        pathSend = content.pathSend,
							        pathSizeSend = content.pathSizeSend,
							        networkSend = self
						    	}
		    				 }

		    print("I am hosting and going to gamescene with pathsize of " .. options.params.pathSizeSend)

		    storyboard.gotoScene("gameScreen", options)
		end

		if code == Constants.SendTroops then
		
			print("Saving opponent's troops")

			self.troops = content.spawnList

		end
		if code == Constants.GameResult then
			self.win = content[1]
		end

	end

	function client:update()
	    -- self:sendData()
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

		local params = {
					        pathSend = 0,
					        pathSizeSend= 0
				    	}

	    local str = nil
	    if self.mRunning then
	        self:update()

	        if waiting.text ==  "Connecting to server..." then
	        	if not self:isJoinedToRoom() then
	        		--self:connect()
	        	else
	        		waiting.text =  "Waiting for an opponent..."
	        	end
	        end

	        if waiting.text ==  "Waiting for an opponent..." then
	        	print(table.getn(self:myRoomActors()))
	        	if table.getn(self:myRoomActors()) == 1 then
			    	self.host = true
			    elseif table.getn(self:myRoomActors()) > 1 then
					waiting.text = "Found opponent"
				end
			end

	        if waiting.text == "Found opponent" then

        		if self.host then

					print("RAISE EVENT")

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

					
					params = {
						        pathSend = path,
						        pathSizeSend= pathSize
				    		 }

				    print("I am host and I am sending client path of size " .. params.pathSizeSend)
				    --timer.cancel(CONNECTIONTIMER)
				    self:raiseEvent( Constants.SendPath, params, { receivers = LoadBalancingConstants.ReceiverGroup.Others } ) 

				    self:service()



				    socket.sleep(0.5)

				    local options = {
				    					params = 
							        	{
									        pathSend = path,
									        pathSizeSend = pathSize,
									        networkSend = self
								    	}
				    				}

				    -- print("I am not hosting with pathsize of " .. options.params.pathSizeSend)
					storyboard.gotoScene("gameScreen", options)

				end

	        end

	        if waiting.text == "Proceeding to Game" and self.host == false then
	        	print("\nGo to game scene\n")
		   
				timer.cancel(CONNECTIONTIMER)

					-- 				path = {}
					-- height = 10
					-- width = 20
					-- pathSize = BuildPath(height,width,path)

					-- while pathSize < (height * width)/4 do  --if it doesn't use at least 1/3 of the grid
					-- 	for index = 0, pathSize-1 do
					-- 		table.remove( path )
					-- 	end
					-- 	pathSize = BuildPath(height,width,path) --rebuild path
					-- end

			    local options = {
			    					params = 
						        	{
								        pathSend = path,
								        pathSizeSend = pathSize,
								        networkSend = self
							    	}
			    				}

			    print("I am not hosting with pathsize of " .. options.params.pathSizeSend)
				storyboard.gotoScene("gameScreen", options)
			end

	    else
	        timer.cancel(event.source)
	        self.mState = "Stopped"
	    end

	end

	return client

end



return scene