require "asi" require "color"
platform.window:setBackgroundColor(color.white)
cursor.set("pencil")

-- warning: very badly written code, 
-- I have never done anythin with lua or any other nspire project
-- read at your own cost :sob:

function on.resize() 
   W, H = platform.window:width(), platform.window:height()
   fontSize   = W/27 --13.25
   leftMargin = fontSize / 5
   lineSpace  = fontSize * 1.5
end
function parse_friend(index)
    cache_f = {}
    for part in string.gmatch(friends[index+1], "([^:]+)") do
      table.insert(cache_f, part)
    end
end
function reset()      
   W, H = platform.window:width(), platform.window:height()
   fontSize   = W/27 --13.25
   leftMargin = fontSize / 5
   lineSpace  = fontSize * 1.5
   
   f_index = 0
   friends = {
       -- use channel ids
       -- just add them manually bcus im lazy
       "ChatGPT:chatgpt", 
       "Eclipt:924427863724265472",
       "Salamaleko:1263176048296853526", 
       "Hazmat:1263951707533213728", 
       "Titiless:1263180907242852455", 
       "CiberCigarro:1263188031679103109",
       "Fili1719:1263560658864312401",
       "AfonsoC:1311035112074248313",
       "Danypedro:1263189472875642902",
       "Skywolf:1273753901023105164",
       "Kiyoshi:1263229189251665941",
   }
   in_send = nil
   in_menu = false
   in_load = false
   in_fail = false
   parse_friend(1)
   -- default friend = 2
   
   new_cache = ""
   new_ssid = ""
   new_pwrd = ""
   new_index = 0
   
   msg_n = 0
   data_cache = {}
   startTimings = false
   txString, rxString, rxCache = "", "", ""
   rxStatus, rxCallback, rxPort = "Welcome!", "None", "Waiting for connection...."
   centerIndex = 2.3
   
   --editor = D2Editor.newRichText()
   --editor:move(1.5,lineSpace+0.4)
   --editor:setMainFont("sansserif", "r")
   --editor:resize(W-1.5,H-lineSpace*2-1)
   --editor:setReadOnly(true)
   --editor:setSelectable(false)
   --editor:setFontSize(8)  
   --editor:setText("squidgames")
   
   logo = image.new(_R.IMG.cool_logo)
   icon_load = image.new(_R.IMG.icon_load)
   icon_fail = image.new(_R.IMG.icon_fail)
   
   
   platform.window:invalidate()   
end
local PORT

function stateListener(state) 
   if state == asi.ON then  
      asi.startScanning(portScanner)
   end
end

function portScanner(port)
   PORT = port  
   print('port connector: ', port)
   port:connect(portConnector)
end

function portConnector(port, event)  
   if event == asi.CONNECTED then 
      asi.stopScanning()
      port:setReadListener(readListener)
   end
end

function readListener(port)
  platform.window:invalidate()
  local success, rxValue = pcall(port.getValue, port)
  if success then
    rxStatus = "Online"
    --rxString = rxValue
    rxCache = rxValue
    print("RX: "..tostring(rxString)) 
    rxPort = tostring(port)
    rxPort = string.gsub(rxPort, "userdata: ", "")

    local newlinePos = string.find(tostring(rxCache), "</m>")
    if newlinePos then
      local line = string.sub(rxCache, 1, newlinePos - 1)
      line = string.gsub(line, "\n", "")
      rxCache = string.sub(rxCache, newlinePos + 1) 
      print("\nReceived line:", line) 
      
      rxCache  = ""
      if tostring(line) ~= rxString then
        rxString = tostring(line)
        display_msgs(tostring(line))
      end
    end

  else
    rxStatus = "No Signal"
    --rxString = rxString
  end
  platform.window:invalidate()
end

function on.construction()
   reset()
   asi.addStateListener(stateListener)
end
function err_port(err, f1, f2)
    local parts = {}
    for part in string.gmatch(err, "([^:]+)") do
      table.insert(parts, part)
    end
    return ""
end
function on.timer()
   -- read ports every 1 second
   --PORT:read()
   local success, err = pcall(function()
       PORT:read()
   end)
   if not success then
       in_load = false
       in_fail = true
       rxPort   = "DISCONNECTED"
       rxStatus = "Unable to locate PORT"
   end
end
-------------------------------------------------------------------------------
function on.charIn(char)
   -- using [EE] key as friends menu toggle
   if in_menu then
       if char == '' then
           in_menu = false
       end
       if char == '8' and f_index > 0 then
           f_index = f_index-1
       elseif char == '8' then
           f_index = #friends-1
       end
       if char == '2' and f_index+1 < #friends then
           f_index = f_index+1
       elseif char == '2' then
           f_index = 0
       end
   else
       if char == '' then
           in_menu = true
           f_index = 0
       else
           txString = txString..char
       end
       if in_load and new_index == 0 then
           new_ssid = txString
       elseif in_load and new_index > 0 then
           new_pwrd = txString
       end
   end
   platform.window:invalidate()
