local activeDUIs = {}
local targetVehicle = nil
local currentCam = nil
local isUIOpen = false

--- Configuração das Câmeras 3D relativas ao veículo
local cameraOffsets = {
    ['teto'] = { pos = vector3(0.0, 0.1, 4.2), target = vector3(0.0, 0.0, 0.5) },
    ['capo'] = { pos = vector3(0.0, 3.8, 1.4), target = vector3(0.0, 1.0, 0.6) },
    ['porta_esquerda'] = { pos = vector3(-3.8, 0.0, 0.8), target = vector3(0.0, 0.0, 0.5) },
    ['porta_direita'] = { pos = vector3(3.8, 0.0, 0.8), target = vector3(0.0, 0.0, 0.5) },
    ['porta_malas'] = { pos = vector3(0.0, -3.8, 1.4), target = vector3(0.0, -1.0, 0.6) },
    ['parachoque_dianteiro'] = { pos = vector3(0.0, 4.3, 0.8), target = vector3(0.0, 1.5, 0.3) },
    ['completo'] = { pos = vector3(-3.5, 3.5, 1.6), target = vector3(0.0, 0.0, 0.5) },
    ['geral'] = { pos = vector3(-3.5, 3.5, 1.6), target = vector3(0.0, 0.0, 0.5) }
}

function SetLiveryCameraView(viewName)
    local veh = targetVehicle
    if not veh or not DoesEntityExist(veh) then return end

    local cfg = cameraOffsets[viewName] or cameraOffsets['geral']
    local worldPos = GetOffsetFromEntityInWorldCoords(veh, cfg.pos.x, cfg.pos.y, cfg.pos.z)
    local worldTarget = GetOffsetFromEntityInWorldCoords(veh, cfg.target.x, cfg.target.y, cfg.target.z)

    if not currentCam then
        currentCam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
        SetCamCoord(currentCam, worldPos.x, worldPos.y, worldPos.z)
        PointCamAtCoord(currentCam, worldTarget.x, worldTarget.y, worldTarget.z)
        SetCamActive(currentCam, true)
        RenderScriptCams(true, true, 600, true, true)
    else
        local newCam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
        SetCamCoord(newCam, worldPos.x, worldPos.y, worldPos.z)
        PointCamAtCoord(newCam, worldTarget.x, worldTarget.y, worldTarget.z)
        SetCamActive(newCam, true)
        SetCamActiveWithInterp(newCam, currentCam, 500, 1, 1)

        Citizen.CreateThread(function()
            Citizen.Wait(500)
            if currentCam and currentCam ~= newCam then
                DestroyCam(currentCam, false)
            end
            currentCam = newCam
        end)
    end
end

function StopLiveryCamera()
    if currentCam then
        RenderScriptCams(false, true, 500, true, true)
        DestroyCam(currentCam, false)
        currentCam = nil
    end
    isUIOpen = false
end

--- Exibir notificação na tela (compatível diretamente com a base WorkStore)
RegisterNetEvent('custom_livery:notify', function(color, message)
    TriggerEvent('Notify', color, message, 5000)

    -- Mensagem no chat para garantia visual
    TriggerEvent('chat:addMessage', {
        color = { 56, 189, 248 },
        multiline = true,
        args = { "[Custom Livery]", message }
    })
end)

--- Comando no cliente
RegisterCommand(Config.Command, function()
    print(string.format("^3[Custom Livery]^0 Comando /%s acionado! Solicitando autorizacao ao servidor...", Config.Command))
    TriggerServerEvent('custom_livery:server:requestOpen')
end, false)

--- Obter veículo atual ou mais próximo
function GetTargetVehicle()
    local ped = PlayerPedId()
    
    local veh = GetVehiclePedIsIn(ped, false)
    if veh ~= 0 and DoesEntityExist(veh) then
        return veh
    end

    local coords = GetEntityCoords(ped)
    local vehicles = GetGamePool('CVehicle')
    local closestVeh = nil
    local closestDist = 10.0

    for _, v in ipairs(vehicles) do
        if DoesEntityExist(v) then
            local vCoords = GetEntityCoords(v)
            local dist = #(coords - vCoords)
            if dist < closestDist then
                closestDist = dist
                closestVeh = v
            end
        end
    end

    return closestVeh
