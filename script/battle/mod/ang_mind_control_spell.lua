out("DEBUG: mind control spell loaded")

require("ang_common")
require("ang_ui")

local mindControlSpell = "mind_control"
local mindControlSpellImage = "mind_control.png"
local mindControlListener = "mind_control_spell"
local mindControlDurationSelection = 10000
MindControl = MindControl or {}

local mindControlSpellDuration = 60000

---------------------------------------------------------------------------------------------------------------------------
--- @function getUnitUniqueId
--- @description This function will determine the unique id of a unit from a selected UI component.
--- It is used when an enemy unit is selected by clicking on the ping icon.
--- @uic The uicomponent that is being clicked on
--- @ending unique id of the unit that is extracted from the uicomponent path otherwise an empty string is returned.
--------------------------------------------------------------------------------------------------------------------------- 
local function getUnitUniqueId(uic)
	local uic_parent = uic;
	local name = uic_parent:Id();
	while name ~= "root" do
		if name == "modular_parent" then
			break;
		end;
		uic_parent = UIComponent(uic_parent:Parent());
		name = uic_parent:Id();
    end;
    if uic_parent then
        local unitId = uic_parent:Parent()
        if unitId then
            local uuid = UIComponent(unitId)
            return uuid:Id()
        end
    end
	return "";
end;

---------------------------------------------------------------------------------------------------------------------------
--- @function createMindControlButtons
--- @description This function creates the UI buttons for controlling enemy units under the
--- mind control spell
--------------------------------------------------------------------------------------------------------------------------- 
MindControl.createMindControlButtons = function()
    out("DEBUG: create mind control UI")
    local relativeComponent =
        find_uicomponent(
        core:get_ui_root(),
        "hud_battle",
        "winds_of_magic"
    )

    if relativeComponent then
        out("DEBUG: relative component: "..tostring(relativeComponent))
    end

    if not MindControl.moveEastButton then
        out("DEBUG: create mind control move east button")
        MindControl.moveEastButton = createButton(relativeComponent, "move_enemy_east", 42, 42, -140, 80, "ui/skins/default/icon_speed_controls_play.png", "CIRCULAR")
        MindControl.moveEastButton:SetTooltipText("Move enemy under the 'mind control spell' east", true)
        MindControl.moveEastButton:SetVisible(false)
        registerForClick(MindControl.moveEastButton, "move_enemy_east", MindControl.moveEnemyEast)
    end
    if not MindControl.moveWestButton then
        out("DEBUG: create mind control move west button")
        MindControl.moveWestButton = createButton(relativeComponent, "move_enemy_west", 42, 42, -220, 80, "ui/skins/default/icon_speed_controls_play.png", "CIRCULAR")
        MindControl.moveWestButton:SetImageRotation(0,d_to_r(180))
        MindControl.moveWestButton:SetTooltipText("Move enemy under the 'mind control spell' west", true)
        MindControl.moveWestButton:SetVisible(false)
        registerForClick(MindControl.moveWestButton, "move_enemy_west", MindControl.moveEnemyWest)
    end
    if not MindControl.moveSouthButton then
        out("DEBUG: create mind control move south button")
        MindControl.moveSouthButton = createButton(relativeComponent, "move_enemy_south", 42, 42, -180, 120, "ui/skins/default/icon_speed_controls_play.png", "CIRCULAR")
        MindControl.moveSouthButton:SetImageRotation(0,d_to_r(90))
        MindControl.moveSouthButton:SetTooltipText("Move enemy under the 'mind control spell' south", true)
        MindControl.moveSouthButton:SetVisible(false)
        registerForClick(MindControl.moveSouthButton, "move_enemy_south", MindControl.moveEnemySouth)
    end
    if not MindControl.moveNorthButton then
        out("DEBUG: create mind control move north button")
        MindControl.moveNorthButton = createButton(relativeComponent, "move_enemy_north", 42, 42, -180, 40, "ui/skins/default/icon_speed_controls_play.png", "CIRCULAR")
        MindControl.moveNorthButton:SetImageRotation(0,d_to_r(270))
        MindControl.moveNorthButton:SetTooltipText("Move enemy under the 'mind control spell' north", true)
        MindControl.moveNorthButton:SetVisible(false)
        registerForClick(MindControl.moveNorthButton, "move_enemy_north", MindControl.moveEnemyNorth)
    end
    if not MindControl.haltButton then
        out("DEBUG: create mind control halt button")
        MindControl.haltButton = createButton(relativeComponent, "halt_enemy", 42, 42, -240, 130, "ui/skins/default/icon_halt.png")
        MindControl.haltButton:SetTooltipText("Halt enemy under the 'mind control spell'", true)
        MindControl.haltButton:SetVisible(false)
        registerForClick(MindControl.haltButton, "halt_enemy", MindControl.haltEnemy)
    end
    if not MindControl.attackButton then
        MindControl.attackButton = createButton(relativeComponent, "attack_enemy", 42, 42, -120, 130, "ui/skins/default/icon_melee.png", "CIRCULAR_TOGGLE")
        MindControl.attackButton:SetTooltipText("Instruct enemy under the 'mind control spell' to attack closest enemy unit", true)
        MindControl.attackButton:SetVisible(false)
        registerForClick(MindControl.attackButton, "attack_enemy", MindControl.attackEnemy)
    end
    if not MindControl.durationDisplay then
        out("DEBUG: create mind control duration display button")
        MindControl.durationDisplay = createButton(relativeComponent, "duration_display", 42, 42, -180, 80, "ui/skins/default/spell_dial_spell_frame_mask.png", "CIRCULAR")
        MindControl.durationDisplay:SetTooltipText("Remaining seconds before the spell ends", true)
        MindControl.durationDisplay:SetVisible(false)
    end
    if not MindControl.coolDownText then
        out("DEBUG: create mind control cooldown text")
        MindControl.coolDownText = createText(MindControl.durationDisplay, "cooldown_counter_text", 42, 42, 15, 15, "TITLE")
        MindControl.coolDownText:SetTooltipText("Remaining seconds before the spell ends", true)
        MindControl.coolDownText:SetStateText(tostring(mindControlSpellDuration/1000))
        MindControl.coolDownText:SetVisible(false)
    end
