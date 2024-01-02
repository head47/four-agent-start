local selectedAgents = 0
local startingAgentNumber = 2
local onClickCampaignOld
local initScreenOld

local function init( modApi )
    modApi.requirements = {"Sim Constructor", "Incognita Socket: Online Multiplayer"}
    modApi:addGenerationOption("starting_agent_number", "FOUR AGENT START", "How many agents to select at campaign start", {values = {2,4,6,8,10,12,14,16}, value=2} )
end

local function load( modApi, options )
    local teamPreview = include( "states/state-team-preview" )

    onClickCampaignOld = onClickCampaignOld or teamPreview.onClickCampaign
    initScreenOld = initScreenOld or teamPreview.initScreen

    function has_value(tab, val)
        for index, value in pairs(tab) do
            if value == val then
                return true
            end
        end
    
        return false
    end

    function teamPreview:onClickCampaign()
        log:write("4AS: executing modified onClickCampaign")
        if options.starting_agent_number then
            if startingAgentNumber-2 > selectedAgents then
                for _,v in pairs(self._selectedAgents) do
                    self._preselectedAgents[#self._preselectedAgents+1] = v
                end
                for _,v in pairs(self._selectedLoadouts) do
                    self._preselectedLoadouts[#self._preselectedLoadouts+1] = v
                end
                selectedAgents = selectedAgents+2
                self._panel.binder.acceptBtn:setText(STRINGS.SCREENS.STR_851442695 .. [[ (]] .. selectedAgents .. [[/]] .. startingAgentNumber .. [[)]])
                return
            else
                for k,v in pairs(self._preselectedAgents) do
                    if not has_value(self._selectedAgents, v) then
                        self._selectedAgents[#self._selectedAgents+1] = v
                        self._selectedLoadouts[#self._selectedLoadouts+1] = self._preselectedLoadouts[k]
                    end
                end
                selectedAgents = 0
            end
        end
        onClickCampaignOld(self)
    end

    function teamPreview:initScreen()
        log:write("4AS: executing modified initScreen")
        initScreenOld(self)
        if options.starting_agent_number then
            log:write("4AS: proceeding to select " .. options.starting_agent_number.value .. " agents")
            startingAgentNumber = options.starting_agent_number.value
            selectedAgents = 0
            self._preselectedAgents = {}
            self._preselectedLoadouts = {}
            self._panel.binder.acceptBtn:setText(STRINGS.SCREENS.STR_851442695 .. [[ (0/]] .. options.starting_agent_number.value .. [[)]])
        else
            log:write("4AS not active!")
            self._panel.binder.acceptBtn:setText(STRINGS.SCREENS.STR_851442695)
        end
    end
end

return {
    init = init,
    load = load,
}
