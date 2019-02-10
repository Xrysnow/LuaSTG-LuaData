---=====================================
---luastg simple log system
---=====================================

----------------------------------------
---old API

local _PRINT=lstg.Print

----------------------------------------
---log udp server

local UDP_SERVER_IP,UDP_SERVER_PORT="localhost",7

local MSG_HEAD="[MSG]"
local PING_HEAD="[PING]"
local REV_HEAD="[REV]"

local LOG_HEAD="NETWORK INFO: "
local WARN_HEAD="NETWORK WARNING: "
local ERR_HEAD="NETWORK ERROR: "

local UDP=nil--udp object

---检查UDP连接可用性
local function UDP_Check()
    if not socket then
        return false
    end
    if UDP==nil then
        --创建UDP object并绑定到对等端口
        UDP=assert(socket.udp())
        local flag=false
        --connect
        local state,errmsg=UDP:setpeername(UDP_SERVER_IP,UDP_SERVER_PORT)
        if state then
            _PRINT(LOG_HEAD.."Connect to listener successfully. ")
            flag=true
        elseif errmsg then
            _PRINT(ERR_HEAD.."Failed to connect to listener. "..tostring(errmsg))
            flag=false
        else
            _PRINT(ERR_HEAD.."Failed to connect to listener. Unkown error.")
            flag=false
        end
        --check once again
        local ip, port = UDP:getpeername()
        if ip then
            _PRINT(LOG_HEAD.."Check pass,connected to "..tostring(ip)..":"..tostring(port))
            flag=true
        elseif port then
            _PRINT(ERR_HEAD.."Failed to get peer name. "..tostring(port))
            flag=false
        else
            _PRINT(ERR_HEAD.."Failed to get peer name. Unkown error.")
            flag=false
        end
        if not flag then
            UDP:close()
            UDP=nil
        end
        return flag
    end
    return true
end

---发送一条消息给监听服务器
local function UDP_send(msg)
    local state,errmsg=UDP:send(MSG_HEAD..__UTF8ToANSI(tostring(msg)))
    if state then
        --lstg.Print(LOG_HEAD.."Send message : \""..tostring(msg).."\" successfully. ")
    elseif errmsg then
        _PRINT(ERR_HEAD.."Failed to send UDP package. "..tostring(errmsg))
    else
        _PRINT(ERR_HEAD.."Failed to send UDP package. Unkown error.")
    end
end

---检查UDP连接可用性并发送消息
local function Send_Log_Message(msg)
    if UDP_Check() then
        UDP_send(msg)
    end
end

----------------------------------------
---simple log

local LSTG_LOG_MIN_LEVEL=1
local LSTG_LOG_LEVEL={
    "[DEBUG]",
    "[INFO]",
    "[WARN]",
    "[ERROR]",
    "[EMERGENCY]",
    
    ["[DEBUG]"]=1,
    ["[INFO]"]=2,
    ["[WARN]"]=3,
    ["[ERROR]"]=4,
    ["[EMERGENCY]"]=5,
}

---简单的log
---@param level number|string @log级别,[DEBUG],[INFO],[WARN],[ERROR],[EMERGENCY]五个级别
---@param module string 模块名
---@param str string @log内容
---@vararg string|number|boolean @其他
function lstg.Log(level,module,str, ... )
    if type(level)=="string" then
        level=LSTG_LOG_LEVEL[level]
        if not level then
            level=1
        end
    end
    if level>=LSTG_LOG_MIN_LEVEL then
        local msg=""
        if module then
            msg=string.format("%s%s%s",LSTG_LOG_LEVEL[level],module,tostring(str))
        else
            msg=string.format("%s%s",LSTG_LOG_LEVEL[level],tostring(str))
        end
        local args={ ... }
        for _,v in ipairs(args) do
            msg=msg..string.format(" %s",tostring(v))
        end
        _PRINT("\n"..msg)
        Send_Log_Message(msg)
    end
end

---重定义的Print
function lstg.Print( ... )
    _PRINT( ... )
    local args={ ... }
    local msg="[INFO]"
    for _,v in ipairs(args) do
        msg=msg..string.format("%s ",tostring(v))
    end
    Send_Log_Message(msg)
end

Print=lstg.Print

----------------------------------------
---simple MessageBox

local ffi = require("ffi")
ffi.cdef[[
    int MessageBoxA(void *w, const char *txt, const char *cap, int type);
]]

---简单的警告弹窗
---@param msg string
function lstg.MsgBoxWarn(msg)
    local ret=ffi.C.MessageBoxA(nil, __UTF8ToANSI(tostring(msg)), __UTF8ToANSI("LuaSTGPlus脚本警告"), 1+48)
    if ret==2 then os.exit() end
end

---简单的错误弹窗
---@param msg string
function lstg.MsgBoxError(msg,title,exit)
    local ret=ffi.C.MessageBoxA(nil, __UTF8ToANSI(tostring(msg)), __UTF8ToANSI(tostring(title)), 0+16)
    if ret==1 and exit then
        os.exit()
    end
end
