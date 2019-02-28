---=====================================
---stagegroup|replay|pausemenu system
---extra game loop
---=====================================

----------------------------------------
---ext加强库

---@class ext @额外游戏循环加强库
ext={}

local extpath="Thlib\\ext\\"

DoFile(extpath.."ext_pause_menu.lua")--暂停菜单和暂停菜单资源
DoFile(extpath.."ext_replay.lua")--CHU爷爷的replay系统以及切关函数重载
DoFile(extpath.."ext_stage_group.lua")--关卡组

ext.replayTicker=0--控制录像播放速度时有用
ext.slowTicker=0--控制时缓的变量
ext.time_slow_level={1, 2, 3, 4}--60/30/20/15 4个程度
ext.pause_menu=ext.pausemenu()--实例化的暂停菜单对象，允许运行时动态更改样式

---重置缓速计数器
function ext.ResetTicker()
	ext.replayTicker=0
	ext.slowTicker=0
end

---获取暂停菜单发送的命令
---@return string
function ext.GetPauseMenuOrder()
	return ext.pause_menu_order
end

---发送暂停菜单的命令，命令有以下类型：
---'Continue'
---'Return to Title'
---'Quit and Save Replay'
---'Give up and Retry'
---'Restart'
---'Replay Again'
---@param msg string
function ext.PushPauseMenuOrder(msg)
	ext.pause_menu_order=msg
end

----------------------------------------
---extra user function

function GameStateChange() end

---设置标题
function ChangeGameTitle()
	local title=""
	if #setting.mod<=0 then
		title="Luastg Ex Plus 0.81b"
	else
		title=setting.mod
	end
	title=title..string.format(" | FPS=%.1f",GetFPS())
	title=title..' | Objects='..GetnObj()
	if jstg.network.status>0 then
		title=title..' | '..jstg.NETSTATES[jstg.network.status]
		if jstg.network.status>4 then
			title=title..'('..jstg.network.delay..')'
		end
	end
	SetTitle(title)
end

---切关处理
function ChangeGameStage()
	jstg.ResetWorlds()--by ETC，重置所有world参数
	ResetWorldOffset()--by ETC，重置world偏移
	
	lstg.ResetLstgtmpvar()--重置lstg.tmpvar
	ex.Reset()--重置ex全局变量
	
	if lstg.nextvar then
		lstg.var=lstg.nextvar
		lstg.nextvar =nil
	end
	
	-- 初始化随机数
	if lstg.var.ran_seed then
		--Print('RanSeed',lstg.var.ran_seed)
		ran:Seed(lstg.var.ran_seed)
	end
	
	--刷新最高分
	if not stage.next_stage.is_menu then
		if scoredata.hiscore == nil then
			scoredata.hiscore = {}
		end
		lstg.tmpvar.hiscore = scoredata.hiscore[stage.next_stage.stage_name..'@'..tostring(lstg.var.player_name)]
	end
	
	jstg.enable_player=false
	
	--切换关卡
	stage.current_stage=stage.next_stage
	stage.next_stage=nil
	stage.current_stage.timer=0
	stage.current_stage:init()
	
	if not jstg.enable_player then
		jstg.Compatible()--创建自机，支持旧版本mod
	end
	
	RunSystem('on_stage_init')
end

---获取输入（ex+中不使用）
function GetInput()
	if stage.next_stage then
		KeyStatePre = {}
	else
		-- 刷新KeyStatePre
		for k, _ in pairs(setting.keys) do
			KeyStatePre[k] = KeyState[k]
		end
	end
	
	-- 不是录像时更新按键状态
	if not ext.replay.IsReplay() then
		for k,v in pairs(setting.keys) do
			KeyState[k] = GetKeyState(v)
		end
	end
	
	if ext.replay.IsRecording() then
		-- 录像模式下记录当前帧的按键
		replayWriter:Record(KeyState)
	elseif ext.replay.IsReplay() then
		-- 回放时载入按键状态
		replayReader:Next(KeyState)
	end
end

