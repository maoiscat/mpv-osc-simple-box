-- mpv-osc-simple
-- by maoiscat
-- github/maoiscat/mpv-osc-simple

require 'elements'
local assdraw = require 'mp.assdraw'

mp.commandv('set', 'osc', 'no')

-- user options
opts = {
    scale = 2,              -- osc render scale
    fixedHeight = false,    -- true to allow osc scale with window
    hideTimeout = 1,        -- seconds untile osc hides, negative means never
    fadeDuration = 0.5,     -- seconds during fade out, negative means never
	boxPosRatio = 0.3,		-- box space ratio from bottom
	boxWidth = 450,			-- 
	boxHeight = 50,			--
    }

-- styles
styles = {
    tooltip = {
        color = {'FFFFFF', '0', '0', '0'},
        border = 1,
        blur = 2,
        font = 'mpv-osd-symbols',
        fontsize = 16,
        wrap = 0,
        },
    panel = {
        color = {'f2f2f2', '0', '0', '0'},
        alpha = {0, 255, 25, 255},
        blur = 1,
        border = 0.1,
        },
    time = {
        font = 'mpv-osd-symbols',
        fontsize = 12
        },
    button = {
        color = {'3A3A3A', '0', '0', '0'},
        alpha = {0, 255, 255, 255},
        blur = 0,
        border = 0,
        font = 'mpv-osd-symbols',
        fontsize = 16
        },
    button2 = {
        color = {'0', '0', '0', '0'},
        alpha = {0, 255, 255, 255},
        blur = 0,
        border = 0,
        font = 'mpv-osd-symbols',
        fontsize = 16
        },
    seekbarF = {
        color = {'C7A25A', '0', '0', '0'},
        alpha = {0, 255, 255, 255},
        blur = 0,
        border = 0,
        },
    seekbarB = {
        color = {'C0C0C0', '0', '0', '0'},
        alpha = {0, 255, 255, 255},
        blur = 0,
        border = 0,
        },
	seekbarH = {
        color = {'FFFFFF', '0', '0', '0'},
        alpha = {0, 255, 255, 255},
        blur = 0,
        border = 0,
        },
    down = {
        color = {'999999', '0', '0', '0'},
        alpha = {0, 255, 255, 255},
        blur = 0,
        border = 0,
        font = 'mpv-osd-symbols',
        fontsize = 16
        },
    title = {
        color = {'ffffff', 'ffffff', '0', '0'},
        border = 0.5,
        blur = 1,
        fontsize = 16,
        wrap = 2,
        },
    top1 = {
        color = {'eeeeee', 'eeeeee', '0', '0'},
        alpha = {100, 255, 100, 255},
        border = 0,
        blur = 0,
        font = 'mpv-osd-symbols',
        fontsize = 20,
        },
    top2 = {
        color = {'ffffff', 'ffffff', '0', '0'},
        alpha = {0, 255, 0, 255},
        border = 0.5,
        blur = 1,
        font = 'mpv-osd-symbols',
        fontsize = 20,
        },
    }

-- logo
local ne
ne = addToIdleLayout('logo')
ne:init()

-- message
local msg = addToIdleLayout('message')
msg:init()

-- an enviromental variable updater
ne = newElement('updater')
ne.layer = 1000
ne.geo = nil
ne.style = nil
ne.visible = false
ne.init = function(self)
		-- opts backup
		player.userScale = opts.scale
        -- event generators
        mp.register_event('file-loaded',
            function()
                player.tracks = getTrackList()
                player.playlist = getPlaylist()
                player.chapters = getChapterList()
                player.playlistPos = getPlaylistPos()
                player.duration = mp.get_property_number('duration')
                dispatchEvent('file-loaded')
            end)
        mp.observe_property('pause', 'bool',
            function(name, val)
                player.paused = val
                dispatchEvent('pause')
            end)
        mp.observe_property('fullscreen', 'bool',
            function(name, val)
                player.fullscreen = val
                dispatchEvent('fullscreen')
            end)
        mp.observe_property('current-tracks/audio/id', 'number',
            function(name, val)
                if val then player.audioTrack = val
                    else player.audioTrack = 0
                        end
                dispatchEvent('audio-changed')
            end)
        mp.observe_property('current-tracks/sub/id', 'number',
            function(name, val)
                if val then player.subTrack = val
                    else player.subTrack = 0
                        end
                dispatchEvent('sub-changed')
            end)
        mp.observe_property('loop-playlist', 'string',
            function(name, val)
                player.loopPlaylist = val
                dispatchEvent('loop-playlist')
            end)
        mp.observe_property('volume', 'number',
            function(name, val)
                player.volume = val
                dispatchEvent('volume')
            end)
    end
