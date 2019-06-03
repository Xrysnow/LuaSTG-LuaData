---=====================================
---杂项
---=====================================

misc={}

----------------------------------------
---杂项功能

--多种消亡特效
hinter=Class(object)

function hinter:init(img,size,x,y,t1,t2,fade)
	self.img=img
	self.x=x
	self.y=y
	self.t1=t1
	self.t2=t2
	self.fade=fade
	self.group=GROUP_GHOST
	self.layer=LAYER_TOP
	self.size=size
	self.t=0
	self.hscale=self.size
end

function hinter:frame()
	if self.timer<self.t1 then
		self.t=self.timer/self.t1
	elseif self.timer<self.t1+self.t2 then
		self.t=1
	elseif self.timer<self.t1*2+self.t2 then
		self.t=(self.t1*2+self.t2-self.timer)/self.t1
	else
		Del(self)
	end
end

function hinter:render()
	if self.fade then
		SetImageState(self.img,'',Color(self.t*255,255,255,255))
		self.vscale=self.size
		object.render(self)
	else
		SetImageState(self.img,'',Color(0xFFFFFFFF))
		self.vscale=self.t*self.size
		object.render(self)
	end
end


bubble=Class(object)

function bubble:init(img,x,y,life_time,size1,size2,color1,color2,layer,blend)
	self.img=img
	self.x=x
	self.y=y
	self.group=GROUP_GHOST
	self.life_time=life_time
	self.size1=size1
	self.size2=size2
	self.color1=color1
	self.color2=color2
	self.layer=layer
	self.blend=blend or ''
end

function bubble:render()
	local t=(self.life_time-self.timer)/self.life_time
	local size=self.size1*t+self.size2*(1-t)
	local c=self.color1*t+self.color2*(1-t)
	SetImageState(self.img,self.blend,c)
	Render(self.img,self.x,self.y,0,size)
end

function bubble:frame()
	if self.timer==self.life_time-1 then
		Del(self)
	end
end


bubble2=Class(object)

function bubble2:init(img,x,y,vx,vy,life_time,size1,size2,color1,color2,layer,blend)
	self.img=img
	self.x=x
	self.y=y
	self.vx=vx
	self.vy=vy
	self.group=GROUP_GHOST
	self.life_time=life_time
	self.size1=size1
	self.size2=size2
	self.color1=color1
	self.color2=color2
	self.layer=layer
	self.blend=blend or ''
end

function bubble2:render()
	local t=(self.life_time-self.timer)/self.life_time
	local size=self.size1*t+self.size2*(1-t)
	local c=self.color1*t+self.color2*(1-t)
	SetImageState(self.img,self.blend,c)
	Render(self.img,self.x,self.y,0,size)
end

function bubble2:frame()
	if self.timer==self.life_time-1 then
		Del(self)
	end
end


--收点时头上飞出的数字
float_text=Class(object)

function float_text:init(fnt,text,x,y,v,angle,life_time,size1,size2,color1,color2)
	self.fnt=fnt
	self.text=text
	self.x=x
	self.y=y
	self.vx=v*cos(angle)
	self.vy=v*sin(angle)
	self.group=GROUP_GHOST
	self.life_time=life_time
	self.size1=size1
	self.size2=size2
	self.color1=color1
	self.color2=color2
	self.layer=LAYER_TOP
end

function float_text:render()
	local t=(self.life_time-self.timer)/self.life_time
	local size=self.size1*t+self.size2*(1-t)
	local c=self.color1*t+self.color2*(1-t)
	SetFontState(self.fnt,'',c)
	RenderText(self.fnt,self.text,self.x,self.y,size,'centerpoint')
end

function float_text:frame()
	if self.timer==self.life_time-1 then
		Del(self)
	end
end


float_text2=Class(object)

function float_text2:init(fnt,text,x,y,v,angle,life_time,size1,size2,color1,color2)
	self.fnt=fnt
	self.text=text
	self.x=x
	self.y=y
	self.vx=v*cos(angle)
	self.vy=v*sin(angle)
	self.group=GROUP_GHOST
	self.life_time=life_time
	self.size1=size1
	self.size2=size2
	self.color1=color1
	self.color2=color2
	self.layer=LAYER_TOP
