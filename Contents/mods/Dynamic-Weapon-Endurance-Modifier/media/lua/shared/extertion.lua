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
--            if (var1.Traits.Asthmatic.isSet()) {
--               var13 = 1.3F;
--            }
--
--            var10000 = var1.getStats();
--            var10000.endurance -= var12 * var13;
--         }
--      }

--DynamicEnduranceMod_Exceptions
--DynamicEnduranceMod_EnduranceMod

local function modifyWeaponsEnduranceMod()
    local SM = getScriptManager()
    local allItems = SM:getAllItems()
    local weaponsText = ""

    --string.find(subject string, pattern string,
    for i=0, allItems:size()-1 do
        ---@type Item
        local itemScript = allItems:get(i)
        local scriptType = itemScript:getTypeString()
        if scriptType == "Weapon" then

            local displayName = itemScript:getDisplayName()
            --local itemModuleDotType = itemScript:getFullName() -- module.Type
            local itemWeaponWeight = itemScript:getActualWeight()
            local itemEnduranceMod = itemScript:getEnduranceMod()

            local enduranceMod = SandboxVars.DynamicEnduranceMod.EnduranceMod
            local endMin = SandboxVars.DynamicEnduranceMod.ResultMin
            local endMax = SandboxVars.DynamicEnduranceMod.ResultMax

            local itemNewEnduranceMod = math.min(endMax, math.max(endMin, itemWeaponWeight * enduranceMod))

            if getDebug() then weaponsText = weaponsText..displayName.."	 w:"..round(itemWeaponWeight, 1).."	 old_e:"..round(itemEnduranceMod, 1).."	 new_e:"..round(itemNewEnduranceMod, 1).. ", \n" end
        end
    end

    if getDebug() then print("Weapons with non-1 itemEnduranceMod:\n"..weaponsText) end
end

Events.OnLoad.Add(modifyWeaponsEnduranceMod)
if isServer() then Events.OnGameBoot.Add(modifyWeaponsEnduranceMod) end