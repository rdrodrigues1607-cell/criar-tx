-- Definição universal de 'async' caso não tenha sido carregado pelo ambiente
if not _G.async then
    local function wait(self)
        local rets = Citizen.Await(self.p)
        if not rets and self.r then rets = self.r end
        return table.unpack(rets or {}, 1, 10)
    end

    local function areturn(self, ...)
        self.r = {...}
        self.p:resolve(self.r)
    end

    function _G.async(func)
        if func then
            Citizen.CreateThreadNow(func)
        else
            return setmetatable({ wait = wait, p = promise.new() }, { __call = areturn })
        end
    end
end

-- Carregador universal da função 'module' do vRP
if not _G.module then
    function _G.module(rsc, path)
        if path == nil then
            path = rsc
            rsc = "vrp"
        end
        local file = LoadResourceFile(rsc, path .. ".lua")
        if file then
            local f, err = load(file, "@" .. rsc .. "/" .. path .. ".lua")
            if f then
                return f()
            else
                print("^1[Custom Livery Error]^0 Erro ao compilar " .. rsc .. "/" .. path .. ": " .. tostring(err))
            end
        end
        return nil
    end
end

local vRP = nil

-- Inicialização segura do Framework (Creative vRP / WorkStore ou Qbox)
Citizen.CreateThread(function()
    Citizen.Wait(100)
    
    if GetResourceState('vrp') == 'started' then
        pcall(function()
            local Proxy = module("vrp", "lib/Proxy")
            if Proxy then
                vRP = Proxy.getInterface("vRP")
                print("^2[Custom Livery]^0 Conectado com sucesso ao Creative vRP / WorkStore!")
            end
        end)
    elseif GetResourceState('qbx_core') == 'started' then
        print("^2[Custom Livery]^0 Conectado com sucesso ao Qbox!")
    end
end)

--- Execução segura de queries MySQL (compatível com oxmysql e mysql-async)
local function ExecuteSQL(query, params, cb)
    if exports['oxmysql'] then
        exports['oxmysql']:execute(query, params, cb)
    elseif MySQL then
        MySQL.Async.execute(query, params, cb)
    end
end

local function FetchSQL(query, params, cb)
    if exports['oxmysql'] then
        exports['oxmysql']:execute(query, params, cb)
    elseif MySQL then
        MySQL.Async.fetchAll(query, params, cb)
    end
end