end

function float_text2:render()
	local t=(self.life_time-self.timer)/self.life_time
	local size=self.size1*t+self.size2*(1-t)
	local c=self.color1*t+self.color2*(1-t)
	SetFontState(self.fnt,'',Color(255*t,80,80,80))
	RenderText(self.fnt,self.text,self.x+0.6,self.y+0.6,size,'centerpoint')
	RenderText(self.fnt,self.text,self.x+0.6,self.y-0.6,size,'centerpoint')
	RenderText(self.fnt,self.text,self.x-0.6,self.y-0.6,size,'centerpoint')
	RenderText(self.fnt,self.text,self.x-0.6,self.y+0.6,size,'centerpoint')
	SetFontState(self.fnt,'',c)
	RenderText(self.fnt,self.text,self.x,self.y,size,'centerpoint')
end

function float_text2:frame()
	if self.timer==self.life_time-1 then
		Del(self)
	end
end


--震屏
--fixed by ETC，不再直接改lrbt
function misc.ShakeScreen(t,s)
	if lstg.tmpvar.shaker then
		lstg.tmpvar.shaker.time=t
		lstg.tmpvar.shaker.size=s
		lstg.tmpvar.shaker.timer=0
	else
		New(shaker_maker,t,s)
	end
end

shaker_maker=Class(object)

function shaker_maker:init(time,size)
	lstg.tmpvar.shaker=self
	self.time=time
	self.size=size
	self.offset=lstg.worldoffset
	--[[
	self.l=lstg.world.l
	self.r=lstg.world.r
	self.bb=lstg.world.b
	self.t=lstg.world.t
	--]]
end

function shaker_maker:frame()
	local a=int(self.timer/3)*360/5*2
	local x=self.size*cos(a)
	local y=self.size*sin(a)
	self.offset.dx=x
	self.offset.dy=y
	--[[
	lstg.world.l=self.l+x
	lstg.world.r=self.r+x
	lstg.world.b=self.bb+y
	lstg.world.t=self.t+y
	--]]
	if self.timer==self.time then
		Del(self)
	end
end

function shaker_maker:del()
	self.offset.dx=0
	self.offset.dy=0
	--[[
	lstg.world.l=self.l
	lstg.world.r=self.r
	lstg.world.b=self.bb
	lstg.world.t=self.t
	--]]
	lstg.tmpvar.shaker=nil
end

function shaker_maker:kill()
	self.offset.dx=0
	self.offset.dy=0
	--[[
	lstg.world.l=self.l
	lstg.world.r=self.r
	lstg.world.b=self.bb
	lstg.world.t=self.t
	--]]
	lstg.tmpvar.shaker=nil
end


--tasker
tasker=Class(object)

function tasker:init(f,group)
	self.group=group or GROUP_GHOST
	task.New(self,f)
end

function tasker:frame()
	task.Do(self)
	if coroutine.status(self.task[1])=='dead' then
		Del(self)
	end
end


--切换关卡用的幕布
shutter=Class(object)

function shutter:init(mode)
	self.layer=LAYER_TOP+100
	self.group=GROUP_GHOST
	self.open=(mode=='open')
end

function shutter:frame()
	if self.timer==60 then
		Del(self)
	end
end

function shutter:render()
	SetViewMode'ui'
	SetImageState('white','',Color(0xFF000000))
	if self.open then
		for i=0,15 do
			RenderRect('white',(i+1-min(max(1-self.timer/30+i/16,0),1))*(screen.width/16),(i+1)*(screen.width/16),0,screen.height)
		end
	else
		for i=0,15 do
			RenderRect('white',i*(screen.width/16),(i+min(max(self.timer/30-i/16,0),1))*(screen.width/16),0,screen.height)
		end
	end
end


mask_fader=Class(object)

function mask_fader:init(mode)
	self.layer=LAYER_TOP+100
	self.group=GROUP_GHOST
	self.open=(mode=='open')
end

function mask_fader:frame()
	if self.timer>30 then
		Del(self)
	end
end

