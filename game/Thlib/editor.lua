--======================================
--编辑器接口
--======================================

_editor_class={}
_editor_cards={}
_editor_tasks={}
_sc_table={}
_infinite=4294967296

----------------------------------------
--编辑器object

_object=Class(object)
function _object:frame()
	if self.hp<=0 then Kill(self) end
	task.Do(self)
	if self.dmgt then self.dmgt = max(0, self.dmgt - 1) end
end
function _object:render()
	local c = 0
	if self.dmgt and self.dmgmaxt then
		c = self.dmgt / self.dmgmaxt
	end
	SetImgState(self, self._blend, self._a, self._r - self._r * 0.75 * c, self._g - self._g * 0.75 * c, self._b)
	DefaultRenderFunc(self)
end
function _object:set_color(blend,a,r,g,b)
	self._blend,self._a,self._r,self._g,self._b=blend,a,r,g,b
end
function _object:take_damage(dmg)
	if self.dmgmaxt then self.dmgt = self.dmgmaxt end
	self.hp=self.hp-dmg
end
function _object:colli(other)
	if self.group==GROUP_ENEMY or self.group==GROUP_NONTJT then--修复了无体术组的问题
		if other.dmg then
			lstg.var.score=lstg.var.score+10
			Damage(self,other.dmg)
			if self._master and self._dmg_transfer and IsValid(self._master) then
				Damage(self._master,other.dmg*self._dmg_transfer)
			end
		end
		other.killerenemy=self
		if not(other.killflag) then
			Kill(other)
		end
		if not other.mute then
			if self.dmg_factor then
				if self.hp>100 then PlaySound('damage00',0.4,self.x/200)
				else PlaySound('damage01',0.6,self.x/200) end
			else
				if self.hp>60 then
					if self.hp>self.maxhp*0.2 then PlaySound('damage00',0.4,self.x/200)
					else PlaySound('damage01',0.6,self.x/200) end
				else PlaySound('damage00',0.35,self.x/200,true)
				end
			end
		end
	end
end
function _object:del()
	if ParticleGetn(self)>0 then misc.KeepParticle(self) end
	_del_servants(self)
	if not self.hide then
		New(bubble3,self.img,self.x,self.y,self.rot,self.dx,self.dy,self.omiga,15,self.hscale,self.hscale,
			Color(self._a,self._r,self._g,self._b),Color(0,self._r,self._g,self._b),self.layer,self._blend)
	end
end
function _object:kill()
	if ParticleGetn(self)>0 then misc.KeepParticle(self) end
	_kill_servants(self)
	if not self.hide then
		New(bubble3,self.img,self.x,self.y,self.rot,self.dx,self.dy,self.omiga,15,self.hscale,self.hscale,
			Color(self._a,self._r,self._g,self._b),Color(0,self._r,self._g,self._b),self.layer,self._blend)
	end
end

--消亡特效（渐隐）
bubble3=Class(object)
function bubble3:init(img,x,y,rot,vx,vy,omiga,life_time,size1,size2,color1,color2,layer,blend)
	self.img=img
	self.x=x
	self.y=y
	self.rot=rot
	self.vx=vx
	self.vy=vy
	self.omiga=omiga
	self.group=GROUP_GHOST
	self.life_time=life_time
	self.size1=size1
	self.size2=size2
	self.color1=color1
	self.color2=color2
	self.layer=layer
	self.blend=blend or ''
end
function bubble3:render()
	local t=(self.life_time-self.timer)/self.life_time
	self.hscale=self.size1*t+self.size2*(1-t)
	self.vscale=self.hscale
	local c=self.color1*t+self.color2*(1-t)
	SetImgState(self,self.blend,c:ARGB())
	DefaultRenderFunc(self)
end
function bubble3:frame()
	if self.timer==self.life_time-1 then Del(self) end
end

----------------------------------------
--编辑器task方法

--和core的task.Wait不一样，这个可以填0进去，执行wait次数也可以为0
function task._Wait(t)
	t=t or 0
	t=max(0,int(t))
	for i=1,t do coroutine.yield() end
