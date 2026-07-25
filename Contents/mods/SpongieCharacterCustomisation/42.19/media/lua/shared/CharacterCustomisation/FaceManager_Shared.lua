
	-- ----------------------------------------------------------------------
	-- -- METHODS THAT NEED TO BE USED BY THE SERVER AND THE CLIENT
	-- ----------------------------------------------------------------------

local FaceManager_Shared = {}

	-- -----------------------------------------
	-- -- UTILITY
	-- -----------------------------------------

function FaceManager_Shared.OnClothingUpdated(player)
	triggerEvent("OnClothingUpdated", player)
	player:resetModel()
end

function FaceManager_Shared.CreateItem(type, texture)

	-- local item = InventoryItemFactory.CreateItem(type) --b41
	local item = instanceItem(type) --b42

	FaceManager_Shared.SetItemTexture(item, texture)
	return item
end

function FaceManager_Shared.SetItemTexture(item, texture)
	if item == nil then return end
	if item:getVisual() == nil then return end
	item:getVisual():setBaseTexture(texture)
	item:getVisual():setTextureChoice(texture)
end

function FaceManager_Shared.GetMuscleLevel(level)
	if level == nil then return 0 end
	if level <= 5 then return 	0 end
	if level <= 8 then return 	1 end
	if level <= 10 then return 	2 end
	return 0
end


function FaceManager_Shared.OpenCharacterCustomisationWindow(player, hideCancelButton)
	local data = player:getModData().SPNCharCustom
	if not data then return nil end

	local CharCustomWindow = CharacterCustomisationPanel_Ingame:new()
	CharCustomWindow.hideCancelButton = hideCancelButton
	CharCustomWindow:initialise()
	CharCustomWindow:addToUIManager()

	CharCustomWindow:setX( (getCore():getScreenWidth()/2) - (CharCustomWindow:getWidth()/2) )
	CharCustomWindow:setY( (getCore():getScreenHeight()/2) - (CharCustomWindow:getHeight()/2) )
	
	CharCustomWindow:OpenMenu(player)

	--pause the game so the player doesnt get jumped by zombies
	if not isClient() and not isServer() and UIManager.getSpeedControls() then
		UIManager.getSpeedControls():SetCurrentGameSpeed(0)
		UIManager.setShowPausedMessage(false)
	end
	
	return CharCustomWindow
end


	-- -----------------------------------------
	-- -- GETTERS
	-- -----------------------------------------
function FaceManager_Shared.GetWornPlayerFace(player)
    for i=0, player:getWornItems():size()-1 do
        local item = player:getWornItems():getItemByIndex(i)
        if item:hasTag(SPNCC.ItemTag.Face) then return item end
    end
    return nil
end
function FaceManager_Shared.GetWornItemsWithTag(player, tag)
	local items = {}
    for i=0, player:getWornItems():size()-1 do
        local item = player:getWornItems():getItemByIndex(i)
        if item:hasTag(tag) then 
			table.insert(items, item) 
		end
    end
	return items
end
function FaceManager_Shared.GetFirstWornItemWithTag(player, tag)
    for i=0, player:getWornItems():size()-1 do
        local item = player:getWornItems():getItemByIndex(i)
        if item:hasTag(tag) then 
			return item
		end
    end
end
function FaceManager_Shared.GetWornItem(player, bodylocation)
    return player:getWornItem(bodylocation)
end
function FaceManager_Shared.GetWornItemWithTag(player, tag)
    for i=0, player:getWornItems():size()-1 do
        local item = player:getWornItems():getItemByIndex(i)
        if item:hasTag(tag) then return item end
    end
	return nil
end
function FaceManager_Shared.GetInventoryItemsWithTag(player, tag)
	local items = {}
	player:getInventory():getAllTagEval(tag, function(item) table.insert(items, item) end)
	return items
end


return FaceManager_Shared