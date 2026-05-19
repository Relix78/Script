-- c:/Users/lukeb/OneDrive/Projects/Original/Scripts/NyroxHub/Games/Universal/Tabs/Updates/Update.lua

local function setupUpdatesTab(UpdatesTab)
    UpdatesTab:Section("Interface", "Left", os.time())
    UpdatesTab:CreateLog({Text = "+ RCTRL toggle added"})
    UpdatesTab:CreateLog({Text = "+ Searchbar added"})

    UpdatesTab:Section("System", "Left", os.time())
    UpdatesTab:CreateLog({Text = "+ Column detection"})
    UpdatesTab:CreateLog({Text = "+ Maintenance fixed"})

    UpdatesTab:Section("Performance", "Left", os.time())
    UpdatesTab:CreateLog({Text = "/ Memory optimized"})
    UpdatesTab:CreateLog({Text = "+ Lag reduction"})
    UpdatesTab:CreateLog({Text = "= Logic cleanup"})
    UpdatesTab:CreateLog({Text = "- Unused assets"})

    UpdatesTab:Section("Security", "Right", os.time())
    UpdatesTab:CreateLog({Text = "+ Bypass updated"})
    UpdatesTab:CreateLog({Text = "/ Encryption added"})
    UpdatesTab:CreateLog({Text = "= Integrity check"})
    UpdatesTab:CreateLog({Text = "- Log leaks"})

    UpdatesTab:Section("Development", "Right", os.time())
    UpdatesTab:CreateLog({Text = "/ API refactor"})
    UpdatesTab:CreateLog({Text = "+ Webhook support"})
    UpdatesTab:CreateLog({Text = "= Error handling"})
    UpdatesTab:CreateLog({Text = "- Legacy code"})

    UpdatesTab:Section("", "Right", os.time() - 90000) -- Zeigt "1 day ago"
    UpdatesTab:CreateLog({Text = "+ Initial UI Framework release"})
    UpdatesTab:CreateLog({Text = "= Optimized UI rendering performance"})
    UpdatesTab:CreateLog({Text = "- Removed notification system"})
    UpdatesTab:CreateLog({Text = "/ Refined Update-Tab layout"})
    UpdatesTab:CreateLog({Text = "+ Added basic movement features"})
end

return setupUpdatesTab