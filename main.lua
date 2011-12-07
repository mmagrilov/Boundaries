----------------------------------------------
--	DynResManager test        	         	--
----------------------------------------------

display.setStatusBar( display.HiddenStatusBar ) 


local resolutionManager = require "DynResManager"   

-- 1) background: its dimensions ensure that "letterbox" margins are filled on known devices
local background = display.newRect(0, 0, 380, 570) 
background.x = display.contentWidth  * 0.5
background.y = display.contentHeight * 0.5
background:setFillColor( 240, 220, 210 )

-- 2) Application "viewable content size" rectangle
local appRect = display.newRect(0, 0, display.viewableContentWidth, display.viewableContentHeight) 
appRect.x = display.contentWidth  * 0.5
appRect.y = display.contentHeight * 0.5
appRect:setFillColor( 100, 160, 100 )

-- 3) Messages about application and screen sizes

-- 3a) Application content size as defined in config.lua
local appSizeText = display.newText("App size:\n"..display.contentWidth.."x"..display.contentHeight, 0, 0, native.systemFont, 16)
appSizeText:setTextColor(0, 60, 0)
appSizeText.x = display.contentWidth*0.5
appSizeText.y = 30

-- 3b) Application viewable content size 
local appSizeText = display.newText("App viewable area:\n        "..display.viewableContentWidth.."x"..display.viewableContentHeight, 0, 0, native.systemFont, 16)
appSizeText:setTextColor(0, 60, 0)
appSizeText.x = display.contentWidth*0.5
appSizeText.y = 90

-- 3c) Device screen size in application scale (in pixels of the application).
--     default scaling mode is "letterbox";
--     for "zoomeven" scaling mode you have to write screenWidthAppPix("zoomeven") and screenHeightAppPix("zoomeven")
local screenAppSizeText = display.newText("Screen size in application scale:\n                  "..
						  resolutionManager.screenWidthAppPix().."x"..resolutionManager.screenHeightAppPix(), 0, 0, native.systemFont, 16)
screenAppSizeText:setTextColor(0, 0, 60)
screenAppSizeText.x = display.contentWidth*0.5
screenAppSizeText.y = 150

-- 3d) Actual screen size (in physical pixels of the device).
--     default scaling mode is "letterbox";
--     for "zoomeven" scaling mode you have to write screenWidthPhysPix("zoomeven") and screenHeightPhysPix("zoomeven")
local screenPhysSizeText = display.newText("Screen physical size:\n         "..
						  resolutionManager.screenWidthPhysPix().."x"..resolutionManager.screenHeightPhysPix(), 0, 0, native.systemFont, 16)
screenPhysSizeText:setTextColor(0, 0, 60)
screenPhysSizeText.x = display.contentWidth*0.5
screenPhysSizeText.y = 210

-- 4) You can use letterbox margins, i.e. areas that are outside the size defined in config.lua

if resolutionManager.minVisibleY() < 0 then -- minVisibleY is the same as display.screenOriginY
	local topNote = display.newText("top letterbox margin", 0, 0, native.systemFont, 14)
	topNote:setTextColor(0, 0, 0)
	topNote.x = display.contentWidth * 0.5
	topNote.y = resolutionManager.minVisibleY() + 8 
	
end

if resolutionManager.maxVisibleY() > display.viewableContentHeight then 
	local bottomNote = display.newText("bottom letterbox margin", 0, 0, native.systemFont, 14)
	bottomNote:setTextColor(0, 0, 0)
	bottomNote.x = display.contentWidth * 0.5
	bottomNote.y = resolutionManager.maxVisibleY() - 8 
end

-- Left and right margins: you can see them even on "tall screen" devices - 
-- just specify small width (say, width = 220) in config.lua
if resolutionManager.minVisibleX() < 0 then 
	local leftNote = display.newText("left letterbox margin", 0, 0, native.systemFont, 14)
	leftNote:setTextColor(0, 0, 0)
	leftNote.x = resolutionManager.minVisibleX() + 8 
	leftNote.y = display.contentHeight * 0.5
	leftNote:rotate (-90)
end

if resolutionManager.maxVisibleX() > display.viewableContentWidth then 
	local rightNote = display.newText("right letterbox margin", 0, 0, native.systemFont, 14)
	rightNote:setTextColor(0, 0, 0)
	rightNote.x = resolutionManager.maxVisibleX() - 8 
	rightNote.y = display.contentHeight * 0.5
	rightNote:rotate( 90)
end

 
 -- 5) What image resolution is loaded (by default)?
local loadHiRes = resolutionManager.haveToLoadHiRes()
local resNote
if loadHiRes then 
	resNote = display.newText("High res images\n    are loaded", 0, 0, native.systemFont, 20)
else
	resNote = display.newText("Low res images\n    are loaded", 0, 0, native.systemFont, 20)
