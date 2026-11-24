print("[VI7.2] START")
local ok, err = pcall(function()
    local base = "https://raw.githubusercontent.com/renosang/Voidware-Vietnamese/main/"
    local function fetch(name)
        print("[VI7.2] Download: "..name)
        local content = game:HttpGet(base..name, true)
        assert(type(content)=="string" and #content>0, "Empty file: "..name)
        return content
    end
    local dictionary = game:GetService("HttpService"):JSONDecode(fetch("vi.json"))
    local chunk, compileError = loadstring(fetch("translator.lua"))
    assert(chunk, compileError)
    local translator = chunk()
    assert(type(translator)=="function", "Invalid translator")
    translator(dictionary)
end)
if not ok then warn("[VI7.2 ERROR] "..tostring(err)) end
