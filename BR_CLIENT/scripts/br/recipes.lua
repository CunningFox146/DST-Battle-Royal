local env = env
GLOBAL.setfenv(1, GLOBAL)

local AddRecipe = env.AddRecipe

if AllRecipes["frostmourne"] then
    AllRecipes["frostmourne"].level = TECH.LOST
end

env.AddRecipe("shusui", {Ingredient("nightsword", 1),Ingredient("goldnugget", 3)}, RECIPETABS.WAR, TECH.NONE, nil, nil, nil, nil, "zorospecific").atlas = "images/inventoryimages/shusui.xml"
env.AddRecipe("sandai", {Ingredient("spear", 1), Ingredient("tentaclespike", 1)}, RECIPETABS.WAR, TECH.NONE, nil, nil, nil, nil, "zorospecific").atlas = "images/inventoryimages/sandai.xml"