function mask_fader:render()
	SetViewMode'ui'
	if self.open then
		SetImageState('white','',Color(max(0,min(255,255-self.timer*8.5)),0,0,0))
	else
		SetImageState('white','',Color(max(0,min(255,self.timer*8.5)),0,0,0))
	end
	RenderRect('white',0,screen.width,0,screen.height)
	SetViewMode'world'
end


--维持粒子特效直到消失
--！警告：使用了改类功能
function misc.KeepParticle(o)
	o.class=ParticleKepper
	PreserveObject(o)
	ParticleStop(o)
	o.bound=false
	o.group=GROUP_GHOST
end

ParticleKepper=Class(object)
function ParticleKepper:frame()
	if ParticleGetn(self)==0 then
		Del(self)
	end
end


--一些形状的渲染
function misc.RenderRing(img,x,y,r1,r2,rot,n,nimg)--boss card
	local da=360/n
	local a=rot
	for i=1,n do
		a=rot-da*i
		Render4V(img..((i-1)%nimg+1),
			r1*cos(a+da)+x,r1*sin(a+da)+y,0.5,
			r2*cos(a+da)+x,r2*sin(a+da)+y,0.5,
			r2*cos(a)+x,r2*sin(a)+y,0.5,
			r1*cos(a)+x,r1*sin(a)+y,0.5)
	end
end

function misc.Renderhp(x,y,rot,la,r1,r2,n,c)--boss
	local da=la/n
	local nn=int(n*c)
	for i=1,nn do
		local a=rot+da*i
		Render4V('hpbar1',
			r1*cos(a+da)+x,r1*sin(a+da)+y,0.5,
			r2*cos(a+da)+x,r2*sin(a+da)+y,0.5,
			r2*cos(a)+x,r2*sin(a)+y,0.5,
			r1*cos(a)+x,r1*sin(a)+y,0.5)
	end
end

function misc.Renderhpbar(x,y,rot,la,r1,r2,n,c)--boss
	local da=la/n
	local nn=int(n*c)
	for i=1,nn do
		local a=rot+da*i
		Render4V('hpbar2',
			r1*cos(a+da)+x,r1*sin(a+da)+y,0.5,
			r2*cos(a+da)+x,r2*sin(a+da)+y,0.5,
			r2*cos(a)+x,r2*sin(a)+y,0.5,
			r1*cos(a)+x,r1*sin(a)+y,0.5)
	end
end

function renderstar(x,y,r,point)--?
	local ang=360/(2*point)
	for angle=360/point,360,360/point do
		local x1,y1=x+r*cos(angle+ang)^3,r*sin(angle+ang)^3
		local x2,y2=x+r*cos(angle-ang)^3,r*sin(angle-ang)^3
		Render4V('_sub_white',x,y,0.5,
		x,y,0.5,
		x1,y1,0.5,
		x2,y2,0.5)
	end
end

function rendercircle(x,y,r,point)--player death effect
	local ang=360/(2*point)
	for angle=360/point,360,360/point do
		local x1,y1=x+r*cos(angle+ang),y+r*sin(angle+ang)
		local x2,y2=x+r*cos(angle-ang),y+r*sin(angle-ang)
		Render4V('_rev_white',x,y,0.5,
		x,y,0.5,
		x1,y1,0.5,
		x2,y2,0.5)
	end
end

