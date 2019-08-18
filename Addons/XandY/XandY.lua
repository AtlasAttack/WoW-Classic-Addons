--[[
                    ----o----(||)----o----(||)----o----(||)----o----(||)----o----(||)----o----(||)----o----(||)----o----


                                      #        #         ####    #       #  ######         #         #
                                       #      #         ##  ##   ##      #  #     ##        #       #
                                        #    #         #      #  # #     #  #      ##        #     #
                                         #  #          #      #  #  #    #  #       #         #   #
                                          ##           ########  #   #   #  #       #          # #
                                         #  #          #      #  #    #  #  #       #           #
                                        #    #         #      #  #     # #  #      ##           #
                                       #      #        #      #  #      ##  #     ##            #
                                      #        #       #      #  #       #  ######              #


                                                       --==  BATTLE FOR AZEROTH  ==--
                                                            --==  CLASSIC  ==--


                    ----o----(||)----o----(||)----o----(||)----o----(||)----o----(||)----o----(||)----o----(||)----o----


                                                    ----o----(||)----oo----(||)----o----

                                                          v2.12 - 10th August 2019
                                                    Copyright (C) Taraezor / Chris Birch

                                                    ----o----(||)----oo----(||)----o----

]]

--------------------------------------------------------------------------------------------------------------------------------------------
--
--		Localisations and Local Data
--		============================
--
--------------------------------------------------------------------------------------------------------------------------------------------

local addonName, L = ...
local addonTitle = addonName

local date = date
local floor = math.floor
local find = string.find
local format = string.format
local len = string.len
local pi = math.pi
local sub = string.sub

local GetMinimapZoneText = GetMinimapZoneText
local GetPlayerFacing = GetPlayerFacing
local GetPlayerMapPosition = C_Map.GetPlayerMapPosition

local xPlayer, yPlayer, xCursor, yCursor;

--------------------------------------------------------------------------------------------------------------------------------------------
--
--		Local Functions
--		===============
--
--------------------------------------------------------------------------------------------------------------------------------------------

local function round( num, places )		-- round to nearest integer, ties round away from zero. LUA 5.0 does NOT have modf
	local mult = 10 ^ ( places or 0 )
	return floor( num * mult + ( ( num < 0 and -1 ) or 1 ) * 0.5 ) / mult
end

--------------------------------------------------------------------------------------------------------------------------------------------
--
--		Build / Version Setup
--		=====================
--
--------------------------------------------------------------------------------------------------------------------------------------------

local buildVersion = GetBuildInfo()
local _, _, buildVersion = find( buildVersion, "(%d+\.%d+)" )
buildVersion = tonumber( buildVersion )

--------------------------------------------------------------------------------------------------------------------------------------------
--
--		Colour Printing - Brown Theme + Map Colours
--		===============
--
--------------------------------------------------------------------------------------------------------------------------------------------

local pc_colour_Prefix		= "\124cFFD2691E"	-- X11Chocolate
local pc_colour_Highlight	= "\124cFFF4A460"	-- X11SandyBrown
local pc_colour_PlainText	= "\124cFFDEB887"	-- X11BurlyWood
local pc_colour_Malachite	= "\124cFF0BDA51"
local pc_colour_Gold		= "\124cFFFED12A"

local function printPC( message )
	if message then
		DEFAULT_CHAT_FRAME:AddMessage( pc_colour_Prefix.. addonTitle.. ": ".. pc_colour_PlainText.. message.. "\124r" )
	end
end

--------------------------------------------------------------------------------------------------------------------------------------------
--
--		Language Localisation
--		=====================
--
--------------------------------------------------------------------------------------------------------------------------------------------

local locale = GetLocale()

local L = {}
setmetatable( L, { __index = function( L, key) return key end } )

if locale == "deDE" then
	L["Player"] = "Spieler"
	L["Cursor"] = "Mauszeiger"
elseif locale == "esES" or locale == "esMX" then
	L["Player"] = "Jugador"
	L["Cursor"] = "Cursor"
elseif locale == "frFR" then
	L["Player"] = "Joueur"
	L["Cursor"] = "Le curseur"
elseif locale == "itIT" then
	L["Player"] = "Giocatore"
	L["Cursor"] = "Cursore"
elseif locale == "koKR" then
	L["Player"] = "플레이어"
	L["Cursor"] = "커서"
elseif locale == "ptBR" then
	L["Player"] = "Jogador"
	L["Cursor"] = "Cursor"
elseif locale == "ruRU" then
	L["Player"] = "игрок"
	L["Cursor"] = "Курсор"
elseif locale == "zhCN" then
	L["Player"] = "玩家"
	L["Cursor"] = "鼠标"
elseif locale == "zhTW" then
	L["Player"] = "玩家"
	L["Cursor"] = "滑鼠游標"
else
	local dm = date( "%d%m" )
	if sub( dm, 1, 2 ) == "19" and sub( dm, 3, 4 ) == "09" then
		L["Player"] = "Cap'n"
		L["Cursor"] = "Bilge Rats"
	end