ne.tick = function(self)
        player.percentPos = mp.get_property_number('percent-pos')
        player.timePos = mp.get_property_number('time-pos')
        player.timeRem = mp.get_property_number('time-remaining')
        dispatchEvent('time')
        return ''
    end
ne.responder['resize'] = function(self)
        player.geo.refX = player.geo.width / 2
        player.geo.refLeft = player.geo.refX - opts.boxWidth/2
        player.geo.refRight = player.geo.refLeft + opts.boxWidth
        player.geo.refWidth = opts.boxWidth
        if player.geo.refLeft < 20 then
			player.geo.refLeft = 20
			player.geo.refRight = player.geo.width - 20
			player.geo.refWidth = player.geo.refRight - player.geo.refLeft
		end
		player.geo.refY = player.geo.height * (1 - opts.boxPosRatio) - opts.boxHeight / 2
		if player.geo.refY < 0 then player.geo.refY = 0 end
		player.geo.refY2 = player.geo.refY + 35
        setPlayActiveArea('area1', 0, player.geo.refY-100, player.geo.width, player.geo.refY+opts.boxHeight+100, 'show_hide')
        setPlayActiveArea('area2', player.geo.refLeft, player.geo.refY, player.geo.refRight, player.geo.refY+opts.boxHeight)
        setPlayActiveArea('area3', player.geo.width-150, 0, player.geo.width, 24)
        return false
    end
ne:init()
local updater = ne
addToPlayLayout('updater')
-- a shared tooltip
ne = newElement('tip', 'tooltip')
ne.layer = 50
ne.style = clone(styles.tooltip)
ne:init()
addToPlayLayout('tip')
local tooltip = ne

-- panel background
ne = newElement('panel', 'box')
ne.layer = 10
ne.style = styles.panel
ne.geo.r = 3
ne.geo.an = 8
ne.geo.w = opts.boxWidth
ne.geo.h = opts.boxHeight
ne.responder['resize'] = function(self)
        self.geo.x = player.geo.refX
        self.geo.y = player.geo.refY
        self:setPos()
        
        local w = player.geo.width - 20
        if w < opts.boxWidth then
			self.geo.w = player.geo.width - 20
		else
			self.geo.w = opts.boxWidth
		end
		self:render()
    end
ne:init()
addToPlayLayout('panel')

-- play pause button
ne = newElement('btnPlay', 'button')
ne.layer = 20
ne.geo.w = 20
ne.geo.h = 20
ne.geo.an = 5
ne.styleNormal = styles.button
ne.styleActive = styles.button2
ne.styleDisabled = styles.down
ne.responder['resize'] = function(self)
		self.geo.x = player.geo.refX
        self.geo.y = player.geo.refY2
        self:setPos()
        self:setHitBox()
    end
ne.responder['mbtn_left_up'] = function(self, pos)
        if self.enabled and self:isInside(pos) then
            mp.commandv('cycle', 'pause')
            return true
        end
        return false
    end
ne.responder['pause'] = function(self)
        if player.paused then
            self.text = '{\\fscx120}\238\132\129'
        else
            self.text = '{\\fscx150}\238\128\130'
        end
        self:render()
        return false
    end
ne:init()
addToPlayLayout('btnPlay')