---纹理平铺
---@param tex string @texture res
---@param blend string @blendmode
---@param color lstgColor|table
---@param x number
---@param y number
---@param rot number
---@param hscale number
---@param vscale number
---@param u number
---@param v number
---@param uvrot number
---@param uvhscale number
---@param uvvscale number
function misc.RenderTile(tex,blend,color,x,y,rot,hscale,vscale,u,v,uvrot,uvhscale,uvvscale)
	if not SetTextureSamplerState then
		return
	end
	--设置采样方式
	SetTextureSamplerState("address","wrap")
	--计算顶点坐标
	local texw,texh=GetTextureSize(tex)
	local texw2,texh2=texw/2,texh/2
	local texpos={
		x={-texw2*hscale,texw2*hscale, texw2*hscale,-texw2*hscale},
		y={ texh2*vscale,texh2*vscale,-texh2*vscale,-texh2*vscale},
	}
	for s=1,4 do
		texpos.x[s],texpos.y[s]=texpos.x[s]*cos(rot)-texpos.y[s]*sin(rot),texpos.x[s]*sin(rot)+texpos.y[s]*cos(rot)
		texpos.x[s],texpos.y[s]=texpos.x[s]+x,texpos.y[s]+y
	end
	--计算uv坐标
	local uvpos={
		u={-texw2*uvhscale, texw2*uvhscale,texw2*uvhscale,-texw2*uvhscale},
		v={-texh2*uvvscale,-texh2*uvvscale,texh2*uvvscale, texh2*uvvscale},
	}
	for s=1,4 do
		uvpos.u[s],uvpos.v[s]=uvpos.u[s]*cos(uvrot)-uvpos.v[s]*sin(uvrot),uvpos.u[s]*sin(uvrot)+uvpos.v[s]*cos(uvrot)
		uvpos.u[s],uvpos.v[s]=uvpos.u[s]+texw2-u,uvpos.v[s]+texh2+v--uv坐标中心点在左上角
	end
	--填充数据
	local vertex={
		{texpos.x[1],texpos.y[1],0.5,uvpos.u[1],uvpos.v[1],},
		{texpos.x[2],texpos.y[2],0.5,uvpos.u[2],uvpos.v[2],},
		{texpos.x[3],texpos.y[3],0.5,uvpos.u[3],uvpos.v[3],},
		{texpos.x[4],texpos.y[4],0.5,uvpos.u[4],uvpos.v[4],},
	}
	if type(color)=="table" then
		for s=1,4 do
			vertex[s][6]=color[s]
		end
	else
		for s=1,4 do
			vertex[s][6]=color
		end
	end
	--渲染
	RenderTexture(tex,blend,vertex[1],vertex[2],vertex[3],vertex[4])
	--恢复采样方式
	SetTextureSamplerState("address","clamp")
end

---纹理平铺符卡背景
---@param tex string @texture res
---@param blend string @blendmode
---@param color lstgColor
---@param u number
---@param v number
---@param uvrot number
---@param uvhscale number
---@param uvvscale number
function misc.RnderTileSCBG(tex,blend,color,u,v,uvrot,uvhscale,uvvscale)
	local world=lstg.world
	local worldw,worldh=world.r-world.l,world.t-world.b
	local w,h=GetTextureSize(tex)
	local scale=math.max(worldw/w,worldh/h)
	misc.RenderTile(tex,blend,color,
		0,0,0,scale,scale,
		u,v,uvrot,scale/uvhscale,scale/uvvscale)
end

---纹理平铺符卡背景（老方法，无法旋转、缩放）
---@param img string @texture res，注意是纹理！！！
---@param x number
---@param y number
function misc.oldRenderTileSCBG(img,x,y)
	local world=lstg.world
	local w,h=GetTextureSize(img)
	for i=-int((world.r+16+x)/w+0.5),int((world.r+16-x)/w+0.5) do
		for j=-int((world.t+16+y)/h+0.5),int((world.t+16-y)/h+0.5) do
			Render(img,x+i*w,y+j*h)
		end
	end
end

----------------------------------------
---资源加载

--一些乱七八糟的东西
LoadTexture('misc','THlib\\misc\\misc.png')
LoadImage('player_aura','misc',128,0,64,64)
LoadImageGroup('bubble','misc',192,0,64,64,1,4)
LoadImage('border','misc',128,192,64,64)
LoadImage('leaf','misc',0,32,32,32)
LoadImage('white','misc',56,8,16,16)
--预制粒子特效图片
LoadTexture('particles','THlib\\misc\\particles.png')
LoadImageGroup('parimg','particles',0,0,32,32,4,4)
--空图片
LoadImageFromFile('img_void','THlib\\misc\\img_void.png')
--反色圈和星星的素材，预先设置好混合和颜色减少性能消耗
CopyImage("_rev_white","white")
SetImageState('_rev_white','add+sub',
	Color(255,255,255,255),
	Color(255,255,255,255),
	Color(255,0,0,0),
	Color(255,0,0,0)
)
CopyImage("_sub_white","white")
SetImageState('_sub_white','mul+sub',
	Color(255,100,100,100),
	Color(255,255,255,255),
	Color(255,0,0,0),
	Color(255,0,0,0)
)