end

---------------------------------------------------------------------------------------------------------------------------
--- @function showMindControlButtons
--- @description This function shows or hides all the buttons for the spell "mind control"
--------------------------------------------------------------------------------------------------------------------------- 
MindControl.showMindControlButtons = function(visible)
    out("DEBUG: show UI: "..tostring(visible))
    if MindControl.moveEastButton then
       MindControl.moveEastButton:SetVisible(visible)
    end
    if MindControl.moveNorthButton then
        MindControl.moveNorthButton:SetVisible(visible)
    end
    if MindControl.moveSouthButton then
        MindControl.moveSouthButton:SetVisible(visible)
    end
    if MindControl.moveWestButton then
        MindControl.moveWestButton:SetVisible(visible)
    end
    if MindControl.haltButton then
        MindControl.haltButton:SetVisible(visible)
    end
    if MindControl.attackButton then
        MindControl.attackButton:SetVisible(visible)
    end
    if MindControl.durationDisplay then
        MindControl.durationDisplay:SetVisible(visible)
    end
    if MindControl.coolDownText then
        MindControl.coolDownText:SetVisible(visible)
    end
end

---------------------------------------------------------------------------------------------------------------------------
--- @section move enemy actions
--------------------------------------------------------------------------------------------------------------------------- 
MindControl.moveEnemyEast = function()
    out("DEBUG: move enemy east")
    if MindControl.selectedMindControlUnit then
        MindControl.selectedMindControlUnit:stop_attack_closest_enemy()
        local pos = MindControl.selectedMindControlUnit.unit:position()
        out("DEBUG: current unit position ("..tostring(pos:get_x())..","..tostring(pos:get_y())..","..tostring(pos:get_z())..")")
        local newpos = battle_vector:new(pos:get_x()+100,pos:get_y(),pos:get_z())
        out("DEBUG: new unit position ("..tostring(newpos:get_x())..","..tostring(newpos:get_y())..","..tostring(newpos:get_z())..")")
        MindControl.selectedMindControlUnit.uc:goto_location(newpos, true)
    end