-- time
ne = newElement('time', 'button')
ne.layer = 20
ne.styleNormal = clone(styles.button)
ne.styleActive = clone(styles.button2)
ne.styleDisabled = clone(styles.down)
ne.styleNormal.font = styles.time.font
ne.styleNormal.fontsize = styles.time.fontsize
ne.styleActive.font = styles.time.font
ne.styleActive.fontsize = styles.time.fontsize
ne.styleDisabled.font = styles.time.font
ne.styleDisabled.fontsize = styles.time.fontsize
ne.useDuration = true
ne.geo.w = 100
ne.geo.h = 20
ne.geo.an = 4
ne.responder['resize'] = function(self)
		self.visible = player.geo.refWidth >= 375
        self.geo.x = player.geo.refLeft + 50
        self.geo.y = player.geo.refY2
        self:setPos()
        self:setHitBox()
    end
ne.responder['time'] = function(self)
		local str = {}
        if player.timePos then
            str[1] = mp.format_time(player.timePos)
        else
            str[1] = '--:--:--'
        end
        
        str[2] = "/"
        
        local val
		if self.useDuration then
            val = player.duration
        else
            val = -player.timeRem
        end
		if val then
            str[3] = mp.format_time(val)
        else
            str[3] = '--:--:--'
        end
        
        self.pack[4] = table.concat(str)
    end
ne.responder['mbtn_left_up'] = function(self, pos)
        if self:isInside(pos) then
            self.useDuration = not self.useDuration
            return true
        end
        return false
    end
ne:init()
addToPlayLayout('time')

-- seekbar
ne = newElement('seekbar', 'slider')
ne.layer = 30
ne.handleSize = 3
ne.style1 = styles.seekbarF
ne.style2 = styles.seekbarB
ne.style3 = styles.seekbarH
ne.responder['resize'] = function(self)
        self.geo.x = player.geo.refLeft + 10
        self.geo.y = player.geo.refY + 10
        self.geo.w = player.geo.refWidth - 20
        self.geo.h = 10
        self.geo.an = 4
        self:setParam()
        self:setPos()
        self:render()
    end
ne.responder['time'] = function(self)
        local val = player.percentPos
        if val then
            self.value = val
            self.xValue = val/100 * self.xLength
            self:render2()
        end
        return false
    end
ne.responder['file-loaded'] = function(self)
        -- update chapter markers
        self.markers = {}
        if player.duration then
            for i, v in ipairs(player.chapters) do
                self.markers[i] = (v.time / player.duration)
            end
            self:render()
        end
        return false
    end
