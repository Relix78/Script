local Games = {}

Games.Games = {
    BloxFruits = {
        Name = "Blox Fruits",
        Icon = "[BF]",
        PlaceIds = {
            2753915549,          -- First Sea
            85211729168715,      -- First Sea (Variant)
            4442272183,          -- Second Sea
            79091703265657,      -- Second Sea (Variant)
            7449423635,          -- Third Sea
            100117331123089      -- Private Server
        },
        Script = "Games/Bloxfruits/main.lua",
        DevMode = false -- Setze auf true für Wartungsarbeiten
    },

    SlimeRNG = {
        Name = "Slime RNG",
        Icon = "[SRNG]",
        PlaceIds = {
            16908638118,
            92416421522960 -- Hauptspiel ID
        },
        Script = "Games/SlimeRNG/main.lua",
        DevMode = true -- Setze auf true für Wartungsarbeiten
    }
}
-- DETECTION LOGIC

function Games.DetectGame()
    local placeId = game.PlaceId
    
    for gameName, gameData in pairs(Games.Games) do
        for _, id in ipairs(gameData.PlaceIds) do
            if id == placeId then
                return {
                    Name = gameName,
                    DisplayName = gameData.Name,
                    Icon = gameData.Icon or "[?]",
                    Script = gameData.Script,
                    DevMode = gameData.DevMode or false
                }
            end
        end
    end
    return nil
end

return Games