end

MindControl.moveEnemyWest = function()
    out("DEBUG: move enemy west")
    if MindControl.selectedMindControlUnit then
        MindControl.selectedMindControlUnit:stop_attack_closest_enemy()
        local pos = MindControl.selectedMindControlUnit.unit:position()
        out("DEBUG: current unit position ("..tostring(pos:get_x())..","..tostring(pos:get_y())..","..tostring(pos:get_z())..")")
        local newpos = battle_vector:new(pos:get_x()-100,pos:get_y(),pos:get_z())
        out("DEBUG: new unit position ("..tostring(newpos:get_x())..","..tostring(newpos:get_y())..","..tostring(newpos:get_z())..")")
        MindControl.selectedMindControlUnit.uc:goto_location(newpos, true)
    end
end

MindControl.moveEnemySouth = function()
    out("DEBUG: move enemy south")
    if MindControl.selectedMindControlUnit then
        MindControl.selectedMindControlUnit:stop_attack_closest_enemy()
        local pos = MindControl.selectedMindControlUnit.unit:position()
        out("DEBUG: current unit position ("..tostring(pos:get_x())..","..tostring(pos:get_y())..","..tostring(pos:get_z())..")")
        local newpos = battle_vector:new(pos:get_x(),pos:get_y(),pos:get_z()-100)
        out("DEBUG: new unit position ("..tostring(newpos:get_x())..","..tostring(newpos:get_y())..","..tostring(newpos:get_z())..")")
        MindControl.selectedMindControlUnit.uc:goto_location(newpos, true)
    end
end

MindControl.moveEnemyNorth = function()
    out("DEBUG: move enemy north")
    if MindControl.selectedMindControlUnit then
        MindControl.selectedMindControlUnit:stop_attack_closest_enemy()
        local pos = MindControl.selectedMindControlUnit.unit:position()
        out("DEBUG: current unit position ("..tostring(pos:get_x())..","..tostring(pos:get_y())..","..tostring(pos:get_z())..")")
        local newpos = battle_vector:new(pos:get_x(),pos:get_y(),pos:get_z()+100)
        out("DEBUG: new unit position ("..tostring(newpos:get_x())..","..tostring(newpos:get_y())..","..tostring(newpos:get_z())..")")
        MindControl.selectedMindControlUnit.uc:goto_location(newpos, true)
    end
end

MindControl.haltEnemy = function()
    out("DEBUG: halt enemy")
    if MindControl.selectedMindControlUnit then
        MindControl.selectedMindControlUnit:stop_attack_closest_enemy()
        MindControl.selectedMindControlUnit:halt()
    end
end

MindControl.attackEnemy = function(context)
    out("DEBUG: attack closest enemy unit")
    if MindControl.selectedMindControlUnit then
        MindControl.selectedMindControlUnit:stop_attack_closest_enemy()
        MindControl.selectedMindControlUnit:start_attack_closest_enemy()
    end
end

---------------------------------------------------------------------------------------------------------------------------
--- @function getMindControlUnitById
--- @description This function checks whether the passed script unit is the last selected unit for the
--- mind control spell.
--- @sunit the script unit to test
--- @ending true if it matches otherwise false
--------------------------------------------------------------------------------------------------------------------------- 
MindControl.getMindControlUnitById = function(sunit)
    if MindControl.lastSelectedMindControlUnitId then
        return tostring(sunit.unit:unique_ui_id()) == MindControl.lastSelectedMindControlUnitId
    end
    return false
