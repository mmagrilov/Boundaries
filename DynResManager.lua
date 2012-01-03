local public = {} 	-- This form of module uses only locals, 
					-- as described in http://blog.anscamobile.com/2011/09/a-better-approach-to-external-modules/

-- ================================================================================================
-- DynResManager - a tool for handling dynamic resolution images. 
-- -------------   the images are loaded by means of DynResManager:loadImage local function.
--  
-- written by Michael Magrilov, mmagrilov@gmail.com
-- 08.09.2011
--         
-- ================================================================================================
-- Version 2.0
-- Changes: 
-- 1) New functions for getting screen boundaries and screen size
-- 2) "base" forceLoadRes value added as a synonim to "low"

-- ================================================================================================


---------------------------------------
-- Constants for scalng              --
---------------------------------------

local constHiResPicScale 	= 2.0	-- in this case Hi-res images must be twice as big as lo-res ones

local constHiResSuffix     	= "@2x"	-- Low: "pic.png"; High: "pic@2x.png"
									-- a note: in this version there can be only 1 dot in image name (names like abc.def.jpg are not allowed)

local constHiResThreshold  	= 1.49   -- Hi-res pic will be loaded if the app is "magnified" by this or greater value;
						-- if width in config.lua is 320 and threshhold is 1.8, then hi-res is loaded starting from device width = 320 * 1.8 = 576 
						-- if width in config.lua is 320 and threshhold is 1.5, then hi-res is loaded starting from device width = 320 * 1.5 = 480
						-- (I assume that scale in config.lua = "letterbox" or "zoomeven" and device proportions are "taller"
						-- than those of the application);
						-- because of scale rounding error it's better to take 1.79 instead of 1.8 and 1.49 instead of 1.5
						
						-- If you need more than two resolution levels, 
						-- it's possible to turn constHiResPicScale, constHiResSuffix and constHiResThreshold into tables
						-- (of course, this requires also changes in local functions)


									
---------------------------------------------------------------
local function haveToLoadHiRes() -- Here we decide if we have to load hi-res or lo-res images
---------------------------------------------------------------

	local deviceScaleX = 1.0 / display.contentScaleX -- App width  on the device screen (pix) / app  width  set in config.lua 
	local deviceScaleY = 1.0 / display.contentScaleY -- App height on the device screen (pix) / app  height set in config.lua 

	if deviceScaleX >= constHiResThreshold or deviceScaleY >= constHiResThreshold then
		return true
	else
		return false
	end
	
end -- haveToLoadHiRes
public.haveToLoadHiRes = haveToLoadHiRes

---------------------------------------------------------------
local function loadImage(imageFileName, forceLoadRes)	-- The main method; optional parm forceLoadRes = "high" / "low" ("base") or empty
---------------------------------------------------------------
local imageFileName  = tostring(imageFileName) or false
if imageFileName == "" then return nil end

local forceLoadRes = string.lower(tostring(forceLoadRes)) or false
if forceLoadRes ~= "high" and forceLoadRes ~= "low" and forceLoadRes ~= "base" then forceLoadRes = "" end
if forceLoadRes == "base" then forceLoadRes = "low" end

	local hiResImageFileName
	local tempImage = nil
	
	-- 1) Load a low-res (base) image if we don't have to load hi-res
	if (not haveToLoadHiRes() and forceLoadRes ~= "high") or forceLoadRes == "low" then
		tempImage   = display.newImage (imageFileName)
		tempImage.x = 0
		tempImage.y = 0
		return tempImage
	end

	-- 3) Loading a HiRes image - first build its name, then load, if not OK, load base image
	hiResImageFileName = string.gsub(imageFileName, "%.", constHiResSuffix..".") -- abc.jpg --> abc@2x.jpg
	tempImage = display.newImage (hiResImageFileName)
	
	-- 4) If we failed to load a hi-res image, load a lo-res;
	if tempImage == nil then
		tempImage   = display.newImage (imageFileName)
		tempImage.x = 0
		tempImage.y = 0
		return tempImage
	end
	
	-- 4) Scaling; if a hi-res image was loaded, its xScale and yScale will not be equal to 1;
	--             take it into account if you want to scale the image again!
	tempImage.xScale = tempImage.xScale / constHiResPicScale
	tempImage.yScale = tempImage.yScale / constHiResPicScale
	
	tempImage.x = 0
	tempImage.y = 0
	
	return tempImage