end

--- Abrir interface NUI com Câmera 3D em tempo real
RegisterNetEvent('custom_livery:openUI', function()
    print("^3[Custom Livery Client]^0 Permissao concedida! Procurando veiculo...")
    local veh = GetTargetVehicle()

    if not veh or not DoesEntityExist(veh) then
        print("^1[Custom Livery Client]^0 Nenhum veiculo encontrado dentro ou proximo (raio de 10m).")
        TriggerEvent('custom_livery:notify', 'vermelho', 'Você precisa estar dentro ou próximo de um veículo!')
        return
    end

    if not NetworkGetEntityIsNetworked(veh) then
        NetworkRegisterEntityAsNetworked(veh)
        Citizen.Wait(100)
    end

    targetVehicle = veh
    isUIOpen = true

    local netId = VehToNet(veh)
    local modelHash = GetEntityModel(veh)
    local plate = GetVehicleNumberPlateText(veh) or "SEM-PLACA"

    -- Identifica o nome do modelo
    local modelKey = nil
    for key, data in pairs(Config.Vehicles) do
        if GetHashKey(key) == modelHash then
            modelKey = key
            break
        end
    end

    if not modelKey then
        if modelHash == GetHashKey("rmodskyline34") then
            modelKey = "rmodskyline34"
        elseif modelHash == GetHashKey("skyliner34") then
            modelKey = "skyliner34"
        else
            modelKey = "r34"
        end
    end

    local vehicleConfig = Config.Vehicles[modelKey] or Config.Vehicles['rmodskyline34'] or Config.Vehicles['r34']

    print(string.format("^2[Custom Livery Client]^0 Veiculo identificado: %s (NetID: %s, Placa: %s)", modelKey, netId, plate))

    -- Inicia a Câmera 3D voltada para o teto/frente
    SetLiveryCameraView('teto')

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'open',
        netId = netId,
        plate = plate:gsub('%s+', ''),
        model = modelKey,
        vehicleLabel = vehicleConfig.label,
        zones = vehicleConfig.zones
    })
end)

-- Lista completa de texturas onde estampas/liveries são aplicadas
local texturesToReplace = {
    "rmodm8gte_sign_1",
    "rmodskyline34_sign_1",
    "rmodskyline34_sign_2",
    "rmodskyline34_sign_3",
    "rmodskyline34_sign_4",
    "rmodskyline34_body",
    "rmodskyline34_livery",
    "rmodskyline34",
    "skyliner34_sign_1",
    "skyliner34_sign_2",
    "skyliner34_body",
    "skyliner34_livery",
    "r34_body",
    "r34_livery",
    "r34_sign_1",
    "car_sign_1",
    "car_sign_2",
    "car_sign_3",
    "car_sign_4",
    "vehicle_paint3",
    "bodyshell",
    "livery",
    "skin",
    "body",
    "chassi"
}

