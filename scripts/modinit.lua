local teamPreview = include( "states/state-team-preview" )
local util = include("client_util")
local mui = include( "mui/mui" )
local serverdefs = include( "modules/serverdefs" )
local scroll_text = include("hud/scroll_text")
local cdefs = include("client_defs")

local function init( modApi )
    modApi.requirements = {"Sim Constructor"}
    modApi:addGenerationOption("four_agent_start", "FOUR AGENT START" , "Allows you to select up to 4 agents by displaying the agent selection screen twice", {enabled = false} )
end

local function load( modApi, options )
    function has_value(tab, val)
        for index, value in pairs(tab) do
            if value == val then
                return true
            end
        end
    
        return false
    end

    function teamPreview:onSecondClickCampaign()
        for k1,v1 in pairs(self._preselectedAgents) do
            if not has_value(self._selectedAgents, v1) then
                self._selectedAgents[#self._selectedAgents+1] = v1
                self._selectedLoadouts[#self._selectedLoadouts+1] = self._preselectedLoadouts[k1]
            end
        end
        self:onClickCampaign()
    end

    function teamPreview:onFirstClickCampaign()
        self._preselectedAgents = {}
        self._preselectedLoadouts = {}
        for k,v in pairs(self._selectedAgents) do
            self._preselectedAgents[k] = v
        end
        for k,v in pairs(self._selectedLoadouts) do
            self._preselectedLoadouts[k] = v
        end
        self._panel.binder.acceptBtn.onClick = util.makeDelegate( nil,  self.onSecondClickCampaign, self)
        self._panel.binder.acceptBtn:setText("> BEGIN (2/4)")
    end

    -- This is a mostly unchanged function from Sim Constructor, and is not covered by the mod license.
    function teamPreview:initScreen()
        self.screen = mui.createScreen( "team_preview_screen.lua" )
        mui.activateScreen( self.screen )
    
        self._scroll_text = scroll_text.panel( self.screen.binder.bg )
    
        self._panel = self.screen.binder.pnl
    
        self._panel.binder.title_txt:setText("")
        self._panel.binder.title_txt:spoolText(STRINGS.UI.SCREEN_NAME_TEAM_SELECT)
    
        if options.four_agent_start and options.four_agent_start.enabled then
            self._panel.binder.acceptBtn.onClick = util.makeDelegate( nil,  self.onFirstClickCampaign, self)
            self._panel.binder.acceptBtn:setText("> BEGIN (0/4)")
        else
            self._panel.binder.acceptBtn.onClick = util.makeDelegate( nil,  self.onClickCampaign, self)
            self._panel.binder.acceptBtn:setText("> BEGIN")
        end
        self._panel.binder.acceptBtn:setClickSound(cdefs.SOUND_HUD_MENU_CONFIRM)
    
        self._panel.binder.cancelBtn.onClick = util.makeDelegate( nil,  self.onClickCancel, self)
        self._panel.binder.cancelBtn:setClickSound(cdefs.SOUND_HUD_MENU_CANCEL)
        
        self._panel.binder.randomizeBtn.onClick = util.makeDelegate( nil, self.randomizeEverything, self )
    
    
        self._panel.binder.muteBtn.onClick = util.makeDelegate( nil, self.muteToggle, self )
        self._panel.binder.muteTxt:setVisible(false)
    
        local gameModeStr = serverdefs.GAME_MODE_STRINGS[ self._campaignDifficulty ]
        local ironmanStr = STRINGS.UI.HUD_OFF
        if self._campaignOptions.rewindsLeft == 0 then
            ironmanStr = STRINGS.UI.HUD_ON
        end
        local difficultyStr = string.format("%s: <c:8CFFFF>%s</>	%s: <c:8CFFFF>%s</>",
            util.toupper(STRINGS.UI.DIFFICULTY_STR),
            util.toupper(gameModeStr),
            STRINGS.UI.DIFF_OPTION_IRONMAN,
            ironmanStr )
        self._panel.binder.gameOptions:setText( difficultyStr)
    end
end

return {
    init = init,
    load = load,
}
