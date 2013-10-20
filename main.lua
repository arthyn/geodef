local photon = require "plugin.photon"
local masterAddress = "app-eu.exitgameslcoud.com:5055" -- using Photon Cloud EU region as default
local appId = "aosnoasng" -- each application on the Photon Cloud gets an appId
local appVersion = "1.0" -- clients with different versions will be separated (easy to update clients)
local client = photon.loadbalancing.LoadBalancingClient.new(masterAddress, appId, appVersion)
client:connect()