--- Aplica a textura no veículo SEM alterar ou estragar o modkit de tunagem do lscustoms
function ApplyCustomLiveryToVehicle(vehicle, textureUrl, modelKey)
    if not DoesEntityExist(vehicle) or not textureUrl then 
        print("^1[Custom Livery]^0 Erro: Veiculo invalido ou textura vazia!")
        return 
    end

    Citizen.CreateThread(function()
        local netId = 0
        if NetworkGetEntityIsNetworked(vehicle) then
            netId = VehToNet(vehicle)
        end

        local txdName = 'livery_txd_' .. tostring(netId) .. '_' .. tostring(GetGameTimer())
        local texName = 'livery_tex'

        local dictNames = { "rmodskyline34", "RMODSKYLINE34", "skyliner34", "r34", "vehshare" }
        if modelKey and modelKey ~= '' then
            table.insert(dictNames, string.lower(modelKey))
            table.insert(dictNames, string.upper(modelKey))
        end

        -- Limpa substituições anteriores para não deixar resquícios no cache do jogo
        for _, dName in ipairs(dictNames) do
            for _, tName in ipairs(texturesToReplace) do
                RemoveReplaceTexture(dName, tName)
            end
        end

        if activeDUIs[netId] then
            DestroyDui(activeDUIs[netId].dui)
            activeDUIs[netId] = nil
        end

        print(string.format("^3[Custom Livery]^0 Inicializando DUI para o veiculo %s...", tostring(vehicle)))

        -- Carrega através do dui_view.html local para garantir viewport 2048x2048 perfeito
        local rscName = GetCurrentResourceName()
        local isBase64 = string.sub(textureUrl, 1, 5) == "data:"
        local targetDuiUrl = string.format("nui://%s/html/dui_view.html", rscName)
        
        if not isBase64 and string.sub(textureUrl, 1, 4) == "http" then
            targetDuiUrl = string.format("nui://%s/html/dui_view.html?url=%s", rscName, textureUrl)
        end

        local duiObj = CreateDui(targetDuiUrl, 2048, 2048)

        -- Aguarda o Chromium inicializar a página
        local timeout = 0
        while not IsDuiAvailable(duiObj) and timeout < 35 do
            Citizen.Wait(40)
            timeout = timeout + 1
        end

        -- Pausa para garantir que o JavaScript da página registrou o listener de mensagens
        Citizen.Wait(250)

        -- Se for base64, envia o payload com a imagem renderizada
        if isBase64 then
            local payload = json.encode({ image = textureUrl })
            for i = 1, 2 do
                SendDuiMessage(duiObj, payload)
                Citizen.Wait(70)
            end
        end

        -- Aguarda o Chromium decodificar e desenhar os pixels na GPU
        Citizen.Wait(350)

        local duiHandle = GetDuiHandle(duiObj)
        print(string.format("^2[Custom Livery]^0 DUI gerado com sucesso! Handle: %s", tostring(duiHandle)))

        local runtimeTxd = CreateRuntimeTxd(txdName)
        CreateRuntimeTextureFromDuiHandle(runtimeTxd, texName, duiHandle)

        -- Aplica a substituição da textura no motor do GTA V
        for _, dName in ipairs(dictNames) do
            for _, tName in ipairs(texturesToReplace) do
                AddReplaceTexture(dName, tName, txdName, texName)
            end
        end

        -- Força o motor do GTA V a recarregar o shader de livery (alterna -1 para 0)
        SetVehicleLivery(vehicle, -1)
        Citizen.Wait(60)
        SetVehicleLivery(vehicle, 0)

        activeDUIs[netId] = {
            dui = duiObj,
            txd = runtimeTxd
        }

        print("^2[Custom Livery]^0 Textura personalizada aplicada com sucesso na lataria do veículo!")
    end)
end

--- Remove a estampa personalizada e restaura a pintura limpa de fábrica
function RemoveCustomLiveryFromVehicle(vehicle)
    if not DoesEntityExist(vehicle) then return end

    local netId = 0
    if NetworkGetEntityIsNetworked(vehicle) then
        netId = VehToNet(vehicle)
    end

    if activeDUIs[netId] then
        DestroyDui(activeDUIs[netId].dui)
        activeDUIs[netId] = nil
    end

    -- Remove todas as substituições de textura ativas
    local dictNames = { "rmodskyline34", "RMODSKYLINE34", "skyliner34", "r34", "vehshare" }
    for _, dName in ipairs(dictNames) do
        for _, tName in ipairs(texturesToReplace) do
            RemoveReplaceTexture(dName, tName)
        end
    end

    -- Volta a estampa para -1 (desativada / pintura de fábrica)
    SetVehicleLivery(vehicle, -1)

    print("^3[Custom Livery]^0 Estampa removida e pintura de fabrica restaurada!")
end

