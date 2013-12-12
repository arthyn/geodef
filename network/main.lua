local LoadBalancingClient
local LoadBalancingConstants
local tableutil
local Logger
local photon

local storyboard = require "storyboard"
local widget = require "widget"

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


local scene = storyboard.newScene()

local stateText = display.newText("Room", 70, 0, canvasSize, 40, native.systemFont, 28)
local thingText = display.newText("Waiting for info", 70, 50, canvasSize, 40, native.systemFont, 28)
local countText = display.newText("Waiting for info", 70, 100, canvasSize, 40, native.systemFont, 28)

local client = LoadBalancingClient.new(appInfo.MasterAddress, appInfo.AppId, appInfo.AppVersion)

math.randomseed( os.time() )

client.mState = "Init"
client.value = 1
--client.sendvalue = 1
client.mSendCount = 0
client.mReceiveCount = 0
client.mRunning = true
client.id = math.random(100)

function scene:createScene( event )
    local group = self.view

    thingText.x = display.contentWidth * .5
    thingText.y = display.contentHeight * (1/8)

    group:insert(stateText)
    group:insert(thingText)

end

local lastErrMess = ""

function client:onOperationResponse(errorCode, errorMsg, code, content)
    self.logger:debug("onOperationResponse", errorCode, errorMsg, code, tableutil.toStringReq(content))
    if errorCode ~= 0 then
        if code == LoadBalancingConstants.OperationCode.JoinRandomGame then  -- master random room fail - try create
            self.logger:info("createRoom")
            self:createRoom("NetworkSwap")
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

function client:onStateChange(state)
    self.logger:debug("Demo: onStateChange " .. state .. ": " .. tostring(LoadBalancingClient.StateToName(state)))
    if state == LoadBalancingClient.State.JoinedLobby then
        self.logger:info("joinRandomRoom - 1")
        self:joinRandomRoom()
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

    stateText.text = LoadBalancingClient.StateToName(self.state)
    thingText.text = str
    countText.text = self.mSendCount

end



client:connect()

if display then
    client.logger:info("Start")
    timer.performWithDelay( 1000, client, 0)
else
    while true do
        client:timer()
        socket.sleep(1)
    end
end