end

--------------------------------------------------------------------------------------------------------------------------------------------
--
--		MiniMapTooltip
--		==============
--
--------------------------------------------------------------------------------------------------------------------------------------------

local function MiniMapTooltip()

	-- I suspect this code works across pretty much every incarnation of WoW over the years

	if ( GameTooltip:IsOwned( MinimapZoneTextButton ) ) then
		if ( xPlayer > 0 ) and ( yPlayer > 0 ) then
			local playerBrace = L["Player"].. " ("
			local length, found = len( playerBrace ), 0
			for i = GameTooltip:NumLines(), 2, -1 do
				local line = _G[ "GameTooltipTextLeft".. i ]:GetText()
				if line ~= nil then
					if sub( line, 1, length ) == playerBrace then
						found = i
						break
					end
				end
			end
			local degrees = round( ( ( GetPlayerFacing() or -1 ) * 180 / pi ), 0 )			
			if found > 0 then
				if ( degrees >= 0 ) then
					_G[ "GameTooltipTextLeft".. found ]:SetText( playerBrace.. format( "%.2f", round( xPlayer, 2 ) ).. 
							":".. format( "%.2f", round( yPlayer, 2 ) ).. ") @ ".. degrees.. "°" )
				else
					_G[ "GameTooltipTextLeft".. found ]:SetText( playerBrace.. format( "%.2f", round( xPlayer, 2 ) ).. 
							":".. format( "%.2f", round( yPlayer, 2 ) ).. ")" )
				end
			else
				if ( degrees >= 0 ) then
					GameTooltip:AddLine( playerBrace.. format( "%.2f", round( xPlayer, 2 ) ).. ":".. 
								format( "%.2f", round( yPlayer, 2 ) ).. ") @ ".. degrees.. "°" )
				else
					GameTooltip:AddLine( playerBrace.. format( "%.2f", round( xPlayer, 2 ) ).. ":".. 
								format( "%.2f", round( yPlayer, 2 ) ).. ")" )
				end
				GameTooltip:Show()
			end
		end
	end
end

--------------------------------------------------------------------------------------------------------------------------------------------
--
--		Event Handler
--		=============
--
--------------------------------------------------------------------------------------------------------------------------------------------

local old_MinimapZoneTextButtonOnClick;		-- Filled on VARIABLES_LOADED event. Not sure if other AddOns would have set this

local function MinimapZoneTextButtonOnClick()

	if old_MinimapZoneTextButtonOnClick then old_MinimapZoneTextButtonOnClick() end
	XandYDB.miniDetail = ( XandYDB.miniDetail < 4 ) and ( XandYDB.miniDetail + 1 ) or 1
end

local function OnEventHandler( self, event, args )

	if ( event == "VARIABLES_LOADED" ) then
		if not XandYDB then XandYDB = {} end
		local miniDetail = XandYDB.miniDetail or 1
		XandYDB = {}
		XandYDB.miniDetail = miniDetail

		if locale == "deDE" then
			addonTitle = GetAddOnMetadata( "XandY", "Title-deDE" )
		elseif locale == "esES" or locale == "esMX" then
			addonTitle = GetAddOnMetadata( "XandY", "Title-esES" )
		elseif locale == "frFR" then
			addonTitle = GetAddOnMetadata( "XandY", "Title-frFR" )
		elseif locale == "itIT" then
			addonTitle = GetAddOnMetadata( "XandY", "Title-itIT" )
		elseif locale == "koKR" then
			addonTitle = GetAddOnMetadata( "XandY", "Title-koKR" )
		elseif locale == "ptBR" then
			addonTitle = GetAddOnMetadata( "XandY", "Title-ptBR" )
		elseif locale == "ruRU" then
			addonTitle = GetAddOnMetadata( "XandY", "Title-ruRU" )
		elseif locale == "zhCN" then
			addonTitle = GetAddOnMetadata( "XandY", "Title-zhCN" )
		elseif locale == "zhTW" then
			addonTitle = GetAddOnMetadata( "XandY", "Title-zhTW" )
		else
			addonTitle = GetAddOnMetadata( "XandY", "Title" )
		end

		old_MinimapZoneTextButtonOnClick = MinimapZoneTextButton:GetScript( "OnClick" )
		MinimapZoneTextButton:SetScript( "OnClick", MinimapZoneTextButtonOnClick )
		GameTooltip:HookScript( "OnUpdate", MiniMapTooltip )
	end
end

local eventFrame = CreateFrame( "Frame" )
eventFrame:RegisterEvent( "VARIABLES_LOADED" )
eventFrame:SetScript( "OnEvent", OnEventHandler )

--------------------------------------------------------------------------------------------------------------------------------------------
--
--		OnUpdate Handler
--		================
--
--------------------------------------------------------------------------------------------------------------------------------------------

local timeSinceLastUpdate = 0

