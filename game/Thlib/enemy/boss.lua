--======================================
--th style boss
--======================================

boss = Class(enemybase)

function boss:init(x, y, name, cards, bg, diff)
    enemybase.init(self,999999999)
    self.x = x
    self.y = y
    self.img = 'undefined'
    --boss魔法阵
    self.aura_alpha = 255 --法阵透明度
    self.aura_alpha_d = 4 --法阵透明度单帧变化值
    self.aura_scale = 1 --法阵大小比例
    self._bosssys = BossSystem(self, name, cards, bg, diff) --boss系统
    --boss行走图
    self._wisys = BossWalkImageSystem(self) --行走图系统
    --boss ex
    if self.ex == nil then
        Kill(self) --开始执行通常符卡系统
    end
    ex.AddBoss(self) --加入ex的boss表中
    lstg.tmpvar.boss = self
end

--！警告：潜在的多玩家适配问题
function boss:frame()
    --出屏判定关闭
    SetAttr(self, 'colli', BoxCheck(self, lstg.world.boundl, lstg.world.boundr, lstg.world.boundb, lstg.world.boundt) and self._colli)
    --血量下限
    self.hp = max(0, self.hp)
    --符卡系统检查hp
    self._bosssys:CheckHP()
    --执行自身task
    self._bosssys:DoTask()
    --行走图系统帧逻辑
    self._wisys:frame()
    --受击闪烁
    if self.dmgt then
        self.dmgt = max(0, self.dmgt - 1)
    end
    --boss系统帧逻辑
    self._bosssys:frame()
    --魔法阵透明度更新
    self.aura_alpha = self.aura_alpha + self.aura_alpha_d
    self.aura_alpha = min(max(0, self.aura_alpha), 128)
end

function boss:render()
    for i=1,25 do
        SetImageState('boss_aura_3D'..i, 'mul+add', Color(self.aura_alpha, 255, 255, 255))
    end
    Render('boss_aura_3D'..self.ani % 25 + 1, self.x, self.y, self.ani * 0.75, 0.92 * self.aura_scale, (0.8 + 0.12 * cos(self.ani * 0.75)) * self.aura_scale)  
    self._bosssys:render()
    self._wisys:render(self.dmgt, self.dmgmaxt)--by OLC，行走图系统
end

function boss:take_damage(dmg)
    if self.dmgmaxt then self.dmgt = self.dmgmaxt end
    if not self.protect then
        local dmg0 = dmg * self.dmg_factor
        self.spell_damage = self.spell_damage+dmg0
        self.hp = self.hp - dmg0
        lstg.var.score = lstg.var.score + 10
    end
end

function boss:kill()
    _kill_servants(self)
    self._bosssys:kill()
    --boss行为更新
    if self._bosssys:next() then --切换到下一个行为
        PreserveObject(self)
    else --没有下一个行为了，清除自身和附属的组件
        boss.del(self)
    end
end

function boss:del()
    self._bosssys:del()
    if self.class.defeat then self.class.defeat(self) end
    ex.RemoveBoss(self)
end

----------------------------------------

Include"Thlib\\enemy\\boss_resources.lua"
Include"Thlib\\enemy\\boss_system.lua"
Include"Thlib\\enemy\\boss_function.lua"
Include"Thlib\\enemy\\boss_card.lua"
Include"Thlib\\enemy\\boss_dialog.lua"
Include"Thlib\\enemy\\boss_other.lua"
Include"Thlib\\enemy\\boss_ui.lua"
