
function LevelupSellItems( keys )
	local caster = keys.caster
    local target = keys.target


    RemoveRedundantAbility(target)
    
	if not target:HasAbility("courier_sell_items_datadriven") then  --如果没有技能，赋予技能
		target:AddAbility("courier_sell_items_datadriven")
		target:FindAbilityByName("courier_sell_items_datadriven"):SetLevel(1)
	else  --升级技能
		local abilityLevel = target:FindAbilityByName("courier_sell_items_datadriven"):GetLevel()
		if abilityLevel<target:FindAbilityByName("courier_sell_items_datadriven"):GetMaxLevel() then
			target:FindAbilityByName("courier_sell_items_datadriven"):SetLevel(abilityLevel+1)
	    end
	end
	
end




function RemoveRedundantAbility(caster) --移除多余的信使技能
    if caster:HasAbility("courier_go_to_secretshop") then
       caster:RemoveAbility("courier_go_to_secretshop")
    end
    if caster:HasAbility("courier_return_stash_items") then
       caster:RemoveAbility("courier_return_stash_items")
    end
    if caster:HasAbility("courier_take_stash_items") then
       caster:RemoveAbility("courier_take_stash_items")
    end
    if caster:HasAbility("courier_transfer_items") then
       caster:RemoveAbility("courier_transfer_items")
    end		
end