end -- loadImage
public.loadImage = loadImage


---------------------------------------------------------------------------------
-- "Get" public to access constants used by DynResManager
---------------------------------------------------------------------------------

-----------------------------------------
local function getHiResPicScale()
-----------------------------------------
	return constHiResPicScale
end
public.getHiResPicScale = getHiResPicScale
---------------------------------------
local function getHiResSuffix()
---------------------------------------
	return constHiResSuffix
end
public.getHiResSuffix = getHiResSuffix
------------------------------------------
local function getHiResThreshold()
------------------------------------------
	return constHiResThreshold
end
public.getHiResThreshold = getHiResThreshold




---------------------------------------------------------------------------------
-- Some useful public functions ( screen X/Y range and screen size)
---------------------------------------------------------------------------------

------------------------------------------------------
local function minVisibleY() 
------------------------------------------------------
	return display.screenOriginY 
end
public.minVisibleY = minVisibleY

------------------------------------------------------
local function maxVisibleY(scaleMode, yAlign) -- default: "letterbox", "center" 
------------------------------------------------------
-- in "letterbox" or "zoomeven" scaling modes works only with yAlign = "bottom" or "center" (default); 
-- doesn't work for yAlign = "top" (we can't get the height of the bottom margin)
-- this is true also for screenHeight... functions

local scaleMode = string.lower(tostring(scaleMode)) or ""
if scaleMode ~= "none" and scaleMode ~= "zoomeven" and scaleMode ~= "zoomstretch" then scaleMode = "letterbox" end

local yAlign = string.lower(tostring(yAlign)) or ""
if yAlign ~= "bottom" then yAlign = "center" end

	if scaleMode == "zoomstretch" then
		return display.viewableContentHeight
	end
	
	if scaleMode == "zoomeven" then
		return display.viewableContentHeight + display.screenOriginY
	end

	if scaleMode == "none" or scaleMode == "letterbox" then
		if yAlign == "center" then
			return display.viewableContentHeight - display.screenOriginY
		else
			return display.viewableContentHeight
		end
	end

end
public.maxVisibleY = maxVisibleY

------------------------------------------------------
local function minVisibleX() 
------------------------------------------------------
	return display.screenOriginX
end
public.minVisibleX = minVisibleX

------------------------------------------------------
local function maxVisibleX(scaleMode, xAlign) -- default: "letterbox", "center"
------------------------------------------------------
-- in "letterbox" or "zoomeven" scaling modes works only with xAlign = "right" or "center" (default); 
-- doesn't work for xAlign = "left" (we can't get the width of the right margin)
-- this is true also for screenWidth... functions

local scaleMode = string.lower(tostring(scaleMode)) or ""
if scaleMode ~= "none" and scaleMode ~= "zoomeven" and scaleMode ~= "zoomstretch" then scaleMode = "letterbox" end

local xAlign = string.lower(tostring(xAlign)) or ""
if xAlign ~= "right" then xAlign = "center" end

	if scaleMode == "zoomstretch" then
		return display.viewableContentWidth
	end
	
	if scaleMode == "zoomeven" then
		return display.viewableContentWidth + display.screenOriginX
	end

	if scaleMode == "none" or scaleMode == "letterbox" then
		if xAlign == "center" then
			return display.viewableContentWidth - display.screenOriginX
		else
			return display.viewableContentWidth
		end
	end

end
public.maxVisibleX = maxVisibleX


------------------------------------------------------
local function screenHeightAppPix(scaleMode, yAlign) -- default: "letterbox", "center" 
------------------------------------------------------
	local scaleMode = string.lower(tostring(scaleMode)) or ""
	if scaleMode ~= "none" and scaleMode ~= "zoomeven" and scaleMode ~= "zoomstretch" then scaleMode = "letterbox" end
	return ( maxVisibleY(scaleMode, yAlign) - minVisibleY(scaleMode) )  -- not "+ 1" because "min" corresponds to 0
