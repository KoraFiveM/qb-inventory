local RESOURCE = GetCurrentResourceName()
local SOURCE_RESOURCE = 'kora_inventory'
local SOURCE_DIRECTORY = '@kora_inventory/images'
local IMAGE_DIRECTORY = RESOURCE == 'qb-inventory' and 'html/images'
    or RESOURCE == 'ox_inventory' and 'web/images'
local EXTENSIONS = { webp = true, png = true, gif = true, jpg = true, jpeg = true, bmp = true }
local syncing = false
local finished = false
local startHandler

if not IMAGE_DIRECTORY then return end

local function isImage(name)
    if type(name) ~= 'string' or name == '' or name == '.' or name == '..' then return false end
    if name:find('/', 1, true) or name:find('\\', 1, true) then return false end
    local extension = name:match('%.([%w]+)$')
    return extension ~= nil and EXTENSIONS[extension:lower()] == true
end

local function finish()
    finished = true
    if startHandler then
        RemoveEventHandler(startHandler)
        startHandler = nil
    end
end

local function syncImages()
    if finished or syncing then return end

    local sourceState = GetResourceState(SOURCE_RESOURCE)
    if sourceState ~= 'started' then
        print(('[%s/image-sync] waiting for kora_inventory (state=%s)'):format(RESOURCE, sourceState))
        return
    end

    local openOk, directory = pcall(io.readdir, SOURCE_DIRECTORY)
    if not openOk or not directory then
        print(('[%s/image-sync] cannot list %s: %s'):format(
            RESOURCE, SOURCE_DIRECTORY, tostring(directory)
        ))
        finish()
        return
    end

    syncing = true
    local scanned, copied, unchanged, failed = 0, 0, 0, 0

    for name in directory:lines() do
        if isImage(name) then
            scanned = scanned + 1
            local source = LoadResourceFile(SOURCE_RESOURCE, ('images/%s'):format(name))
            if type(source) ~= 'string' then
                failed = failed + 1
            else
                local destination = ('%s/%s'):format(IMAGE_DIRECTORY, name)
                if LoadResourceFile(RESOURCE, destination) == source then
                    unchanged = unchanged + 1
                else
                    local savedOk, saved = pcall(SaveResourceFile, RESOURCE, destination, source, #source)
                    if savedOk and saved then
                        copied = copied + 1
                    else
                        failed = failed + 1
                    end
                end
            end
        end
    end

    pcall(function() directory:close() end)
    syncing = false
    finish()

    print(('[%s/image-sync] finished: scanned=%d copied=%d unchanged=%d failed=%d'):format(
        RESOURCE, scanned, copied, unchanged, failed
    ))

    if copied > 0 then
        SetTimeout(500, function()
            ExecuteCommand('refresh')
            SetTimeout(500, function()
                if GetResourceState(RESOURCE) == 'started' then
                    ExecuteCommand(('restart %s'):format(RESOURCE))
                end
            end)
        end)
    end
end

startHandler = AddEventHandler('onResourceStart', function(resource)
    if resource == RESOURCE or resource == SOURCE_RESOURCE then
        SetTimeout(1000, syncImages)
    end
end)

SetTimeout(1000, syncImages)