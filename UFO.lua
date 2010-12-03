local L = UFOLocalization;

local UFO_Units = {"Player", "Target", "Pet", "Party",};
-- local UFO_Table = {}

function UFO_test()
	for i, unit in ipairs(UFO_Units) do
		print(i .. " " .. unit)
	end
end

function UFO_OnLoad(self)

	-- UIPanelWindows["UFO_Frame"] = {whileDead = 1, }

	self:RegisterEvent("ADDON_LOADED");
	self:SetBackdropBorderColor(.6, .6, .6, 1);
	local units = {}
	self.buttons = {}
	self.buttons.health = {}
	self.buttons.power = {}

	for i, unit in ipairs(UFO_Units) do
		-- print(i .. " " .. unit);
		
		local UnitText = self:CreateFontString(nil, "ARTWORK", "GameFontHighlight");
		UnitText:SetText(unit);
		units[i] = UnitText;

		local ButtonHealth = CreateFrame("CheckButton", "UFOButton" .. unit .. "Health", self, "UFOCheckButtonTemplate");
		ButtonHealth:SetChecked(false);
		self.buttons.health[i] = ButtonHealth;
		
		local ButtonPower = CreateFrame("CheckButton", "UFOButton" .. unit .. "Power", self, "UFOCheckButtonTemplate");
		ButtonPower:SetChecked(false);
		self.buttons.power[i] = ButtonPower;
		
		local ButtonHealthPerc = CreateFrame("CheckButton", "UFOButton" .. unit .. "HealthPerc", ButtonHealth, "UFOSmallCheckButtonTemplate");
		ButtonHealthPerc:SetChecked(false);
		self.buttons.health[i].perc = ButtonHealthPerc;
		
		local ButtonPowerPerc = CreateFrame("CheckButton", "UFOButton" .. unit .. "PowerPerc", ButtonHealth, "UFOSmallCheckButtonTemplate");
		ButtonPowerPerc:SetChecked(false);
		self.buttons.power[i].perc = ButtonPowerPerc;

		if i == 1 then
			UnitText:SetPoint("TOPLEFT", UFO_PanelSubText, "BOTTOMLEFT", 50, -55);
			ButtonHealth:SetPoint("TOPLEFT", UFO_PanelHealthText, "BOTTOMLEFT", -10, -20);
			ButtonPower:SetPoint("TOPLEFT", UFO_PanelManaText, "BOTTOMLEFT", -10, -20);
		else
			UnitText:SetPoint("TOPLEFT", units[i-1], "BOTTOMLEFT", 0, -35);
			ButtonHealth:SetPoint("TOPLEFT", self.buttons.health[i-1], "BOTTOMLEFT", 0, -20);
			ButtonPower:SetPoint("TOPLEFT", self.buttons.power[i-1], "BOTTOMLEFT", 0, -20)
		end
		ButtonHealthPerc:SetPoint("CENTER", ButtonHealth, "CENTER", 30, 0)
		ButtonPowerPerc:SetPoint("CENTER", ButtonPower, "CENTER", 30, 0)
	end
end

function UFO_OnEvent(self, event, ...)
	if event == "ADDON_LOADED" and ... == "UFO" then
		self:UnregisterEvent("ADDON_LOADED")

		print("Loaded1")
		
		if not UFO_DB then
			UFO_DB = {enable = true, };
			for i, unit in ipairs(UFO_Units) do
				print(i .. " " .. unit)
				UFO_DB[unit] = {};
				UFO_DB[unit].Health = true
				UFO_DB[unit].HealthPerc = false
				UFO_DB[unit].Power = true
				UFO_DB[unit].PowerPerc = true
			end
		end
		print("Loaded2")
		print (UFO_DB)
	end
	UFO_Update_OptionsFrame(self);
	-- UFO_Update_UnitFrames(self);
end

function UFO_OnClick(self, ...)
	local ButtonName = self:GetName()
	local UnitMatch
	local BarType

	for i, unit in ipairs(UFO_Units)
		UnitMatch = string.match(ButtonName, unit)
		if UnitMatch ~= nil then break end
	end

	BarType = string.match(ButtonName, "Health")
	if BarType == nil then BarType = "Power" end

	local perc = string.match(ButtonName, "Perc");

	if perc ~= nil then BarType = BarType .. perc; end
		
	if ( self:GetChecked() ) then
		PlaySound("igMainMenuOptionCheckBoxOn");
		UFO_DB[UnitMatch][BarType] = true;
	else
		PlaySound("igMainMenuOptionCheckBoxOff");
		UFO_DB[UnitMatch][BarType] = false;
	end
	UFO_Update_OptionsFrame(UFO_Frame);
end

function UFO_Update_OptionsFrame(self)
	for i, unit in ipairs(UFO_Units) do
		if (UFO_DB[unit].Health) then
			self.buttons.health[i]:SetChecked(true);
			if (UFO_DB[unit].HealthPerc) then
				self.buttons.health[i].perc:SetChecked(true);
			else
				self.buttons.health[i].perc:SetChecked(false);
			end
		else
			self.buttons.health[i]:SetChecked(false);
			self.buttons.health[i].perc:SetChecked(false);
			self.buttons.health[i].perc:Disable();
		end
		if (UFO_DB[unit].Power) then
			self.buttons.power[i]:SetChecked(true);
			if (UFO_DB[unit].PowerPerc) then
				self.buttons.power[i].perc:SetChecked(true);
			else
				self.buttons.power[i].perc:SetChecked(false);
			end
		else
			self.buttons.power[i]:SetChecked(false);
			self.buttons.power[i].perc:SetChecked(false);
			self.buttons.power[i].perc:Disable();
		end
	end
