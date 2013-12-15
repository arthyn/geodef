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

function scene:createScene( event )
	local group = self.view

	local bgMusic = audio.loadStream( "music.mp3" )
	backgroundMusicChannel = audio.play( bgMusic, {channel=1, loops=-1} )

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
	logo:scale(3,3) 


	logo:translate(0,0)
	logo.x = display.contentWidth * .5
	logo.y = display.contentHeight * (4/12)
	--local name = display.newText("geodef", 0, 0, native.systemFont, 200)
	--name.x = display.contentWidth * .5
	--name.y = display.contentHeight * .4

	local backButton = createButton("PLAY!", backButtonRelease)
	backButton.x = display.contentWidth * (.5)
	backButton.y = display.contentHeight * (.7)

	group:insert(background)
	group:insert(logo)
	group:insert(backButton)

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