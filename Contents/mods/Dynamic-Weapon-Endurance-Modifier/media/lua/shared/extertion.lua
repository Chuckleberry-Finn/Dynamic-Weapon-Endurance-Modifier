---zombie/ai/states/SwipeStatePlayer.java #1249
--      if (var2.isUseEndurance()) {
--         float var11 = 0.0F;
--         if (var2.isTwoHandWeapon() && (var1.getPrimaryHandItem() != var2 || var1.getSecondaryHandItem() != var2)) {
--            var11 = var2.getWeight() / 1.5F / 10.0F;
--         }
--
--         if (var9 <= 0 && !var1.isForceShove()) {
--            float var12 = (var2.getWeight() * 0.18F * var2.getFatigueMod(var1) * var1.getFatigueMod() * var2.getEnduranceMod() * 0.3F + var11) * 0.04F;
--            float var13 = 1.0F;
--            if (var1.Traits.Asthmatic.isSet()) { var13 = 1.3F; }
--            var10000 = var1.getStats();
--            var10000.endurance -= var12 * var13;
--         }
--      }

local function modifyWeaponsEnduranceMod()
    local SM = getScriptManager()
    local allItems = SM:getAllItems()
    local weaponsText = ""

    local enduranceModOverwrites = {}

    local exceptions = SandboxVars.DynamicEnduranceMod.Exceptions
    for roleColor in string.gmatch(exceptions, "([^;]+)") do
        local itemType,endMod = string.match(roleColor, "(.*):(.*)")
        if itemType and endMod then
            enduranceModOverwrites[itemType] = endMod
        end
    end

    --string.find(subject string, pattern string,
    for i=0, allItems:size()-1 do
        ---@type Item
        local itemScript = allItems:get(i)
        local scriptType = itemScript:getTypeString()
        if scriptType == "Weapon" then

            local itemType = itemScript:getName()
            local itemModuleDotType = itemScript:getFullName() -- module.Type
            local itemDisplayCategory = itemScript:getDisplayCategory()

            local itemWeaponWeight = itemScript:getActualWeight()
            local itemEnduranceMod = itemScript:getEnduranceMod()

            local enduranceMod = SandboxVars.DynamicEnduranceMod.EnduranceMod
            local endMin = SandboxVars.DynamicEnduranceMod.ResultMin
            local endMax = SandboxVars.DynamicEnduranceMod.ResultMax

            local itemEndModOverwrite = enduranceModOverwrites[itemModuleDotType] or enduranceModOverwrites[itemType] or enduranceModOverwrites[itemDisplayCategory] or nil
            local itemNewEnduranceMod = itemEndModOverwrite or math.min(endMax, math.max(endMin, itemWeaponWeight * enduranceMod))

            if getDebug() then
                local eText = (itemEndModOverwrite and "overwrite_e") or "new_e"
                weaponsText = weaponsText..itemType..
                        "	 w:"..round(itemWeaponWeight, 1)..
                        "	 old_e:"..round(itemEnduranceMod, 1)..
                        "	 "..eText..":"..round(itemNewEnduranceMod, 1)..
                        ", \n"
            end
        end
    end

    if getDebug() then print("Dynamic Weapon Endurance Mod:\n"..weaponsText) end
end

Events.OnLoad.Add(modifyWeaponsEnduranceMod)
if isServer() then Events.OnGameBoot.Add(modifyWeaponsEnduranceMod) end