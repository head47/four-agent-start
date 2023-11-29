local teamPreview = include( "states/state-team-preview" )
local util = include("client_util")
local mui = include( "mui/mui" )
local serverdefs = include( "modules/serverdefs" )
local scroll_text = include("hud/scroll_text")
local cdefs = include("client_defs")

local secondStage = false
local loaded = false
local onClickCampaignOld
local initScreenOld

local function init( modApi )
    modApi.requirements = {"Sim Constructor"}
    modApi:addGenerationOption("four_agent_start", "FOUR AGENT START" , "Allows you to select up to 4 agents by displaying the agent selection screen twice", {enabled = false} )
end

local function load( modApi, options )
    if not loaded then  -- loading on game start
        onClickCampaignOld = teamPreview.onClickCampaign
        initScreenOld = teamPreview.initScreen
        loaded = true
    else                -- loading on campaign start
        function has_value(tab, val)
            for index, value in pairs(tab) do
                if value == val then
                    return true
                end
            end
        
            return false
        end

        function teamPreview:onClickCampaign()
            if options.four_agent_start and options.four_agent_start.enabled then
                if not secondStage then
                    for k,v in pairs(self._selectedAgents) do
                        self._preselectedAgents[k] = v
                    end
                    for k,v in pairs(self._selectedLoadouts) do
                        self._preselectedLoadouts[k] = v
                    end
                    self._panel.binder.acceptBtn:setText("> BEGIN (2/4)")
                    secondStage = true
                    return
                else
                    for k1,v1 in pairs(self._preselectedAgents) do
                        if not has_value(self._selectedAgents, v1) then
                            self._selectedAgents[#self._selectedAgents+1] = v1
                            self._selectedLoadouts[#self._selectedLoadouts+1] = self._preselectedLoadouts[k1]
                        end
                    end
                    secondStage = false
                end
            end
            onClickCampaignOld(self)
        end

        function teamPreview:initScreen()
            log:write("4AS: executing modified initScreen")
            initScreenOld(self)
            if options.four_agent_start and options.four_agent_start.enabled then
                log:write("4AS selected")
                secondStage = false
                self._preselectedAgents = {}
                self._preselectedLoadouts = {}
                self._panel.binder.acceptBtn:setText("> BEGIN (0/4)")
            else
                log:write("4AS not selected!")
                self._panel.binder.acceptBtn:setText("> BEGIN")
            end
        end
    end
end

return {
    init = init,
    load = load,
}