end

----------------------------------------
--单位管理

function _kill(unit,trigger)
	if IsValid(unit[1]) then
		for i=1,#unit do
			if trigger then Kill(unit[i]) else RawKill(unit[i]) end
		end
		return
	end
	if trigger then Kill(unit) else RawKill(unit) end
end
function _del(unit,trigger)
	if IsValid(unit[1]) then
		for i=1,#unit do
			if trigger then Del(unit[i]) else RawDel(unit[i]) end
		end
		return
	end
	if trigger then Del(unit) else RawDel(unit) end
end

function RawSetA(self, accel, angle, navi, maxv)--!警告：RawSetA为实验性功能，和SetA冲突，有潜在的兼容性问题
	self.ax=accel*cos(angle)
	self.ay=accel*sin(angle)
	if self.acceleration then
		--self.acceleration=nil--两套加速度更新逻辑不能相容，使用底层的加速度更新时，加速度+重力系统需要关闭
	end
	if navi then self.navi = navi end
	if maxv~=0 then
		self.forbidveloc={v=maxv}
	end
end
function SetA(self,accel,angle,maxv,gravity,maxvy,navi)--!警告：和RawSetA冲突
	--self.ax,self.ay=0,0--两套加速度更新逻辑不能相容,使用加速度+重力的一套时，底层的加速度更新需要关闭
	self.navi = navi
	if accel~=0 then
		self.acceleration={ax=accel*cos(angle),ay=accel*sin(angle)}
	end
	if gravity~=0 then
		self.acceleration = self.acceleration or {}
		self.acceleration.g = gravity
	end
	if maxv~=0 then
		self.forbidveloc={v=maxv}
	end
	if maxvy~=0 then
		self.forbidveloc = self.forbidveloc or {}
		self.forbidveloc.vy = maxvy
	end
end
function _set_a(obj,a,rot,aim)--！潜在的问题：多玩家适配
	if rot == "original" then rot = atan2(obj.vy, obj.vx) end
	if aim then rot = rot + Angle(obj,Player(obj)) end
	obj.acceleration = obj.acceleration or {}
	local accel = obj.acceleration
	accel.ax = a * cos(rot)
	accel.ay = a * sin(rot)
end
function _set_g(obj,g)
	obj.acceleration = obj.acceleration or {}
	obj.acceleration.g = g
end
function _forbid_v(obj, v, vx, vy)
	obj.forbidveloc = obj.forbidveloc or {}
	local fv = obj.forbidveloc
	if v ~= "original" then
		fv.v = v
	end
	if vx ~= "original" then
		fv.vx = vx
	end
	if vy ~= "original" then
		fv.vy = vy
	end
end
function GetA(obj)
	local acc = {}
	if obj.acceleration then acc = obj.acceleration end
	return acc.ax or 0, acc.ay or 0
end
function GetG(obj)
	local acc = {}
	if obj.acceleration then acc = obj.acceleration end
	return acc.g
end
function GetFV(obj)
	local fv = {}
	if obj.forbidveloc then fv = obj.forbidveloc end
	return fv.v or 0, fv.vx or 0, fv.vy or 0
end

_can_be_master={[_object]=true,[enemy]=true,[boss]=true,[laser]=true,[bullet]=true}--没用上？？
function _connect(master,servant,dmg_transfer,con_death)
	if IsValid(master) and IsValid(servant) then
		if con_death then
			master._servants = master._servants or {}
			table.insert(master._servants,servant)
		end
		servant._master=master
		servant._dmg_transfer=dmg_transfer
	end
end
function _set_rel_pos(servant,x,y,rot,follow_rot)
	if servant._master and IsValid(servant._master) then
		local master=servant._master
		if follow_rot then
			x,y=x*cos(master.rot)-y*sin(master.rot),x*sin(master.rot)+y*cos(master.rot)
			rot=rot+master.rot
		end
		servant.x=master.x+x
		servant.y=master.y+y
		servant.rot=rot
	end