end
function on.backspaceKey()
   txString = string.usub(txString, 1, -2)
   if in_load and new_index == 0 then
       new_ssid = txString
   elseif in_load and new_index > 0 then
       new_pwrd = txString
   end
   platform.window:invalidate()
end
function on.enterKey()
   if in_load and new_index == 0 and txString ~= "" then
       new_pwrd, txString = "", ""
       new_index = 1
   elseif in_load and new_index > 0 then
       if txString ~= "" then
           print("sending update data...")
           print("ssid: "..new_ssid)
           print("pwrd: "..new_pwrd)
       
           PORT:write("//UPDATE//"..new_ssid.."||"..new_pwrd.."\n")
       end
       new_ssid, new_pwrd, txString = "", "", ""
       new_index = 0
   elseif in_menu then
       print(f_index)
       print(friends[f_index+1])
       parse_friend(f_index)
       --editor:setText("updating channel to "..cache_f[2])
       rxString = ""
       rxCallback = ""
       local success, err = pcall(function()
           in_load = true
           print("attempting channel update...")
           PORT:write("//CHANNEL//"..cache_f[2].."\n")
           in_menu = false
           msg_n   = 0
       end)
       if not success then
           rxStatus = "Disconnected"
           _tx, txString = "", ""
       end
   else
       if not startTimings then
           timer.start(3)
           --editor:setVisible(true)
           in_load = true
           local success, err = pcall(function()
               PORT:read()
               PORT:write("//CHANNEL//"..cache_f[2].."\n")
           end)
           if not success then
               in_load = false
               in_fail = true
               rxPort   = "DISCONNECTED"
               rxStatus = "Unable to locate PORT"
           end
           startTimings = true
           
       end
       --PORT:write(txString.."\n")
       if rxString ~= "" then
           in_send = "< sending > "..txString
       end
       local success, err = pcall(function()
           PORT:write(txString.."\n")
       end)
       local _tx =  "nil"
       if not success then
           rxStatus = "Disconnected"
           _tx, txString = "ERROR WRITTING TX_DATA TO PORT:\n"..err.."\nPLEASE CHECK FOR CONNECTIONS WITH THE ESP MODULE!\n:: generating traceback..."
           
       end
       -- PORT:read()
       --if txString and txString ~= "" then
       --    editor:setText(_tx..("\n < sending.. > "..txString or "<nil>"))
       --end
       --if txString and txString == "" then
       --    editor:setText("Attempting connection to channel: "..cache_f[2].."\nLoading...")
       --end
       txString = ""
   end
   platform.window:invalidate()
end
function on.escapeKey()
   reset()
end
local cahce_table = {}
function display_msgs(rxData)
    local content = {}
    local _channel, content = tostring(rxData):match("^<m:(%d+)>(.+)$")
    print("channel.."..tostring(_channel).." | cache: "..cache_f[2])
    if in_load and string.find(tostring(rxData), tostring(cache_f[2])) then
        in_load = false
    end
    if type(rxData) == "string" and _channel and content then
        data_cache = {}
        for part in content:gmatch("([^||]+)") do
            table.insert(data_cache, part)
        end
    else
        if startTimings then
            rxStatus = "onHold"
        end
        rxString = rxCallback
        in_send = nil
    end
    if data_cache ~= {} then
        --local _cache = table.concat(data_cache, " // ")
        --print("\ncache: ".._cache)
        --editor:setText(table.concat(data_cache, "\n"))
        --editor:setText(table.concat(data_cache, "\n"))
        cahce_table = data_cache
    end
end