end

---------------------------------------------------------------------------------------------------------------------------
--- @function getSpell
--- @description This function determines whether the passed in ui component is a spell button or not.
--- If it is a spell button then this function will return the name of the spell
--- @component the full image path for the spell. Fx: data/ui/Battle UI/ability_icons/mind_control.png
--------------------------------------------------------------------------------------------------------------------------- 
MindControl.getSpell = function(component)
    local componentImagePath = component:GetImagePath()
    local isspell = uicomponent_descended_from(component, "spell_parent")
    local currentState = component:CurrentState()
    out("DEBUG: image path "..tostring(component:GetImagePath()))
    out("DEBUG: is spell "..tostring(isspell))
    out("DEBUG: current state "..tostring(currentState))
    if isspell and currentState == "hover" and componentImagePath then
        out("DEBUG: check image path")
        if ends_with(componentImagePath, mindControlSpellImage) then
            out("DEBUG: got spell: "..tostring(mindControlSpell))
            return mindControlSpell
        end
    end
    return nil
end

---------------------------------------------------------------------------------------------------------------------------
--- @function getMindControlUnitSelected
--- @description This function determines whether the passed in ui component is a spell button or not.
--- If it is a spell button then this function will return the name of the spell
--- @component the full image path for the spell. Fx: data/ui/Battle UI/ability_icons/mind_control.png
--------------------------------------------------------------------------------------------------------------------------- 
MindControl.getMindControlUnitSelected = function(component)
    local isUnit = uicomponent_descended_from(component, "script_ping_parent")
    if isUnit then
        local uuid = getUnitUniqueId(component)
        if uuid then
            out("DEBUG: unique unit id: "..tostring(uuid))
            if MindControl.lastSelectedMindControlUnitId == nil then
                MindControl.clearMindControlUnits()
                MindControl.lastSelectedMindControlUnitId = tostring(uuid)
                if MindControl.mindControlUnits then
                    local filteredUnits = MindControl.mindControlUnits:filter("FilteredMindControlUnits",MindControl.getMindControlUnitById)
                    if filteredUnits and filteredUnits:count() == 1 then
                        local firstUnit = filteredUnits:item(1)
                        if firstUnit then
                            out("DEBUG: clicked on unit: "..tostring(firstUnit.unit:unique_ui_id()))
                            return firstUnit
                        end
                    end
                end
            else
                out("DEBUG: already selected enemy unit with id: "..tostring(MindControl.lastSelectedMindControlUnitId))
            end
        end
    end
    return nil
end

---------------------------------------------------------------------------------------------------------------------------
--- @function clearMindControlUnits
--- @description This function will remove the ping icon above all units from mind control collection.
--- This is to ensure they cannot be selected.
--------------------------------------------------------------------------------------------------------------------------- 
MindControl.clearMindControlUnits = function()
    if MindControl.mindControlUnits then
        for i = 1, MindControl.mindControlUnits:count() do
            local sunit = MindControl.mindControlUnits:item(i)
            if sunit then
                sunit:remove_ping_icon()
            end
        end
    end
end

---------------------------------------------------------------------------------------------------------------------------
--- @function activateMindControl
--- @description This function will activate the spell "mind control". It will find all enemy units
--- and put a ping icon on them so they are selectable. It will wait for the player to select one of the
--- enemy unit.
--------------------------------------------------------------------------------------------------------------------------- 
MindControl.activateMindControl = function()
    out("DEBUG: activate mind control spell")
    MindControl.clearMindControlUnits()
    MindControl.mindControlUnits = script_units:new("MindControlUnits")
    local armies = bm:get_non_player_alliance():armies()
    for i = 1, armies:count() do
        local army = armies:item(i)
        local units = army:units()
        for j = 1, units:count() do
            local unit = units:item(j)
            if unit and not unit:is_commanding_unit() then
                out("DEBUG: unit: "..tostring(unit:name()))
                local sunit = script_unit:new_by_reference(army, unit:name())
                sunit:add_ping_icon(2,mindControlDurationSelection)
                MindControl.mindControlUnits:add_sunits(sunit)
            end
        end
    end
    MindControl.lastSelectedMindControlUnitId = nil
