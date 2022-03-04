local HttpService = game:GetService("HttpService")

-- Constants:
local ValidExtensions = {
    ".lua",
    ".json",
    ".jpg",
    ".png"
}

-- Variables:
local imported = {}

-- Functions:
local function findFile(path: string)
    local nodes = path:split("/")

    -- Folder
    local folder = nodes[1]
    if not isfolder(folder) then return nil end
    for i = 2, #nodes - 1 do
        folder = folder .. "/" .. nodes[i]
        if not isfolder(folder) then return nil end
    end

    -- Get File:
    if isfolder(folder .. "/" .. nodes[#nodes]) then
        return folder .. "/init.lua"
    end

    local file;
    local extension;
    for i,v in ipairs(listfiles(folder)) do
        local name, count = v:gsub(folder, "", 1)
        if count == 1 then
            local split = name:split(".")
            local ext = "." .. split[#split]
            if table.find(ValidExtensions, ext) then
                file = v
                extension = ext
                break
            end
        end
    end
    return file, extension
end

local function loadChunk(chunk: string, extension: string)
    if extension == ".lua" then
        return loadstring(chunk)();
    elseif extension == ".json" then
        return HttpService:JSONDecode(chunk);
    else
        return loadstring(chunk);
    end
end

-- Runtime:
local Runtime = {}

function Runtime.import(path: string)
    if imported[path] then return imported[path] end
    local file, extension = findFile(path)
    if file then
        if imported[file] then
            return imported[file]
        else
            local chunk = readfile(file)
            local module = loadChunk(chunk, extension)
            imported[file] = module
            imported[path] = module
            return module;
        end
    end
    return error("File not found");
end

print(Runtime.import("Test/Test-script")())
task.wait(2.5)
print(Runtime.import("Test/Test-script")())

return Runtime