end
function _kill_servants(master)
	for k,v in pairs(master._servants) do if IsValid(v) then Kill(v) end end
	master._servants={}
end
function _del_servants(master)
	for k,v in pairs(master._servants) do if IsValid(v) then Del(v) end end
	master._servants={}
end

----------------------------------------
--编辑器bullet
--！潜在的问题：多玩家适配

_straight=Class(bullet)
function _straight:init(imgclass,index,x,y,v,angle,aim,omiga,stay,destroyable,time,_495,accel,accangle,maxv,through)
	self.x=x self.y=y
	time = time or 0
	self.rot = angle
	if aim then self.rot = self.rot + Angle(self,_Player(self)) end
	self.omiga=omiga
	if accangle=='original' then accangle = self.rot end
	bullet.init(self,imgclass,index,stay,destroyable)
	if time and time ~= 0 then
		New(tasker, function()
			task.Wait(time)
			if IsValid(self) then
				SetV2(self,v,self.rot,true,false)
				if accel then SetA(self,accel,accangle,maxv,0,0,false) end
			end
		end)
	else
		SetV2(self,v,self.rot,true)
		if accel then SetA(self,accel,accangle,maxv,0,0,false) end
	end
	self._495 = _495
	self.through = through
end
function _straight:frame()
	if self.through then
		local w=lstg.world
		if self.y > w.t then self.y = self.y - (2*w.t) self.through = nil end
		if self.y < w.b then self.y = self.y + (2*w.t) self.through = nil end
		if self.x > w.r then self.x = self.x - (2*w.r) self.through = nil end
		if self.x < w.l then self.x = self.x + (2*w.r) self.through = nil end
	end
	if self._495 and not self.reflected then
		straight_495.frame(self)
	else
		bullet.frame(self)
	end
end

function _create_bullet_group(style,color,x,y,n,t,v1,v2,angle,da,aim,omiga,stay,des,time,_495,enemy)
	local unitlist={}
	local p=_Player(GetCurrentObject())
	if n>=1 then
		--间隔为0直接一次创建并返回一个表
		if t==0 then
			local dv=(v2-v1)/n
			local da=da/n
			angle=angle+da*(-n/2+0.5)
			v1=v1+dv*0.5
			if aim then angle=angle+Angle(x,y,p.x,p.y) end
			for i=0,n-1 do
				local last1=New(_straight,style,color,x,y,v1+dv*i,angle+da*i,false,omiga,stay,des,time,_495)
				ex.UnitListAppend(unitlist,last1)
			end
			last=unitlist
			return unitlist
		end
		--间隔不为0则创建发射器
		New(_bullet_shooter,function()
			local dv=(v2-v1)/n
			local da=da/n
			angle=angle+da*(-n/2+0.5)
			v1=v1+dv*0.5
			if aim then angle=angle+Angle(x,y,p.x,p.y) end
			for i=0,n-1 do
				local last1=New(_straight,style,color,x,y,v1+dv*i,angle+da*i,false,omiga,stay,des,time,_495)
				ex.UnitListAppend(unitlist,last1)
				task._Wait(t)
			end
		end,enemy)
	end
	last=unitlist
	return unitlist
end

_bullet_shooter=Class(object)
function _bullet_shooter:init(f,enemy)
	self.group=GROUP_GHOST
	self.hide=true
	self.enemy=enemy
	task.New(self,f)
end
function _bullet_shooter:frame()
	if not (IsValid(self.enemy) or self.enemy==stage.current_stage) then
		Del(self)
	else
		task.Do(self)
		if coroutine.status(self.task[1])=='dead' then Del(self) end
	end
end

function _clear_bullet(convert,clear_indes)
	local w=Players()
	for i=1,#w do
		local p=w[i]
		if convert then New(bullet_killer,p.x,p.y,clear_indes)
		else New(bullet_deleter,p.x,p.y,clear_indes) end
	end
end