--- Cria a tabela no banco de dados automaticamente na inicialização
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end

    Citizen.CreateThread(function()
        Citizen.Wait(1000)
        local createTableQuery = [[
            CREATE TABLE IF NOT EXISTS `vehicle_custom_liveries` (
                `plate` VARCHAR(12) NOT NULL,
                `model` VARCHAR(50) NOT NULL,
                `texture_url` LONGTEXT NOT NULL,
                `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                PRIMARY KEY (`plate`)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
        ]]
        ExecuteSQL(createTableQuery, {}, function()
            print("^2[Custom Livery]^0 Tabela 'vehicle_custom_liveries' pronta no Banco de Dados!")
        end)
    end)
end)

--- Função universal para checar se o jogador é Admin (Compatível com WorkStore, Creative e Qbox)
function CheckAdminPermission(source)
    if Config.AdminOnly == false then
        return true
    end

    -- 1. Base WorkStore / Creative Network (usa Passport e HasGroup)
    if vRP then
        local Passport = nil
        if vRP.Passport then
            Passport = vRP.Passport(source)
        elseif vRP.getUserId then
            Passport = vRP.getUserId(source)
        end

        if Passport then
            -- Verifica no formato WorkStore Tema Próprio
            if vRP.HasGroup then
                if vRP.HasGroup(Passport, "Admin", 1) 
                    or vRP.HasGroup(Passport, "Admin") 
                    or vRP.HasGroup(Passport, "Staff", 1) 
                    or vRP.HasGroup(Passport, "Owner", 1) 
                    or vRP.HasGroup(Passport, "Owner") 
                    or vRP.HasGroup(Passport, "Fundador", 1)
                    or vRP.HasGroup(Passport, Config.Permissions.creative) then
                    print(string.format("^2[Custom Livery]^0 Admin autorizado via WorkStore HasGroup! Passport: %s", Passport))
                    return true
                end
            end

            if vRP.HasPermission then
                if vRP.HasPermission(Passport, "Admin") or vRP.HasPermission(Passport, Config.Permissions.creative) then
                    print(string.format("^2[Custom Livery]^0 Admin autorizado via HasPermission! Passport: %s", Passport))
                    return true
                end
            end

            -- Verifica no formato vRP tradicional
            if vRP.hasPermission then
                if vRP.hasPermission(Passport, Config.Permissions.creative) 
                    or vRP.hasPermission(Passport, "Admin") 
                    or vRP.hasPermission(Passport, "admin.permissao") then
                    print(string.format("^2[Custom Livery]^0 Admin autorizado via hasPermission! ID: %s", Passport))
                    return true
                end
            end

            if vRP.hasGroup then
                if vRP.hasGroup(Passport, "admin") or vRP.hasGroup(Passport, "Admin") or vRP.hasGroup(Passport, "owner") then
                    print(string.format("^2[Custom Livery]^0 Admin autorizado via hasGroup! ID: %s", Passport))
                    return true
                end
            end
            
            print(string.format("^3[Custom Livery]^0 Passport %s tentou usar o comando mas nao possui cargo de Admin.", Passport))
        else
            print(string.format("^1[Custom Livery]^0 Nao foi possivel obter Passport/UserId para source %s", source))
        end
    end

    -- 2. Base Qbox
    if exports['qbx_core'] and exports['qbx_core'].HasPermission then
        if exports['qbx_core']:HasPermission(source, Config.Permissions.qbox) 
            or exports['qbx_core']:HasPermission(source, 'admin') 
            or exports['qbx_core']:HasPermission(source, 'god') then
            print(string.format("^2[Custom Livery]^0 Admin autorizado via Qbox! Source: %s", source))
            return true
        end
    end

    -- 3. ACE Permissions (fallback nativo)
    if IsPlayerAceAllowed(source, 'command.' .. Config.Command) or IsPlayerAceAllowed(source, Config.Permissions.qbox) then
        return true
    end

    return false
end

--- Função para acionar abertura do painel
local function ProcessOpenCommand(source)
    local src = source
    if src == 0 then
        print("^3[Custom Livery]^0 Este comando deve ser executado dentro do jogo por um jogador.")
        return
    end

    print(string.format("^3[Custom Livery]^0 Processando comando /%s para source %s...", Config.Command, src))

    if not CheckAdminPermission(src) then
        TriggerClientEvent('custom_livery:notify', src, 'vermelho', 'Acesso negado! Permissão exclusiva para Administradores.')
        return
    end

    print(string.format("^2[Custom Livery]^0 Jogador %s liberado! Enviando evento para abrir NUI...", src))
    TriggerClientEvent('custom_livery:openUI', src)
end

-- Registra comando no servidor
RegisterCommand(Config.Command, function(source, args, rawCommand)
    ProcessOpenCommand(source)
end, false)

-- Recebe pedido do cliente (caso o comando seja digitado no client/F8)
RegisterNetEvent('custom_livery:server:requestOpen', function()
    local src = source
    ProcessOpenCommand(src)
end)

--- Evento do servidor para aplicar a textura, salvar no banco e sincronizar
RegisterNetEvent('custom_livery:server:apply', function(netId, plate, vehicleModel, textureUrl)
    local src = source
    if not CheckAdminPermission(src) then
        print(string.format("^1[Custom Livery Warning]^0 Jogador %s tentou aplicar textura sem permissao de admin!", src))
        return
    end

    local vehicle = NetworkGetEntityFromNetworkId(netId)
    if not DoesEntityExist(vehicle) then
        TriggerClientEvent('custom_livery:notify', src, 'vermelho', 'Veículo não encontrado ou fora de alcance.')
        return
    end

    local cleanPlate = string.gsub(plate, "%s+", "")

    -- 1. Salva no Banco de Dados vinculado à placa
    local saveQuery = [[
        INSERT INTO `vehicle_custom_liveries` (`plate`, `model`, `texture_url`)
        VALUES (@plate, @model, @texture_url)
        ON DUPLICATE KEY UPDATE `texture_url` = @texture_url, `model` = @model;
    ]]

    ExecuteSQL(saveQuery, {
        ['@plate'] = cleanPlate,
        ['@model'] = vehicleModel,
        ['@texture_url'] = textureUrl
    }, function()
        print(string.format("^2[Custom Livery DB]^0 Textura salva no banco para a placa [%s]", cleanPlate))
    end)

    -- 2. Sincroniza em tempo real com TODOS os jogadores conectados usando State Bag do FiveM
    local liveryData = {
        model = vehicleModel,
        url = textureUrl,
        plate = cleanPlate,
        appliedAt = os.time()
    }

    Entity(vehicle).state:set('customLivery', liveryData, true)

    TriggerClientEvent('custom_livery:notify', src, 'verde', 'Textura personalizada salva e aplicada com sucesso!')
    print(string.format("^2[Custom Livery]^0 Admin %s aplicou nova estampa no veiculo [Placa: %s, Modelo: %s]", src, cleanPlate, vehicleModel))
end)

--- Evento do servidor para remover a estampa do veículo e do banco de dados
RegisterNetEvent('custom_livery:server:remove', function(netId, plate)
    local src = source
    if not CheckAdminPermission(src) then
        return
    end

    local vehicle = NetworkGetEntityFromNetworkId(netId)
    local cleanPlate = string.gsub(plate, "%s+", "")

    -- Remove do Banco de Dados
    local deleteQuery = "DELETE FROM `vehicle_custom_liveries` WHERE `plate` = @plate"
    ExecuteSQL(deleteQuery, { ['@plate'] = cleanPlate }, function()
        print(string.format("^3[Custom Livery DB]^0 Estampa removida do banco para a placa [%s]", cleanPlate))
    end)

    -- Limpa a State Bag para todos os jogadores conectados
    if DoesEntityExist(vehicle) then
        Entity(vehicle).state:set('customLivery', nil, true)
    end

    TriggerClientEvent('custom_livery:notify', src, 'verde', 'Estampa removida e pintura de fábrica restaurada!')
    print(string.format("^3[Custom Livery]^0 Admin %s removeu a estampa do veiculo [Placa: %s]", src, cleanPlate))
end)

--- Evento para restaurar a estampa quando um carro spawna da garagem
RegisterNetEvent('custom_livery:server:requestVehicleLivery', function(netId, plate)
    local src = source
    local vehicle = NetworkGetEntityFromNetworkId(netId)
    if not DoesEntityExist(vehicle) then return end

    local cleanPlate = string.gsub(plate, "%s+", "")

    local selectQuery = "SELECT `model`, `texture_url` FROM `vehicle_custom_liveries` WHERE `plate` = @plate LIMIT 1"
    FetchSQL(selectQuery, { ['@plate'] = cleanPlate }, function(result)
        if result and result[1] then
            local liveryData = {
                model = result[1].model,
                url = result[1].texture_url,
                plate = cleanPlate,
                appliedAt = os.time()
            }
            Entity(vehicle).state:set('customLivery', liveryData, true)
        end
    end)
end)
