
VehicleControlAddonMenu = {}

local VehicleControlAddonMenu_mt = Class(VehicleControlAddonMenu, TabbedMenu)

--- Page tab UV coordinates for display elements.
VehicleControlAddonMenu.TAB_UV = {
	SETTINGS    = { 0, 209, 65, 65 },
	GENERAL     = {844, 144, 65, 65},
	ENVIRONMENT = {65, 144, 65, 65},
	PLAYER      = {454, 209, 65, 65},
	FIELD       = {432, 96, 48, 48},
	VEHICLES    = {130, 144, 65, 65},
}

VehicleControlAddonMenu.CONTROLS = {
	BACKGROUND    = "inGameBackgroundElement",
	FRAME1 = "vcaFrame1",
	FRAME2 = "vcaFrame2",
	FRAME3 = "vcaFrame3",
	FRAME5 = "vcaFrame5",
}

local alwaysVisiblePredicate = function() return true end
local frame5VisiblePredicate = function() 
	return g_currentMission.controlledVehicle.vcaTransmission == vehicleControlAddonTransmissionBase.ownTransmission 
end 

VehicleControlAddonMenu.FRAMES = {
	{ name = "vcaFrame1", iconUVs = VehicleControlAddonMenu.TAB_UV.SETTINGS },
	{ name = "vcaFrame2", iconUVs = VehicleControlAddonMenu.TAB_UV.VEHICLES },
	{ name = "vcaFrame3", iconUVs = VehicleControlAddonMenu.TAB_UV.GENERAL, },
	{ name = "vcaFrame5", iconUVs = VehicleControlAddonMenu.TAB_UV.PLAYER   },
}

VehicleControlAddonMenu.L10N_SYMBOL = {
    BUTTON_BACK = "button_back",
}

function VehicleControlAddonMenu:new(messageCenter, i18n, inputManager)
	local self = TabbedMenu:new(nil, VehicleControlAddonMenu_mt, messageCenter, i18n, inputManager)
	self:registerControls(VehicleControlAddonMenu.CONTROLS)
	self.vcaInactiveFrames = {}
	return self
end

function VehicleControlAddonMenu:vcaSetIsFrameVisible( name, visible )
	self.vcaInactiveFrames[name] = not visible
end 

function VehicleControlAddonMenu:vcaGetIsFrameVisible( name )
	if self.vcaInactiveFrames[name] then	
		return false 
	end 
	return true 
end 

function VehicleControlAddonMenu:onGuiSetupFinished()
	VehicleControlAddonMenu:superClass().onGuiSetupFinished(self)

	self.clickBackCallback = self:makeSelfCallback(self.onButtonBack)


	for i,f in pairs(VehicleControlAddonMenu.FRAMES) do 
		if f.name ~= nil and type( self[f.name] ) == "table" and type( self[f.name].initialize ) == "function" then 
			local frame = self[f.name]
			frame:initialize()
			local predicate = f.predicate
			if predicate == nil then 
				predicate = function() return self:vcaGetIsFrameVisible( f.name ) end 
			end 
			self:registerPage( frame, i, Utils.getNoNil( f.predicate, predicate ) )
			self:addPageTab( frame, Utils.getNoNil( f.uiFilename, g_baseUIFilename), getNormalizedUVs( f.iconUVs ) )
		else 
			print("ERROR: "..tostring(f.name).."; "..type( self[f.name] ) == "table")
		end 
	end 
end

function VehicleControlAddonMenu:onMenuOpened()
	VehicleControlAddonMenu:superClass().onMenuOpened(self)
	
	self:updatePages()
	
	self.vcaInputEnabled = true  
end


function VehicleControlAddonMenu:onClose()
	VehicleControlAddonMenu:superClass().onClose(self)

	self.vcaInputEnabled = false 
end

function VehicleControlAddonMenu:setupMenuButtonInfo()
	VehicleControlAddonMenu:superClass().setupMenuButtonInfo(self)

	self.defaultMenuButtonInfo = {{ inputAction = InputAction.MENU_BACK,
																	text        = self.l10n:getText(VehicleControlAddonMenu.L10N_SYMBOL.BUTTON_BACK),
																	callback    = self.clickBackCallback },
															 }

	self.defaultMenuButtonInfoByActions[InputAction.MENU_BACK] = self.defaultMenuButtonInfo[1]

	self.defaultButtonActionCallbacks = { [InputAction.MENU_BACK] = self.clickBackCallback }
end

function VehicleControlAddonMenu:setShowOwnTransmission( enabled )
	local b1 = self:vcaGetIsFrameVisible( "vcaFrame5" )
	
	self:vcaSetIsFrameVisible( "vcaFrame5", enabled )
	
	local b2 = self:vcaGetIsFrameVisible( "vcaFrame5" )
	
	if b1 ~= b2 and self.vcaInputEnabled then 
		self:updatePages()
	end 
end 

function VehicleControlAddonMenu:onPageChange(pageIndex, pageMappingIndex, element, skipTabVisualUpdate)
	local f = VehicleControlAddonMenu:superClass().onPageChange
	local state, result = pcall( f, self,pageIndex, pageMappingIndex, element, skipTabVisualUpdate )
	if not state then 
		print("Error: "..tostring(result))
		self.currentPage = nil 
	end 
end 