end

---------------------------------------------------------------------------------------------------------------------------
--- @function handleUiClick
--- @description This function will handle whenever a UI component has been clicked on. It will check whether
--- the component is a spell button or selected enemies etc.
--- @context context object passed from ComponentLClickUp event
--------------------------------------------------------------------------------------------------------------------------- 
MindControl.handleUiClick = function(context)
    out("DEBUG: ui click string: "..tostring(context.string))
    out("DEBUG: ui component id: "..tostring(UIComponent(context.component):Id()))
    local component = UIComponent(context.component)
    out("DEBUG: ui animation id: "..tostring(component:CurrentAnimationId()))
    local spellName = MindControl.getSpell(component)
    out("DEBUG: spell name: "..tostring(spellName))
    local mindControlUnitSelected = MindControl.getMindControlUnitSelected(component)
    if spellName == mindControlSpell then
        bm:callback(MindControl.activateMindControl,0.1)
    elseif mindControlUnitSelected then
        out("DEBUG: cast mind control spell on selected unit"..tostring(mindControlUnitSelected.unit:unique_ui_id()))
        MindControl.castMindControl(mindControlUnitSelected)
    end
end

---------------------------------------------------------------------------------------------------------------------------
--- @function castMindControl
--- @description Performs the actual spell for mind control
--- @sunit The unit under the spell
--------------------------------------------------------------------------------------------------------------------------- 
MindControl.castMindControl = function(sunit)
    bm:remove_process("end_mind_control")
    MindControl.endMindControl()
    out("DEBUG: take control of unit: "..tostring(sunit.unit:unique_ui_id()))
    MindControl.selectedMindControlUnit = sunit
    sunit:take_control()
    sunit:add_ping_icon(4, mindControlSpellDuration)
    bm:callback(MindControl.endMindControl, mindControlSpellDuration, "end_mind_control")
    MindControl.showMindControlButtons(true)
    bm:repeat_callback(MindControl.mindControlCooldown,1000,"mind_control_cooldown")

end

---------------------------------------------------------------------------------------------------------------------------
--- @function endMindControl
--- @description Ends the spell mind control and release control of the affected unit
--- @sunit The unit under the spell
--------------------------------------------------------------------------------------------------------------------------- 
MindControl.endMindControl = function()
    out("DEBUG: end mind control")
    if MindControl.selectedMindControlUnit then
        MindControl.haltEnemy()
        MindControl.selectedMindControlUnit:stop_attack_closest_enemy()
        out("DEBUG: release mind control unit")
        MindControl.selectedMindControlUnit:release_control()
        MindControl.selectedMindControlUnit:remove_ping_icon()
    end
    MindControl.showMindControlButtons(false)
    bm:remove_process("mind_control_cooldown")
    MindControl.mindControlCooldownCounter = 0
end

MindControl.mindControlCooldown = function()
    if MindControl.durationDisplay then
        MindControl.mindControlCooldownCounter = MindControl.mindControlCooldownCounter+1
        local countDown = (mindControlSpellDuration/1000) - MindControl.mindControlCooldownCounter
        MindControl.coolDownText:SetStateText(tostring(countDown))
    end
end

---------------------------------------------------------------------------------------------------------------------------
--- @section Set up listeners
--------------------------------------------------------------------------------------------------------------------------- 
core:remove_listener(mindControlListener)

core:add_listener(
    mindControlListener,
    "ComponentLClickUp",
    true,
    MindControl.handleUiClick,
    true
);

MindControl.createMindControlButtons()