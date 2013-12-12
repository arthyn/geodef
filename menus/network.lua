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

    function client:onActorLeave(actor)

        end

    return client
end

return createClient