bullet_cleaner = Class(object)
function bullet_cleaner:init(x,y,radius,time,time2,into,indes,v)
	self.x = x
	self.y = y
	if time == 0 then
		self.radius = radius
	else
		self.radius = 0
		self.delta = radius / time
	end
	self.time = time
	self.time2 = time2
	self.into = into
	self.indes = indes
	self.bound = false
	self.group = GROUP_PLAYER
	self.a = self.radius
	self.b = self.radius
	self.vy = v or 0.2
end
function bullet_cleaner:frame()
	if self.timer < self.time then
		self.radius = self.radius + self.delta
		self.a = self.radius
		self.b = self.radius
	end
	if self.timer > self.time2 then RawDel(self) end
end
function bullet_cleaner:colli(other)
	if other.group == GROUP_ENEMY_BULLET or (self.indes and other.group == GROUP_INDES) then
		if self.into then Kill(other) else Del(other) end
	end
end

----------------------------------------
--激光方法

function laser:_TurnOn(t,sound,wait)
	t=t or 30
	t=max(1,int(t))
	if sound then PlaySound('lazer00',0.25,self.x/200) end
	self.counter=t
	self.da=(1-self.alpha)/t
	self.dw=(self.w0-self.w)/t
	if task.GetSelf()==self and wait then task.Wait(t) end
end
function laser:_TurnHalfOn(t,wait)
	t=t or 30
	t=max(1,int(t))
	self.counter=t
	self.da=(0.5-self.alpha)/t
	self.dw=(0.5*self.w0-self.w)/t
	if task.GetSelf()==self and wait then task.Wait(t) end
end
function laser:_TurnOff(t,wait)
	t=t or 30
	t=max(1,int(t))
	self.counter=t
	self.da=-self.alpha/t
	self.dw=-self.w/t
	if task.GetSelf()==self and wait then task.Wait(t) end
end

----------------------------------------
--声音

function _play_music(name,ptime)
	local _,bgm=EnumRes('bgm')
	for _,v in pairs(bgm) do StopMusic(v) end
	PlayMusic(name,1.0,ptime)
end
function _pause_music()
	local _,bgm=EnumRes('bgm')
	for _,v in pairs(bgm) do PauseMusic(v) end
end
function _resume_music()
	local _,bgm=EnumRes('bgm')
	for _,v in pairs(bgm) do ResumeMusic(v) end
end
function _stop_music()
	local _,bgm=EnumRes('bgm')
	for _,v in pairs(bgm) do StopMusic(v) end
end

----------------------------------------
--游戏系统相关

function _drop_item(itemclass, num, x, y)
	local switch = {
		[item_power] = function()
			item.DropItem(x,y,{num,0,0})
		end,
		[item_faith] = function()
			item.DropItem(x,y,{0,num,0})
		end,
		[item_point] = function()
			item.DropItem(x,y,{0,0,num})
		end,
		[item_power_large] = function()
			for i=1,num do
				local r2=sqrt(ran:Float(1,4))*sqrt(num-1)*5
				local a=ran:Float(0,360)
				New(item_power_large,x+r2*cos(a),y+r2*sin(a))
			end
		end,
		[item_power_full] = function()
			for i=1,num do
				local r2=sqrt(ran:Float(1,4))*sqrt(num-1)*5
				local a=ran:Float(0,360)
				New(item_power_full,x+r2*cos(a),y+r2*sin(a))
			end
		end,
		[item_faith_minor] = function()
			for i=1,num do
				local r2=sqrt(ran:Float(1,4))*sqrt(num-1)*5
				local a=ran:Float(0,360)
				New(item_faith_minor,x+r2*cos(a),y+r2*sin(a))
			end
		end,
		[item_extend] = function()
			for i=1,num do
				local r2=sqrt(ran:Float(1,4))*sqrt(num-1)*5
				local a=ran:Float(0,360)
				New(item_extend,x+r2*cos(a),y+r2*sin(a))
			end
		end,
		[item_chip] = function()
			for i=1,num do
				local r2=sqrt(ran:Float(1,4))*sqrt(num-1)*5
				local a=ran:Float(0,360)
				New(item_chip,x+r2*cos(a),y+r2*sin(a))
			end
		end,
		[item_bombchip] = function()
			for i=1,num do
				local r2=sqrt(ran:Float(1,4))*sqrt(num-1)*5
				local a=ran:Float(0,360)
				New(item_bombchip,x+r2*cos(a),y+r2*sin(a))
			end
		end,
		[item_bomb] = function()
			for i=1,num do
				local r2=sqrt(ran:Float(1,4))*sqrt(num-1)*5
				local a=ran:Float(0,360)
				New(item_bomb,x+r2*cos(a),y+r2*sin(a))
			end
		end
	}
	switch[itemclass]()
