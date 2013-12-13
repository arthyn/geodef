local storyboard = require "storyboard"
local scene = storyboard.newScene()
local widget = require "widget"

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
	storyboard.gotoScene("mainMenu")
end

local function onSegmentPress( event )
    local target = event.target
    if target.segmentNumber == 2 then
    	audio.stop(1)
    else
    	local bgMusic = audio.loadStream( "music.mp3" )
		audio.play(bgMusic, {channel=1, loops=-1} )

	end
end

function scene:createScene( event )
	local group = self.view

	local background = display.newImage( "wallpaper.png")
	background:translate(0,0)
	background:setFillColor(math.random(50, 255), math.random(50, 255), math.random(50, 255))

	local logo = display.newImage( "logo.png")
	logo:setFillColor(math.random(50, 255), math.random(50, 255), math.random(50, 255))
	logo:scale(1.5,1.5 ) 
	logo:translate(0,0)
	logo.x = display.contentWidth * .5
	logo.y = display.contentHeight * (4/14)

	local backButton = createButton("Back", backButtonRelease)
	backButton.x = display.contentWidth * (.5)
	backButton.y = display.contentHeight * (.75)

	local musicToggle = widget.newSegmentedControl{
		top = display.contentHeight/2,
		left = display.contentWidth/4,
		segmentWidth = display.contentWidth/4,
    	segments = { "MUSIC ON", "MUSIC OFF"},
   		defaultSegment = 1,
    	onPress = onSegmentPress,
    	labelSize = 50
	}

	group:insert(background)
	group:insert(backButton)
	group:insert(musicToggle)
	group:insert(logo)

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