function drawWrappedText(gc, strings, W, startX, startY, lineSpace, tabSpace)
    local display_data = {}  
    local currentY = startY
    local cur_author = "nil"
    
    for _, text in ipairs(strings) do
        text = string.gsub(text, "[\r\n]", "")
        
        local author, content = text:match("([^:]+):(.*)")
        if author and content then
            if author ~= cur_author then
                table.insert(display_data, "<author>"..author .. ":")
                cur_author = author
            end
            -- indent stuff
            local remainingText = tabSpace .. content
            local firstChunk = true
            
            while #remainingText > 0 do
                local currentLine = ""
                local charIndex = 1
                
                while charIndex <= #remainingText do
                    local testLine = remainingText:sub(1, charIndex)
                    local lineWidth = gc:getStringWidth(testLine) + startX + 1
                    
                    if lineWidth <= W then
                        charIndex = charIndex + 1
                    else
                        break
                    end
                end
                
                currentLine = remainingText:sub(1, charIndex - 1)
                table.insert(display_data, currentLine)
                remainingText = remainingText:sub(charIndex)
                
                if #remainingText > 0 then
                    remainingText = tabSpace .." " .. remainingText
                end
            end
        else
            local remainingText = text
            while #remainingText > 0 do
                local charIndex = 1
                
                while charIndex <= #remainingText do
                    local testLine = remainingText:sub(1, charIndex)
                    local lineWidth = gc:getStringWidth(testLine) + startX + 1
                    
                    if lineWidth <= W then
                        charIndex = charIndex + 1
                    else
                        break
                    end
                end
                
                local currentLine = remainingText:sub(1, charIndex - 1)
                table.insert(display_data, currentLine)
                remainingText = remainingText:sub(charIndex)
                
                if #remainingText > 0 then
                    remainingText = tabSpace .." " .. remainingText
                end
            end
        end
    end
    
    --local startIndex = math.max(1, #display_data - 12)
    for i = 0, #display_data - 1 do 
        if display_data[i] and display_data[i+2] and
           string.find(display_data[i], "<author>") and 
           string.find(display_data[i+2], "<author>") then
            display_data[i] = display_data[i]..string.sub(display_data[i+1], #tabSpace+1)
            table.remove(display_data, i+1)
        elseif display_data[i+1] and i == #display_data -1
           and string.find(display_data[i], "<author>") then
            display_data[i] = display_data[i]..string.sub(display_data[i+1], #tabSpace+1)
            table.remove(display_data, i+1)
        end
    end
    local startIndex = math.max(1, #display_data - 11) -- -12
    for i = startIndex, #display_data do
        local content = display_data[i]
        if string.find(content , "<author>") then
            content = string.sub(content, 9)
            currentY = currentY + 2
        end
        gc:drawString(content, startX, currentY)
        currentY = currentY + lineSpace + 2
    end
    
    return currentY
end
function on.paint(gc)
    if startTimings and not in_load then
        --editor:setVisible(true)
        if in_menu then
            drawWrappedText(gc, cahce_table, W, lineSpace*5 + 5, 15, 11, " ")
        else
            drawWrappedText(gc, cahce_table, W, 5, 15, 11, "   ")
        end
    end
    if startTimings and in_send and not in_load and not in_fail then
        gc:setFont("sansserif","i",7)
        gc:drawString(in_send, 6, H -33)
    end
    if not startTimings and not in_load and not in_fail then
        gc:setFont("sansserif","bi",15)
        --editor:setVisible(false)
        --gc:drawImage(logo, 165, 15)
        gc:drawImage(logo, 182, 10)
        gc:drawString("TiNspire wifi bridge",3, 15)
        gc:setFont("sansserif","b",10)
        gc:drawString("Made with lots of love... ",6, 40)
        gc:drawString("by yours only, cl 20 <3 ",6, 52)
        gc:setFont("sansserif","r",9)
        gc:drawString("Waiting for serial connection...",6, 80-5)
        gc:setFont("sansserif","r",8)
        gc:drawString("* Connect serial device to default COM port",4.5, 100-5)
        gc:drawString("* Wait for ESP WiFi connection successfull.",4.5, 112-5)
        gc:drawString("* If the LED stops blinking, you're online!",4.5, 124-5)
        gc:drawString("* Press [EE] to open Friends Menu",4.5, 136-5)
        gc:setFont("sansserif","b",9)
        gc:setPen("medium","smooth")
        gc:drawRect(14, 149, 160, 35)
        gc:setPen("thin","smooth")
        gc:drawString("       Press [ENTER] to begin!   ",4.5, 157)
    end
    if in_load and not in_fail then
        --in_menu = false
        --editor:setVisible(false)
        gc:drawImage(icon_load, 160, 15)
        gc:setFont("sansserif","b",15)
        gc:drawString("Hey! Hold on...", 6, 15)
        gc:setFont("sansserif","bi",10)
        gc:drawString("I am still loading this page",6, 40)
        gc:setFont("sansserif","r",9)
        gc:drawString("Tuning to channel:",        6, 80-20)
        gc:drawString("Id: "..cache_f[2],          7, 93-20)
        --gc:drawString("Ie: "..cache_f[1],          7, 106)
        gc:setFont("sansserif","r",10)
        if new_ssid ~= "" then
            gc:drawString("name: '"..new_ssid.."'",          10, 106)
        else
            gc:drawString("name: < undefined >",             10, 106)
        end
        if new_pwrd ~= "" then
            gc:drawString("Pass: '"..new_pwrd.."'",          10, 122)
        else
            gc:drawString("Pass: < undefined >",          10, 122)
        end
        gc:drawRect(6, 95, 165, 50)
        gc:setFont("sansserif","r",8)
        if new_index == 0 then
            gc:drawString("Change credentials? [ ↵ ] to proceed!",          10, 96)
        else
            gc:drawString("Change credentials? [ ↵ ] to Update!",          10, 96)
        end
        gc:drawString("NOTICE:",          7, 140+12)
        gc:drawString("If this is taking too long to load,",          7, 152+12)
        gc:drawString("consider reconnecting the ESP device.",        7, 163+12)
    end
    if in_fail then
        in_menu = false
        --editor:setVisible(false)
        gc:drawImage(icon_fail, 190, 15) --50
        gc:setFont("sansserif","b",15)
        gc:drawString("Uh oh...",6, 15)
        gc:setFont("sansserif","bi",10)
        
        local h = [[  
        stack traceback:
            main.lua:150: in function 'on.timer()'
            main.lua:154: in in main chunk
            [C] in function 'PORT:read'
        PLEASE CHECK FOR CONNECTIONS WITH THE ESP MODULE!
        PRESS [EE] TO ATTEMPT RECONNECTION]]
        gc:drawString("Something went wrong",6, 40)
        gc:setFont("sansserif","r",6)
        gc:drawString("ERROR WRITTING TX_DATA TO PORT",7, 65)
        gc:drawString([[[string "require "asi" require "color"..."]:154:]],7, 75)
        gc:drawString("attempt to index upvalue 'PORT' (a nil value)",8, 85)
        gc:drawString("attempt to index upvalue 'PORT' (a nil value)",8, 95)
        gc:drawString("stack traceback:",8, 105)
        gc:drawString("    main.lua:150: in function 'on.timer()'",7, 115)
        gc:drawString("    main.lua:154: in in main chunk",7, 125)
        gc:drawString("    [C] in function 'PORT:read'",7, 135)
        gc:setFont("sansserif","r",9)
        gc:drawString("Check for cable connections with the ESP device!",7, 150)
        gc:drawString("Program needs to restart to attempt new connection.",7, 161)
        gc:setFont("sansserif","r",6)
        gc:drawString("× Everything connected? Try to replug USB-B port...",7, 176)
    end
    if not in_load then
        new_index = 0
        new_cache = ""
        new_ssid  = ""
        new_pwrd  = ""
    end
    gc:setFont("sansserif","r",10)
    
    
    local topUIHeight = lineSpace
    local bottomUIHeight = lineSpace * 2
    local availableHeight = H - topUIHeight - bottomUIHeight
    local maxLines = math.floor(availableHeight / lineSpace)
    --
    local maxWidth = W - leftMargin * 2
    local visibleTxString = tostring(txString)
    while gc:getStringWidth(visibleTxString) > maxWidth do
        visibleTxString = string.sub(visibleTxString, 2)
    end

    gc:drawString("      "..rxPort.." "..(rxStatus or ""), leftMargin, 0 - centerIndex)
    if not in_load then
        gc:drawString("|" .. visibleTxString, leftMargin, H - bottomUIHeight + lineSpace - centerIndex)
    end
    gc:drawRect(0, topUIHeight, W - 0.5, H - bottomUIHeight)
    gc:drawRect(0, 0, W - 0.5, H - 0.5)
    
    
    -- draw friends menu
    if in_menu then
        --editor:move(lineSpace*5,lineSpace+0.4)
        gc:setColorRGB(255, 255, 255)
        gc:fillRect(0, lineSpace, lineSpace*5, H)
        gc:setColorRGB(0, 0, 0)
        gc:drawRect(-1, lineSpace, lineSpace*5, H)
        --gc:drawRect(-1, H-lineSpace, lineSpace*5, H)
        gc:setFont("serif","i",6)
        gc:drawString(cache_f[1], 0, H-21)
        gc:drawString(cache_f[2], 0, H-12)
        gc:setFont("sansserif","r",10)
        gc:setColorRGB(170, 170, 170)
        gc:fillRect(0, lineSpace+10*f_index, lineSpace*5, lineSpace-5)
        gc:setColorRGB(0, 0, 0)
        for i, friend in ipairs(friends) do
           friend = string.sub(friend, 1, string.find(friend, ":") - 1)
           if friend == cache_f[1] then
               gc:drawString('* '..friend, 1.5, 10 * i + 3)
           else
               gc:drawString('  '..friend, 1.5, 10 * i + 3) 
           end
        end
     else
        --editor:move(1.5,lineSpace+0.4)
        --startLineSpace = startLineSpace + 10
        startLineX = 5
     end
    
    
    
    gc:drawRect(0, 0, lineSpace+5, lineSpace)
    gc:fillRect(0, 0, lineSpace+5, lineSpace)
    gc:setColorRGB(255, 255, 255)
    gc:drawString("EE", 2, 0 - centerIndex)
end