end

function _init_item(self)--用于关卡开始时重置各个系统参数
	if lstg.var.is_practice then
		item.PlayerInit()
		if self.item_init then
			for k,v in pairs(self.item_init) do
				lstg.var[k]=v
			end
		end
	else
		if self.number==1 then
			item.PlayerInit()
			if self.group.item_init then
				for k,v in pairs(self.group.item_init) do
					lstg.var[k]=v
				end
			end
		end
	end
end

----------------------------------------
--资源加载

function _LoadImageFromFile(teximgname,filename,mipmap,a,b,rect,edge)
	LoadTexture(teximgname,filename,mipmap)
	local w,h=GetTextureSize(teximgname)
	LoadImage(teximgname,teximgname,edge,edge,w-edge*2,h-edge*2,a,b,rect)
end
function _LoadImageGroupFromFile(teximgname,filename,mipmap,r,l,a,b,rect)
	LoadTexture(teximgname,filename,mipmap)
	local w,h=GetTextureSize(teximgname)
	LoadImageGroup(teximgname,teximgname,0,0,w/r,h/l,r,l,a,b,rect)
end

local musicrecording = {}
function MusicRecord(name, path, loopend, looplength)
	musicrecording[name] = {path, loopend, looplength}
end
function LoadMusicRecord(name)
	--修改by OLC，阻止重复加载
	if type(musicrecording[name]) == "table" then
		if lstg.tmpvar.musiccache == nil then lstg.tmpvar.musiccache = {} end
		if not lstg.tmpvar.musiccache[name] then
			LoadMusic(name, unpack(musicrecording[name]))
			lstg.tmpvar.musiccache[name] = true
		end
	end
end

----------------------------------------
--拖影特效
--？细节：现有的拖影是通过HGE粒子特效来实现的，无法更改混合模式和颜色，无法更改大小和拖影长度

function MakeSmear(obj,length,interval,blend,color,size)
	if IsValid(obj) and ImageList[obj.img] then
		length = length or 10
		interval = interval or 1
		blend = blend or ''
		color = color or {255,255,255,255,0,255,255,255}
		--size = size or {1,0}
		New(smear,obj,length,interval,blend,color,size)
	else
		error("Invalid object or not a object with image")
	end
end

smear = Class(object)
smear.cache = {}
smear.func = function(img)--修改by OLC，修复了疯狂重复加载的问题
	if lstg.tmpvar.smearcache == nil then lstg.tmpvar.smearcache = {} end
	if not lstg.tmpvar.smearcache[img] then
		smear.cache[img] = img.."_smear_psi"
		lstg.tmpvar.smearcache[img] = img.."_smear_psi"
		LoadPS(img.."_smear_psi","THlib\\bullet\\smear.psi",img)
	end
	return lstg.tmpvar.smearcache[img]
end
function smear:init(obj,interval)
	self.master = obj
	self.emission = 60/(interval or 1)
	self.layer = obj.layer - 1
	self.bound = false
end
function smear:frame()
	if self.notframe then return end
	if not IsValid(self.master) then Kill(self) return end
	self.x = self.master.x
	self.y = self.master.y
	self.rot = self.master.rot
	if self.master.hide or not self.master.img then
		self.hide = true
	else
		self.hide = false
		self.img = smear.func(self.master.img)
		ParticleSetEmission(self,self.emission)
	end
end
function smear:kill()
	self.status = 'normal'
	self.notframe = true
	New(tasker, function()
		local m = ParticleGetEmission(self)
		while true do
			if m < 0 then break end
			ParticleSetEmission(self,m)
			m = m - 5
			task.Wait(1)
		end
		task.Wait(30)
		Del(self)
	end)