end
public.screenHeightAppPix = screenHeightAppPix

------------------------------------------------------
local function screenHeightPhysPix(scaleMode, yAlign) -- default: "letterbox", "center" 
------------------------------------------------------
-- screen height in "physical pixels"
-- I use "0.51" for rounding instead of 0.5 because screenOriginX & screenOriginY are rounded to a half pixel accuracy;
-- still, the function can give one pixel error for "zoomeven" scaling mode 
	return math.floor(screenHeightAppPix(scaleMode, yAlign) / display.contentScaleY + 0.51)
end
public.screenHeightPhysPix = screenHeightPhysPix



------------------------------------------------------
local function screenWidthAppPix(scaleMode, xAlign) -- default: "letterbox", "center" 
------------------------------------------------------
	local scaleMode = string.lower(tostring(scaleMode)) or ""
	if scaleMode ~= "none" and scaleMode ~= "zoomeven" and scaleMode ~= "zoomstretch" then scaleMode = "letterbox" end
	return ( maxVisibleX(scaleMode, xAlign) - minVisibleX(scaleMode) )  -- not "+ 1" because "min" corresponds to 0
end
public.screenWidthAppPix = screenWidthAppPix

------------------------------------------------------
local function screenWidthPhysPix(scaleMode, xAlign) -- default: "letterbox", "center" 
------------------------------------------------------
-- screen width in "physical pixels"
-- I use "0.51" for rounding instead of 0.5 because screenOriginX & screenOriginY are rounded to a half pixel accuracy; 
-- still, the function can give one pixel error for "zoomeven" scaling mode
	return math.floor(screenWidthAppPix(scaleMode, xAlign) / display.contentScaleX + 0.51)
end
public.screenWidthPhysPix = screenWidthPhysPix


-------


---------------------------------------------------------------
-- A function for rendering text with a font size set dynamically according to device resolution.
---------------------------------------------------------------
local function displayText(text, x, y, font, size, refPoint ) 
---------------------------------------------------------------
local text = text or "xxx"
local x = x  or 0
local y = y  or 0
local font = font  or native.systemFont
local size = size  or 12
local refPoint = refPoint or ""

local sizeAtRealResolution
local tempText
local W0, H0

	sizeAtRealResolution = size / display.contentScaleY
	tempText = display.newText(text, 0, 0, font, sizeAtRealResolution )
	
	refPoint = string.lower(refPoint)
	if refPoint 	== "center" 		then
		tempText:setReferencePoint( display.CenterReferencePoint )
	elseif refPoint == "topleft" 		then
		tempText:setReferencePoint( display.TopLeftReferencePoint )
	elseif refPoint == "topcenter" 		then
		tempText:setReferencePoint( display.TopCenterReferencePoint )
	elseif refPoint == "topright" 		then
		tempText:setReferencePoint( display.TopRightReferencePoint )
	elseif refPoint == "centerright" 	then
		tempText:setReferencePoint( display.CenterRightReferencePoint )
	elseif refPoint == "bottomright" 	then
		tempText:setReferencePoint( display.BottomRightReferencePoint )
	elseif refPoint == "bottomcenter" 	then
		tempText:setReferencePoint( display.BottomCenterReferencePoint )
	elseif refPoint == "bottomleft" 	then
		tempText:setReferencePoint( display.BottomLeftReferencePoint )
	elseif refPoint == "centerleft" 	then
		tempText:setReferencePoint( display.CenterLeftReferencePoint )
	else
		tempText:setReferencePoint( display.TopLeftReferencePoint ) -- default
	end
	
	tempText.yScale = tempText.yScale * display.contentScaleY
	tempText.xScale = tempText.xScale * display.contentScaleX

	tempText.x = x
	tempText.y = y
		
	return tempText 

end -- displayText
public.displayText = displayText

return public


