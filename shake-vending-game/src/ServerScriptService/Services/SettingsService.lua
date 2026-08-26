local SettingsService = {}
local EFFECT_QUALITY = {Low=true, Medium=true, High=true}
local function setPlayerAttribute(player,key,value)player:SetAttribute("ShakeVM_"..key,value)end
function SettingsService:Init(RemoteService,DataService,TradingService)
    self.RemoteService=RemoteService;self.DataService=DataService;self.TradingService=TradingService
    RemoteService.Events.SettingsAction.OnServerEvent:Connect(function(player,action,value)
        if not RemoteService:Allow(player,"settings",6,10) then return end
        if type(action)~="string" then return end
        local profile=DataService:GetProfile(player);if not profile then return end;profile.Settings=profile.Settings or {}
        if action=="trade_enabled" and type(value)=="boolean" then profile.TradeSettings.Enabled=value;if not value then TradingService:CancelForUser(player.UserId,"Trading disabled") end;RemoteService.Events.Toast:FireClient(player,{Text=value and "Trade requests enabled" or "Trade requests disabled",Kind="Info"});return end
        if action=="effect_quality" and EFFECT_QUALITY[value] then profile.Settings.EffectQuality=value;setPlayerAttribute(player,"EffectQuality",value)
        elseif action=="reduced_effects" and type(value)=="boolean" then profile.Settings.ReducedEffects=value;setPlayerAttribute(player,"ReducedEffects",value)
        elseif action=="reduced_screen_shake" and type(value)=="boolean" then profile.Settings.ReducedScreenShake=value;setPlayerAttribute(player,"ReducedScreenShake",value)
        elseif action=="skip_long_reveals" and type(value)=="boolean" then profile.Settings.SkipLongReveals=value;setPlayerAttribute(player,"SkipLongReveals",value)
        elseif action=="music_enabled" and type(value)=="boolean" then profile.Settings.MusicEnabled=value;setPlayerAttribute(player,"MusicEnabled",value)
        elseif action=="sfx_enabled" and type(value)=="boolean" then profile.Settings.SFXEnabled=value;setPlayerAttribute(player,"SFXEnabled",value)
        elseif action=="intro_seen" and value==true then profile.Settings.IntroSeen=true;setPlayerAttribute(player,"IntroSeen",true)
        elseif action=="tutorial_complete" and value==true then profile.Settings.TutorialComplete=true;setPlayerAttribute(player,"TutorialComplete",true)
        elseif action=="tutorial_reset" and value==true then profile.Settings.TutorialComplete=false;setPlayerAttribute(player,"TutorialComplete",false)
        elseif action=="auto_lock_legendary" and type(value)=="boolean" then profile.Settings.AutoLockLegendary=value
        elseif action=="keep_one_each" and type(value)=="boolean" then profile.Settings.KeepOneEach=value
        else return end
    end)
end
return SettingsService