end

----------------------------------------
--阿基米德螺线 powered by 二要
--？细节：现有版本的编辑器不再提供该功能

Include'THlib\\bulletex\\Archimedes.lua'

archiexpand=Class(bullet)
function archiexpand:init(imgclass,color,destroyable,navi,auto,center,radius,angle,omiga,deltar)
	bullet.init(self,imgclass,color,true,destroyable)
	self.navi = navi and auto==0
	self.omiga = auto
	archimedes.expand.init(self,center,radius,angle,omiga,deltar)
end
function archiexpand:frame()
	bullet.frame(self)
	archimedes.expand.frame(self)
end

archirotate=Class(bullet)
function archirotate:init(imgclass,color,destroyable,navi,auto,center,radius,angle,omiga,time)
	bullet.init(self,imgclass,color,true,destroyable)
	self.navi = navi and auto==0
	self.omiga = auto
	archimedes.rotation.init(self,center,radius,angle,omiga,time)
end
function archirotate:frame()
	bullet.frame(self)
	archimedes.rotation.frame(self)
end

----------------------------------------
--bullet ex系统

Include("THlib\\bulletex\\Queue.lua")
Include("THlib\\bulletex\\Heap.lua")
Include("THlib\\bulletex\\List.lua")
Include("THlib\\bulletex\\Array.lua")
Include("THlib\\bulletex\\Class.lua")
Include("THlib\\bulletex\\BulletEx.lua")

RenderObject=Class(object)
function RenderObject:init(parent,image,x,y,rot,h,v,layer,tf)
	self.img = image
	self.x,self.y = x,y
	self.rot=rot
	self.hscale,self.vscale = h,v
	self.task = {}
	self.master = parent
	self.layer = layer
	tf(self)
end
function RenderObject:frame()
	if not IsValid(self.master) and stage.current_stage ~= self.master then
		Del(self)
		return
	end
	task.Do(self)
end
function RenderObject:render()
	if self._blend and self._a and self._r and self._g and self._b then
		SetImgState(self,self._blend,self._a,self._r,self._g,self._b)
	end
	DefaultRenderFunc(self)
	if self._blend and self._a and self._r and self._g and self._b then
		SetImgState(self,'',255,255,255,255)
	end
end

----------------------------------------
--迟早要干掉的反弹板
--！警告：SB反弹板会炸游戏，不要使用

rebounder = Class(object)
rebounder.list = {}
rebounder.size = 0
function rebounder:init(x,y,length,angle)
	self.x = x
	self.y = y
	self.length = length
	self.rot = angle
	self.last_rot = nil
	self.last_len = nil
	self.group = GROUP_GHOST
	self.colli = false
	self.id = rebounding.AddRebounder(x,y,length,angle)
	rebounder.list[self.id] = self
	rebounder.size = rebounder.size + 1
end
function rebounder:frame()
	if self.last_rot ~= self.rot or self.last_len ~= self.length or self.dx ~= 0 or self.dy ~= 0 then
		rebounding.UpdateRebounder(self.id, self.x, self.y, self.length, self.rot)
	end
	task.Do(self)
end
function rebounder:colli(obj)
	if obj.omiga == 0 and not obj.navi then obj.rot = self.rot * 2 - obj.rot end
end
function rebounder:kill()
	rebounding.ReleaseRebounder(self.id)
	rebounder.list[self.id] = nil
	rebounder.size = rebounder.size - 1
end
function rebounder:del()
	rebounding.ReleaseRebounder(self.id)
	rebounder.list[self.id] = nil
	rebounder.size = rebounder.size - 1
end
function PauseRebound()
	ReboundPause = true
end
function ResumeRebound()
	ReboundPause = false
end
function ClearRebound()
	ReboundPause = false
	for _,obj in pairs(rebounder.list) do Del(obj) end
	rebounder.list = {}
	rebounder.size = 0
	rebounding.ClearRebound()
end