end
resNote:setTextColor(222, 255, 222)
resNote.x = display.contentWidth*0.5
resNote.y = 410
 

-- 6) Controls: first place them in the corners of application contents area defined in config.lua

local controlPositionText = nil
local controlPosition = "app"

control1 = resolutionManager.loadImage("Button1.png") 
control2 = resolutionManager.loadImage("Button2.png") 
control3 = resolutionManager.loadImage("Button3.png") 
control4 = resolutionManager.loadImage("Button4.png") 


local function placeControlsInAppCorners() -- for "letterbox scaling mode

	control1.x = 0 + control1.width  * control1.xScale * 0.5 -- have to use xScale for hi-res images
	control1.y = 0 + control1.height * control1.yScale * 0.5
	
	control2.x = display.viewableContentWidth - control2.width * control2.xScale  * 0.5
	control2.y = 0 + control2.height * control2.yScale * 0.5
	
	control3.x = 0 + control3.width * control3.xScale  * 0.5
	control3.y = display.contentHeight - control3.height * control3.yScale * 0.5
	
	control4.x = display.contentWidth  - control4.width  * control4.xScale * 0.5
	control4.y = display.contentHeight - control4.height * control4.yScale * 0.5
	
	if controlPositionText ~= nil then
		display.remove(controlPositionText)
		controlPositionText = nil
	end
	controlPositionText = display.newText("  Now controls are\n    in the corners\nof app contents area", 0, 0, native.systemFont, 30)
	controlPositionText:setTextColor(0, 0, 0)
	controlPositionText.x = display.contentWidth*0.5
	controlPositionText.y = 310
	
	controlPosition = "app"

end

local function placeControlsInScreenCorners()

	--     default scaling mode is "letterbox";
	--     for "zoomeven" scaling mode you have to write minVisibleX("zoomeven") and minVisibleY("zoomeven")

	control1.x = resolutionManager.minVisibleX() + control1.width  * control1.xScale * 0.5
	control1.y = resolutionManager.minVisibleY() + control1.height * control1.yScale * 0.5
	
	control2.x = resolutionManager.maxVisibleX() - control2.width  * control2.xScale * 0.5
	control2.y = resolutionManager.minVisibleY() + control2.height * control2.yScale * 0.5
	
	control3.x = resolutionManager.minVisibleX() + control3.width  * control3.xScale * 0.5
	control3.y = resolutionManager.maxVisibleY() - control3.height * control3.yScale * 0.5
	
	control4.x = resolutionManager.maxVisibleX() - control4.width  * control4.xScale * 0.5
	control4.y = resolutionManager.maxVisibleY() - control4.height * control4.yScale * 0.5
	
	if controlPositionText ~= nil then
		display.remove(controlPositionText)
		controlPositionText = nil
	end
	controlPositionText = display.newText("  Now controls are\n    in the corners\nof physical screen", 0, 0, native.systemFont, 30)
	controlPositionText:setTextColor(255, 255, 255)
	controlPositionText.x = display.contentWidth*0.5
	controlPositionText.y = 310
	
	controlPosition = "screen"

end

placeControlsInAppCorners()


-- 6) Touching controls will toggle their position (app/screen)

local function togglePosition (event)
	if event.phase ~= "ended" then
		return true
	end
	
	if controlPosition == "app" then
		placeControlsInScreenCorners()
	else
		placeControlsInAppCorners()
	end
	return true
end

control1:addEventListener("touch", togglePosition)
control2:addEventListener("touch", togglePosition)
control3:addEventListener("touch", togglePosition)
control4:addEventListener("touch", togglePosition)



-- This is placeControlsInAppCorners function for "zoomeven" mode;
-- 
--[[
local function placeControlsInAppCorners()

	control1.x = display.screenOriginX + control1.width  * control1.xScale * 0.5 
	control1.y = display.screenOriginY + control1.height * control1.yScale * 0.5
	
	control2.x = display.screenOriginX + display.viewableContentWidth - control2.width * control2.xScale  * 0.5
	control2.y = display.screenOriginY + control2.height * control2.yScale * 0.5
	
	control3.x = display.screenOriginX + control3.width * control3.xScale  * 0.5
	control3.y = display.screenOriginY + display.viewableContentHeight - control3.height * control3.yScale * 0.5
	
	control4.x = display.screenOriginX + display.viewableContentWidth - control4.width  * control4.xScale * 0.5
	control4.y = display.screenOriginY + display.viewableContentHeight - control4.height * control4.yScale * 0.5
	
	if controlPositionText ~= nil then
		display.remove(controlPositionText)
		controlPositionText = nil
	end
	controlPositionText = display.newText("  Now controls are\n    in the corners\nof app contents area", 0, 0, native.systemFont, 30)
	controlPositionText:setTextColor(0, 0, 0)
	controlPositionText.x = display.contentWidth*0.5
	controlPositionText.y = 310
	
	controlPosition = "app"

end
--]]