---行为帧动作(和游戏循环的帧更新分开)
function DoFrame()
	--标题设置
	ChangeGameTitle()
	--切关处理
	if stage.next_stage then ChangeGameStage() end
	--刷新输入
	jstg.GetInputEx()
	--stage和object逻辑
	SetPlayer()--清除jstg.current_player指向的自机
	if GetCurrentSuperPause()<=0 or stage.nopause then
		ex.Frame()
		task.Do(stage.current_stage)
		stage.current_stage:frame()
		stage.current_stage.timer=stage.current_stage.timer+1
	end
	ObjFrame()
	if GetCurrentSuperPause()<=0 or stage.nopause then
		for i=1,jstg.GetWorldCount() do
			jstg.SwitchWorld(i)
			SetWorldFlag(jstg.worlds[i].world)
			BoundCheck()
		end
	end
	if GetCurrentSuperPause()<=0 then
		CollisionCheck(GROUP_PLAYER,GROUP_ENEMY_BULLET)
		CollisionCheck(GROUP_PLAYER,GROUP_ENEMY)
		CollisionCheck(GROUP_PLAYER,GROUP_INDES)
		CollisionCheck(GROUP_ENEMY,GROUP_PLAYER_BULLET)
		CollisionCheck(GROUP_NONTJT,GROUP_PLAYER_BULLET)
		CollisionCheck(GROUP_ITEM,GROUP_PLAYER)
		--由OLC添加，可用于自机bomb
		CollisionCheck(GROUP_SPELL,GROUP_ENEMY)
		CollisionCheck(GROUP_SPELL,GROUP_NONTJT)
		CollisionCheck(GROUP_SPELL,GROUP_ENEMY_BULLET)
		CollisionCheck(GROUP_SPELL,GROUP_INDES)
	end
	UpdateXY()
	AfterFrame()
	--切关时清空资源和回收对象
	if stage.next_stage and stage.current_stage then
		stage.current_stage:del()
		task.Clear(stage.current_stage)
		if stage.preserve_res then
			stage.preserve_res=nil
		else
			RemoveResource'stage'
		end
		ResetPool()
	end
end

---缓速和加速
function DoFrameEx()
	if ext.replay.IsReplay() then
		--播放录像时
		ext.replayTicker = ext.replayTicker + 1
		ext.slowTicker = ext.slowTicker + 1
		if GetKeyState(setting.keysys.repfast) then
			for _=1,4 do
				DoFrame(true, false)
				ext.pause_menu_order = nil
			end
		elseif GetKeyState(setting.keysys.repslow) then
			if ext.replayTicker % 4 == 0 then
				DoFrame(true, false)
				ext.pause_menu_order = nil
			end
		else
			if lstg.var.timeslow then
				local tmp=min(4,max(1,lstg.var.timeslow))
				if ext.slowTicker%(ext.time_slow_level[tmp])==0 then
					DoFrame(true, false)
				end
			else
				DoFrame(true, false)
			end
			ext.pause_menu_order = nil
		end
	else
		--正常游戏时
		ext.slowTicker=ext.slowTicker+1
		if lstg.var.timeslow and lstg.var.timeslow>0 then
			local tmp=min(4,max(1,lstg.var.timeslow))
			if ext.slowTicker%(ext.time_slow_level[tmp])==0 then
				DoFrame(true, false)
			end
		else
			DoFrame(true, false)
		end
	end
end

function BeforeRender() end

function AfterRender()
	--暂停菜单渲染
	local state=0
	ext.pause_menu:render()
end

function GameExit() end

----------------------------------------
---extra game call-back function

function FrameFunc()
	if jstg then jstg.ProceedConnect() end--刷新网络状态
	boss_ui.active_count=0--重设boss ui的槽位（多boss支持）
	if GetLastKey() == setting.keysys.snapshot and setting.allowsnapshot then
		Snapshot('snapshot\\'..os.date("!%Y-%m-%d-%H-%M-%S", os.time() + setting.timezone * 3600)..'.png')--支持时区
	end
	--执行场景逻辑
	if ext.pause_menu:IsKilled() then
		--处理录像速度与正常更新逻辑
		DoFrameEx()
		--按键弹出菜单
		if (GetLastKey() == setting.keysys.menu or ext.pop_pause_menu) and (not stage.current_stage.is_menu) then
			ext.pause_menu:FlyIn()
		end
	else
		--暂停菜单部分
		--仍然需要更新输入
		jstg.GetInputEx(true)
	end
	--暂停菜单更新
	ext.pause_menu:frame()
	--退出游戏逻辑
	if lstg.quit_flag then
		GameExit()
	end
	return lstg.quit_flag
end

function RenderFunc()
	BeginScene()
	SetWorldFlag(1)
	BeforeRender()
	if stage.current_stage.timer and stage.current_stage.timer >= 0 and stage.next_stage == nil then
		stage.current_stage:render()
		for i=1,jstg.GetWorldCount() do
			jstg.SwitchWorld(i)
			SetWorldFlag(jstg.worlds[i].world)
			ObjRender()
			SetViewMode('world')
			DrawCollider()
		end
		if Collision_Checker then
			Collision_Checker.render()
		end
		if not stage.current_stage.is_menu then RunSystem("on_stage_render") end
	end
	AfterRender()
	EndScene()
end

function FocusLoseFunc()
	if ext.pause_menu==nil and stage.current_stage and jstg.network.status==0 then
		if not stage.current_stage.is_menu then
			ext.pop_pause_menu=true
		end
	end
end