ne.responder['mouse_move'] = function(self, pos)
        if not self.visible then return false end
        local seekTo = self:getValueAt(pos)
        if self.allowDrag then
            mp.commandv('seek', seekTo, 'absolute-percent')
            self.active = true
        end
        if self:isInside(pos) then
            local tipText
            if player.duration then
                local seconds = seekTo/100 * player.duration
                if #player.chapters > 0 then
                    local ch = #player.chapters
                    for i, v in ipairs(player.chapters) do
                        if seconds < v.time then
                            ch = i - 1
                            break
                        end
                    end
                    if ch == 0 then
                        tipText = string.format('[0/%d][unknown]\\N%s',
                            #player.chapters, mp.format_time(seconds))
                    else
                        local title = player.chapters[ch].title
                        if not title then title = 'unknown' end
                        tipText = string.format('[%d/%d][%s]\\N%s',
                            ch, #player.chapters, title,
                            mp.format_time(seconds))
                    end
                else
                    tipText = mp.format_time(seconds)
                end
            else
                tipText = '--:--:--'
            end
            tooltip:show(tipText, {pos[1], self.geo.y}, self)
            self.active = true
            return true
        elseif not self.allowDrag then
            tooltip:hide(self)
            self.active = false
            return false
        end
    end
ne.responder['mbtn_left_down'] = function(self, pos)
        if not self.visible then return false end
        if self:isInside(pos) then
            self.allowDrag = true
            local seekTo = self:getValueAt(pos)
            if seekTo then
                mp.commandv('seek', seekTo, 'absolute-percent')
                return true
            end
        end
        return false
    end
ne.responder['mbtn_left_up'] = function(self, pos)
        if self.allowDrag then
            self.allowDrag = false
            self.lastSeek = nil
            return true
        end
    end
ne:init()
addToPlayLayout('seekbar')

-- volume bar
ne = newElement('volumeBar', 'slider')
ne.layer = 30
ne.handleSize = 2
ne.style1 = styles.button
ne.style2 = styles.seekbarB
ne.style3 = styles.seekbarH
ne.responder['resize'] = function(self)
		self.visible = player.geo.refWidth >= 265
        self.geo.x = player.geo.refRight - 40
        self.geo.y = player.geo.refY2
        self.geo.w = 50
        self.geo.h = 6
        self.geo.an = 6
        self:setParam()
        self:setPos()
        self:render()
    end
ne.responder['volume'] = function(self)
        local val = player.volume
        if val then
            if val > 140 then val = 140
                elseif val < 0 then val = 0 end
            self.value = val/1.4
            self.xValue = val/140 * self.xLength
            self:render2()
        end
        return false
    end
ne.responder['mouse_move'] = function(self, pos)
        if not self.visible then return false end
        local vol = self:getValueAt(pos)
        if self.allowDrag and vol then
			mp.commandv('set', 'volume', vol*1.4)
			self.active = true
        end
        if self:isInside(pos) then
            local tipText
            if vol then
                tipText = string.format('%d', vol*1.4)
            else
                tipText = 'N/A'
            end
            -- tooltip:show(tipText, {pos[1], self.geo.y}, self)
            self.active = true
            return true
        elseif not self.allowDrag then
            -- tooltip:hide(self)
            self.active = false
            return false
        end
    end
ne.responder['mbtn_left_down'] = function(self, pos)
        if not self.visible then return false end
        if self:isInside(pos) then
            self.allowDrag = true
            local vol = self:getValueAt(pos)
            if vol then
                mp.commandv('set', 'volume', vol*1.4)
                return true
            end
        end
        return false
    end
ne.responder['mbtn_left_up'] = function(self, pos)
        if self.allowDrag then
            self.allowDrag = false
            self.lastSeek = nil
            return true
        end
    end
ne:init()
addToPlayLayout('volumeBar')


-- toggle fullscreen
ne = newElement('btnFullscreen', 'button')
ne.layer = 20
ne.styleNormal = styles.button
ne.styleActive = styles.button2
ne.styleDisabled = styles.down
ne.geo.an = 5
ne.geo.w = 20
ne.geo.h = 20
ne.responder['resize'] = function(self)
		self.visible = player.geo.refWidth >= 125
        self.geo.x = player.geo.refRight - 15
        self.geo.y = player.geo.refY2
        self:setPos()
        self:setHitBox()
    end
ne.responder['mbtn_left_up'] = function(self, pos)
        if self.enabled and self.visible and self:isInside(pos) then
            mp.commandv('cycle', 'fullscreen')
            return true
        end
        return false
    end
ne.responder['fullscreen'] = function(self)
        if player.fullscreen then
            self.text = '{\\fscx125\\fscy125}\xee\x84\x89'
        else
            self.text = '{\\fscx125\\fscy125}\xee\x84\x88'
        end
        self:render()
    end
ne:init()
addToPlayLayout('btnFullscreen')

-- cycle audio
ne = newElement('btnAudio', 'button')
ne.layer = 20
ne.styleNormal = styles.button
ne.styleActive = styles.button2
ne.styleDisabled = styles.down
ne.geo.an = 5
ne.geo.w = 20
ne.geo.h = 20
ne.text = '\xee\x84\x86'
ne.responder['resize'] = function(self)
		self.visible = player.geo.refWidth >= 125
        self.geo.x = player.geo.refLeft + 15
        self.geo.y = player.geo.refY2 -1
        self:setPos()
        self:setHitBox()
    end
ne.responder['file-loaded'] = function(self)
        if #player.tracks.audio > 1 then
            self:enable()
        else
            self:disable()
        end
        return false
    end
ne.responder['mbtn_left_up'] = function(self, pos)
        if self.visible and self.enabled and self:isInside(pos) then
            cycleTrack('audio', nil, 1)
            return true
        end
        return false
    end
ne.responder['mbtn_right_up'] = function(self, pos)
        if self.visible and self.enabled and self:isInside(pos) then
            cycleTrack('audio', 'prev', 1)
            return true
        end
        return false
    end
ne.responder['audio-changed'] = function(self)
        if player.tracks then
            local lang, title = nil, nil
            if player.audioTrack > 0 then
                lang = player.tracks.audio[player.audioTrack].lang
                title = player.tracks.audio[player.audioTrack].title
            end
            if lang then lang = '[' .. lang .. ']' else lang = '' end
            if title then title = '[' .. title .. ']' else title = '' end
            self.tipText = string.format('[%s/%s]%s%s', player.audioTrack, #player.tracks.audio, lang, title)
            tooltip:update(self.tipText, self)
        end
        return false
    end
ne.responder['mouse_move'] = function(self, pos)
        if not self.visible or not self.enabled then return false end
        local check = self:isInside(pos)
        if check and not self.active then
            self.active = true
            self.style = self.styleActive
            self:setStyle()
            tooltip:show(self.tipText, {self.geo.x-10, self.geo.y+10, 7}, self)
        elseif not check and self.active then
            self.active = false
            self.style = self.styleNormal
            self:setStyle()
            tooltip:hide(self)
        end
        return false
    end
ne:init()
addToPlayLayout('btnAudio')


-- cycle sub
ne = newElement('btnSub', 'button')
ne.layer = 20
ne.styleNormal = styles.button
ne.styleActive = styles.button2
ne.styleDisabled = styles.down
ne.geo.an = 5
ne.geo.w = 20
ne.geo.h = 20
ne.text = '\xee\x84\x87'
ne.responder['resize'] = function(self)
		self.visible = player.geo.refWidth >= 170
        self.geo.x = player.geo.refLeft + 35
        self.geo.y = player.geo.refY2 - 1
        self:setPos()
        self:setHitBox()
    end
ne.responder['file-loaded'] = function(self)
        if #player.tracks.sub > 0 then
            self:enable()
        else
            self:disable()
        end
        return false
    end
ne.responder['mbtn_left_up'] = function(self, pos)
        if self.visible and self.enabled and self:isInside(pos) then
            cycleTrack('sub')
            return true
        end
        return false
    end
ne.responder['mbtn_right_up'] = function(self, pos)
        if self.visible and self.enabled and self:isInside(pos) then
            cycleTrack('sub', 'prev')
            return true
        end
        return false
    end
ne.responder['sub-changed'] = function(self)
        if player.tracks then
            local lang, title = nil, nil
            if player.subTrack > 0 then
                lang = player.tracks.sub[player.subTrack].lang
                title = player.tracks.sub[player.subTrack].title
            end
            if lang then lang = '[' .. lang .. ']' else lang = '' end
            if title then title = '[' .. title .. ']' else title = '' end
            self.tipText = string.format('[%s/%s]%s%s', player.subTrack, #player.tracks.sub, lang, title)
            tooltip:update(self.tipText, self)
        end
        return false
    end
ne.responder['mouse_move'] = function(self, pos)
        if not self.visible or not self.enabled then return false end
        local check = self:isInside(pos)
        if check and not self.active then
            self.active = true
            self.style = self.styleActive
            self:setStyle()
            tooltip:show(self.tipText, {self.geo.x-10, self.geo.y+10, 7}, self)
        elseif not check and self.active then
            self.active = false
            self.style = self.styleNormal
            self:setStyle()
            tooltip:hide(self)
        end
        return false
    end
ne:init()
addToPlayLayout('btnSub')

-- previous file button
ne = newElement('btnPrev', 'button')
ne.layer = 20
ne.styleNormal = styles.button
ne.styleActive = styles.button2
ne.styleDisabled = styles.down
ne.geo.an = 5
ne.geo.w = 20
ne.geo.h = 20
ne.render = function(self)
        local s, w = 10, 2
        local ass = assdraw.ass_new()
        ass:draw_start()
        -- rect
        ass:rect_cw(0, s*0.1, w, s*0.9)
        -- triangle1
        ass:move_to(w+1, s/2)
        ass:line_to(s, 0)
        ass:line_to(s, s)
        ass:line_to(w+1, s/2)
        ass:draw_stop()
        self.pack[4] = ass.text
    end
ne.responder['resize'] = function(self)
		self.visible = player.geo.refWidth >= 70
        self.geo.x = player.geo.refX - 30
        self.geo.y = player.geo.refY2
        self:setPos()
        self:setHitBox()
    end
ne.responder['file-loaded'] = function(self)
        if not player.playlist then return false end
        if player.playlistPos <= 1 and player.loopPlaylist == 'no' then
            self:disable()
        else
            self:enable()
        end
        return false
    end
ne.responder['loop-playlist'] = ne.responder['file-loaded']
ne.responder['mbtn_left_up'] = function(self, pos)
        if self.enabled and self.visible and self:isInside(pos) then
            mp.commandv('playlist-prev', 'weak')
            return true
        end
        return false
    end
ne:init()
addToPlayLayout('btnPrev')

-- next file button
ne = newElement('btnNext', 'button')
ne.layer = 20
ne.styleNormal = styles.button
ne.styleActive = styles.button2
ne.styleDisabled = styles.down
ne.geo.an = 5
ne.geo.w = 20
ne.geo.h = 20
ne.render = function(self)
        local s, w = 10, 2
        local ass = assdraw.ass_new()
        ass:draw_start()
        -- rect
        ass:rect_cw(s-w, s*0.1, s, s*0.9)
        -- triangle1
        ass:move_to(0, 0)
        ass:line_to(s-w-1, s/2)
        ass:line_to(0, s)
        ass:line_to(0, 0)
        ass:draw_stop()
        self.pack[4] = ass.text
    end
ne.responder['resize'] = function(self)
        self.visible = player.geo.refWidth >= 70
        self.geo.x = player.geo.refX + 30
        self.geo.y = player.geo.refY2
        self:setPos()
        self:setHitBox()
    end
ne.responder['file-loaded'] = function(self)
        if not player.playlist then return false end
        if player.playlistPos >= #player.playlist
            and player.loopPlaylist == 'no' then
            self:disable()
        else
            self:enable()
        end
        return false
    end
ne.responder['loop-playlist'] = ne.responder['file-loaded']
ne.responder['mbtn_left_up'] = function(self, pos)
        if self.enabled and self.visible and self:isInside(pos) then
            mp.commandv('playlist-next', 'weak')
            return true
        end
        return false
    end
ne:init()
addToPlayLayout('btnNext')

-- close button on title bar
ne = newElement('winClose', 'button')
ne.layer = 20
ne.geo.w = 20
ne.geo.h = 20
ne.geo.an = 5
ne.styleNormal = styles.top1
ne.styleActive = styles.top2
ne.styleDisabled = nil
ne.text = '\238\132\149'
ne.responder['resize'] = function(self)
        self.geo.x = player.geo.width - 20
        self.geo.y = 12
        self:setPos()
        self:setHitBox()
        return false
    end
ne.responder['fullscreen'] = function(self)
        self.visible = player.fullscreen
        return false
    end
ne.responder['mbtn_left_up'] = function(self, pos)
        if self.visible and self:isInside(pos) then
            mp.commandv('quit')
        end
        return false
    end
ne:init()
addToPlayLayout('winClose')

-- max/restore button on title bar
ne = newElement('winMax', 'winClose')
ne.responder['resize'] = function(self)
        self.geo.x = player.geo.width - 50
        self.geo.y = 12
        if player.fullscreen then
            self.text = '\238\132\148'
        else
            self.text = '\238\132\147'
        end
        self:render()
        self:setPos()
        self:setHitBox()
        return false
    end
ne.responder['mbtn_left_up'] = function(self, pos)
        if self:isInside(pos) then
            mp.commandv('cycle', 'fullscreen')
            return true
        end
        return false
    end
ne:init()
addToPlayLayout('winMax')

-- minimize button
ne = newElement('winMin', 'winClose')
ne.text = '\238\132\146'
ne.responder['resize'] = function(self)
        self.geo.x = player.geo.width - 75
        self.geo.y = 12
        self:setPos()
        self:setHitBox()
        return false
    end
ne.responder['mbtn_left_up'] = function(self, pos)
        if self:isInside(pos) then
            mp.commandv('cycle', 'window-minimized')
            return true
        end
        return false
    end
ne:init()
addToPlayLayout('winMin')
