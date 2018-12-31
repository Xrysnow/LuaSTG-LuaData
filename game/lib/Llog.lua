---=====================================
---luastg simple log system
---=====================================

----------------------------------------
---simple log

local LSTG_LOG_MIN_LEVEL=1
local LSTG_LOG_LEVEL={
    "[Debug]",
    "[Info]",
    "[Warning]",
    "[Error]",
    "[Emergency]",
    
    ["[Debug]"]=1,
    ["[Info]"]=2,
    ["[Warning]"]=3,
    ["[Error]"]=4,
    ["[Emergency]"]=5,
}

---简单的log
---@param level number|string @log级别,[Debug],[Info],[Warning],[Error],[Emergency]五个级别
---@param module string 模块名
---@param str string @log内容
---@vararg string|number|boolean @其他
function lstg.Log(level,module,str, ... )
    if type(level)=="string" then
        level=LSTG_LOG_LEVEL[level]
    end
    if level>=LSTG_LOG_MIN_LEVEL then
        lstg.Print(LSTG_LOG_LEVEL[level]..module..str, ... )
    end
end