end

-- hooking
--[[
local origFrame

function UFO_DisplayPanel(...)
	local frame = ...

	origFrame = frame

	if (UFO_DB.enable) then
		if frame and frame:GetName() == "InterfaceOptionsStatusTextPanel" then
			frame:Hide()
			UFO_Panel:SetParent(InterfaceOptionsFramePanelContainer);
			UFO_Panel:ClearAllPoints();
			UFO_Panel:SetPoint("TOPLEFT", InterfaceOptionsFramePanelContainer, "TOPLEFT");
			UFO_Panel:SetPoint("BOTTOMRIGHT", InterfaceOptionsFramePanelContainer, "BOTTOMRIGHT");
			UFO_Panel:Show();
		else
			UFO_Panel:Hide()
		end
	end
end
	

hooksecurefunc("InterfaceOptionsList_DisplayPanel", UFO_DisplayPanel)
--]]


---[[
local origDisplayPanel = InterfaceOptionsList_DisplayPanel
local origFrame

function InterfaceOptionsList_DisplayPanel(...)
	local frame = ...
	local OrigFunc = origDisplayPanel(...);

	origFrame = frame

	-- post-hook
	if (UFO_DB.enable) then
		if frame and frame:GetName() == "InterfaceOptionsStatusTextPanel" then
			
			frame:Hide()
			UFO_Panel:SetParent(InterfaceOptionsFramePanelContainer);
			UFO_Panel:ClearAllPoints();
			UFO_Panel:SetPoint("TOPLEFT", InterfaceOptionsFramePanelContainer, "TOPLEFT");
			UFO_Panel:SetPoint("BOTTOMRIGHT", InterfaceOptionsFramePanelContainer, "BOTTOMRIGHT");
			UFO_Panel:Show();
		else
			UFO_Panel:Hide()
		end
	end
end
--]]

function UFO_Disable()
	UFO_DB.enable = false
	if (UFO_Panel:IsShown() == 1) then
		UFO_Panel:Hide()
		InterfaceOptionsList_DisplayPanel(origFrame)
	end
	
end

function UFO_Enable()
	UFO_DB.enable = true
	if (origFrame and origFrame:GetName() == "InterfaceOptionsStatusTextPanel") then
		InterfaceOptionsList_DisplayPanel(origFrame)
	end
	
end

function UFO_UpdateTextString(textStatusBar, ...)
	if UFO_DB.enable then
		local textString = textStatusBar.TextString;
		if(textString) then
			local value = textStatusBar:GetValue();
			local valueMin, valueMax = textStatusBar:GetMinMaxValues();

			if ( ( tonumber(valueMax) ~= valueMax or valueMax > 0 ) and not ( textStatusBar.pauseUpdates ) ) then
				textStatusBar:Show();
				if ( value and valueMax > 0 and UFO_DB ) then
					if ( value == 0 and textStatusBar.zeroText ) then
						textString:SetText(textStatusBar.zeroText);
						textStatusBar.isZero = 1;
						textString:Show();
						return;
					end
					value = tostring(math.ceil((value / valueMax) * 100)) .. "%";
					if 	(textStatusBar.prefix and (textStatusBar.alwaysPrefix or not 
						(textStatusBar.cvar and GetCVar(textStatusBar.cvar) == "1" and textStatusBar.textLockable) ) ) then
					
						textString:SetText(textStatusBar.prefix .. " " .. value);
					else
						textString:SetText(value);
					end
				elseif ( value == 0 and textStatusBar.zeroText ) then
					textString:SetText(textStatusBar.zeroText);
					textStatusBar.isZero = 1;
					textString:Show();
					return;
				else
					textStatusBar.isZero = nil;
					if ( textStatusBar.capNumericDisplay ) then
						value = TextStatusBar_CapDisplayOfNumericValue(value);
						valueMax = TextStatusBar_CapDisplayOfNumericValue(valueMax);
					end
					if 	( textStatusBar.prefix and (textStatusBar.alwaysPrefix or not 
						(textStatusBar.cvar and GetCVar(textStatusBar.cvar) == "1" and textStatusBar.textLockable) ) ) then
						
						textString:SetText(textStatusBar.prefix.." "..value.." / "..valueMax);
					else
						textString:SetText(value.." / "..valueMax);
					end
				end
			
				if 	( (textStatusBar.cvar and GetCVar(textStatusBar.cvar) == "1" and textStatusBar.textLockable) 
					or textStatusBar.forceShow ) then
					
					textString:Show();
				elseif ( textStatusBar.lockShow > 0 and (not textStatusBar.forceHideText) ) then
					textString:Show();
				else
					textString:Hide();
				end
			else
				textString:Hide();
				textString:SetText("");
				if ( not textStatusBar.alwaysShow ) then
					textStatusBar:Hide();
				else
					textStatusBar:SetValue(0);
				end
			end
		end
	end
end
hooksecurefunc("TextStatusBar_UpdateTextString", UFO_UpdateTextString)