local function OnUpdate()

	-- From a certain patch/update the timeElapsed was passed as a value. But this block should work across all versions of WoW.
	-- Actually timeElapsed ignores the time elapsed while looking at a loading screen or a cinematic. GetTime is better

	local curTime = GetTime()
	if curTime - timeSinceLastUpdate <= 0.2 then return end
	timeSinceLastUpdate = curTime
	
	if IsInInstance() == true then
		xPlayer, yPlayer = 0, 0
	else
		-- KNOWN BUG: Repro: login/reload. Do not show World Map. Enter instance. Show instance (World) map, exit.
		-- Result: No coords appear in Minimap title text. All options tested and no fix. Appears to be a problem at Blizzard's end
		local viewedMap = WorldMapFrame:GetMapID() or 0
		local playerMapPos = GetPlayerMapPosition( viewedMap, "player" )
		if playerMapPos then	-- Not all maps have coordinates. Eg, Ironforge side of the Deeprun Tram
			xPlayer, yPlayer = playerMapPos:GetXY()
		else
			xPlayer, yPlayer = 0, 0
		end
	end
	
	xPlayer, yPlayer = ( xPlayer or 0 ) * 100, ( yPlayer or 0 ) * 100

	if ( MinimapZoneTextButton:IsVisible() == true ) then
		local minimapZoneText = GetMinimapZoneText()
		if ( ( xPlayer == 0 ) and ( yPlayer == 0 ) ) then
			MinimapZoneText:SetText( minimapZoneText )
		else
			local colourText = ""
			local degrees = round( ( ( GetPlayerFacing() or -1 ) * 180 / pi ), 0 )			
			if ( degrees == 0 ) or ( degrees == 90 ) or ( degrees == 180 ) or ( degrees == 270 ) or ( degrees == 360 ) then
				colourText = pc_colour_Prefix
			elseif ( degrees == 45 ) or ( degrees == 135 ) or ( degrees == 225 ) or ( degrees == 315 ) then
				colourText = pc_colour_Highlight
			end
			if ( XandYDB.miniDetail == 1 ) then
				MinimapZoneText:SetText( colourText.. "(".. format( "%.1f", round( xPlayer, 1 ) ).. ":".. 
							format( "%.1f", round( yPlayer, 1 ) ).. ") ".. minimapZoneText )
			elseif ( XandYDB.miniDetail == 2 ) then
				MinimapZoneText:SetText( colourText.. "(".. format( "%.2f", round( xPlayer, 2 ) ).. ":".. 
							format( "%.2f", round( yPlayer, 2 ) ).. ") ".. minimapZoneText )
			elseif ( XandYDB.miniDetail == 3 ) then
				MinimapZoneText:SetText( colourText.. "(".. format( "%.3f", round( xPlayer, 3 ) ).. ":".. 
							format( "%.3f", round( yPlayer, 3 ) ).. ") ".. minimapZoneText )
			else
				MinimapZoneText:SetText( minimapZoneText )
			end
		end
	end

	if ( WorldMapFrame:IsVisible() == true ) then
		xPlayer = round( xPlayer, 2 )
		yPlayer = round( yPlayer, 2 )
		
		xCursor, yCursor = WorldMapFrame:GetNormalizedCursorPosition()	
		xCursor, yCursor = round( xCursor * 100, 2 ), round( yCursor * 100, 2 )
		
		local spaces, currentTitle = "          ", ""
		
		if buildVersion ~= 1.13 then
			currentTitle = WorldMapFrame.BorderFrame.TitleText:GetText()
			currentTitle = gsub( currentTitle, L[ "Player" ].. " @ ".. pc_colour_Malachite.. "%d*%.*%d*\124r:".. pc_colour_Malachite.. "%d*%.*%d*\124r", "" )
			currentTitle = gsub( currentTitle, L[ "Cursor" ].. " @ ".. pc_colour_Malachite.. "%d*%.*%d*\124r:".. pc_colour_Malachite.. "%d*%.*%d*\124r", "" )
			currentTitle = strtrim( currentTitle  )
		end

		if ( xPlayer ~= 0 ) or ( yPlayer ~= 0 ) then
			currentTitle = currentTitle.. "          ".. L[ "Player" ].. " @ ".. pc_colour_Malachite.. format( "%.2f", xPlayer ).. "\124r:".. pc_colour_Malachite.. format( "%.2f", yPlayer ).. "\124r"
			spaces = " "
		end
		if ( xCursor > 0 ) and ( xCursor < 100 ) and ( yCursor > 0 ) and ( yCursor < 100 ) then
			currentTitle = currentTitle.. spaces.. L[ "Cursor" ].. " @ ".. pc_colour_Malachite.. xCursor.. "\124r:".. pc_colour_Malachite.. 
								yCursor.. "\124r"
		end
		
		if buildVersion == 1.13 then
			XandYCoords:SetText( currentTitle )
			XandYCoords:SetPoint( "CENTER", WorldMapFrame, "CENTER", 0, -368)
		else
			WorldMapFrame.BorderFrame.TitleText:SetText( currentTitle )
		end
	end
end

eventFrame:SetScript( "OnUpdate", OnUpdate )