--- Escuta as alterações de State Bag do FiveM
AddStateBagChangeHandler('customLivery', nil, function(bagName, key, value, _unused, replicated)
    local netId = bagName:gsub('entity:', '')
    netId = tonumber(netId)
    if not netId then return end

    local entity = NetworkGetEntityFromNetworkId(netId)
    if DoesEntityExist(entity) then
        if value and value.url then
            ApplyCustomLiveryToVehicle(entity, value.url, value.model)
        else
            RemoveCustomLiveryFromVehicle(entity)
        end
    end
end)

--- Callbacks da Interface NUI
RegisterNUICallback('close', function(data, cb)
    SetNuiFocus(false, false)
    StopLiveryCamera()
    cb('ok')
end)

-- Prévia em Tempo Real na Lataria do Carro 3D
RegisterNUICallback('livePreview', function(data, cb)
    local netId = data.netId
    if not netId or netId == 0 then
        if targetVehicle and DoesEntityExist(targetVehicle) then
            netId = VehToNet(targetVehicle)
        end
    end

    if activeDUIs[netId] and activeDUIs[netId].dui then
        -- Envia os novos pixels renderizados diretamente para o DUI já conectado ao carro
        SendDuiMessage(activeDUIs[netId].dui, json.encode({ image = data.imageUrl }))
    else
        local veh = nil
        if netId and netId ~= 0 then
            veh = NetworkGetEntityFromNetworkId(netId)
        end
        if not veh or not DoesEntityExist(veh) then
            veh = targetVehicle
        end
        if veh and DoesEntityExist(veh) then
            ApplyCustomLiveryToVehicle(veh, data.imageUrl, data.model)
        end
    end

    cb('ok')
end)

-- Alternar Ângulo da Câmera 3D
RegisterNUICallback('setCamera', function(data, cb)
    if data.view then
        SetLiveryCameraView(data.view)
    end
    cb('ok')
end)

RegisterNUICallback('applyLivery', function(data, cb)
    SetNuiFocus(false, false)
    StopLiveryCamera()
    print("^2[Custom Livery Client]^0 Botao Salvar Definitivo clicado na NUI!")

    local veh = nil
    if data.netId and data.netId ~= 0 then
        veh = NetworkGetEntityFromNetworkId(data.netId)
    end
    if not veh or not DoesEntityExist(veh) then
        veh = targetVehicle or GetTargetVehicle()
    end

    if veh and DoesEntityExist(veh) then
        print(string.format("^2[Custom Livery Client]^0 Salvando textura no veiculo [NetID: %s]...", tostring(data.netId)))
        ApplyCustomLiveryToVehicle(veh, data.imageUrl, data.model)
    else
        print("^1[Custom Livery Client]^0 Erro: Nenhum veiculo encontrado para aplicar!")
        TriggerEvent('custom_livery:notify', 'vermelho', 'Veículo não encontrado!')
    end

    if string.sub(data.imageUrl, 1, 4) == "http" then
        print("^2[Custom Livery Client]^0 Sincronizando link da imagem com o servidor...")
        TriggerServerEvent('custom_livery:server:apply', data.netId, data.plate, data.model, data.imageUrl)
    else
        TriggerEvent('custom_livery:notify', 'verde', 'Estampa salva e aplicada com sucesso!')
    end

    cb('ok')
end)

RegisterNUICallback('removeLivery', function(data, cb)
    SetNuiFocus(false, false)
    StopLiveryCamera()
    print("^3[Custom Livery Client]^0 Removendo estampa do veiculo...")

    local veh = nil
    if data.netId and data.netId ~= 0 then
        veh = NetworkGetEntityFromNetworkId(data.netId)
    end
    if not veh or not DoesEntityExist(veh) then
        veh = targetVehicle or GetTargetVehicle()
    end

    if veh and DoesEntityExist(veh) then
        RemoveCustomLiveryFromVehicle(veh)
    end

    TriggerServerEvent('custom_livery:server:remove', data.netId, data.plate)
    TriggerEvent('custom_livery:notify', 'verde', 'Estampa removida e pintura original restaurada!')
    cb('ok')
end)
