Config = {}

-- Escolha o Framework ativo: 'creative' ou 'qbox'
Config.Framework = 'creative'

-- Ativar verificação de Admin (deixe true para apenas admins poderem usar; false para liberar a todos)
Config.AdminOnly = true

-- Configuração de Permissões de Administrador
Config.Permissions = {
    creative = 'Admin',
    qbox = 'admin'
}

-- Comando para abrir o painel de personalização (pode ser digitado no chat ou no F8)
Config.Command = 'liveryadmin'

-- Modelos de veículos configurados com mapeamento 2D UV completo
Config.Vehicles = {
    ['rmodskyline34'] = {
        label = 'Nissan Skyline GT-R R34',
        originalTexture = 'rmodm8gte_sign_1',
        canvasSize = 2048,
        zones = {
            ['capo'] = { label = 'Capô Dianteiro', x = 730, y = 320, width = 590, height = 460, rotation = 0 },
            ['teto'] = { label = 'Teto', x = 750, y = 920, width = 550, height = 430, rotation = 0 },
            ['porta_malas'] = { label = 'Porta-Malas / Traseira', x = 750, y = 1480, width = 550, height = 320, rotation = 0 },
            ['porta_esquerda'] = { label = 'Lateral / Porta Esquerda', x = 120, y = 680, width = 480, height = 580, rotation = 0 },
            ['porta_direita'] = { label = 'Lateral / Porta Direita', x = 1450, y = 680, width = 480, height = 580, rotation = 180 },
            ['parachoque_dianteiro'] = { label = 'Para-choque Dianteiro', x = 720, y = 120, width = 610, height = 180, rotation = 0 },
            ['completo'] = { label = 'Wrap Completo (Carro Inteiro)', x = 0, y = 0, width = 2048, height = 2048, rotation = 0 }
        }
    },
    ['skyliner34'] = {
        label = 'Nissan Skyline GT-R R34',
        originalTexture = 'skyliner34_sign_1',
        canvasSize = 2048,
        zones = {
            ['capo'] = { label = 'Capô Dianteiro', x = 730, y = 320, width = 590, height = 460, rotation = 0 },
            ['teto'] = { label = 'Teto', x = 750, y = 920, width = 550, height = 430, rotation = 0 },
            ['porta_malas'] = { label = 'Porta-Malas / Traseira', x = 750, y = 1480, width = 550, height = 320, rotation = 0 },
            ['porta_esquerda'] = { label = 'Lateral / Porta Esquerda', x = 120, y = 680, width = 480, height = 580, rotation = 0 },
            ['porta_direita'] = { label = 'Lateral / Porta Direita', x = 1450, y = 680, width = 480, height = 580, rotation = 180 },
            ['parachoque_dianteiro'] = { label = 'Para-choque Dianteiro', x = 720, y = 120, width = 610, height = 180, rotation = 0 },
            ['completo'] = { label = 'Wrap Completo (Carro Inteiro)', x = 0, y = 0, width = 2048, height = 2048, rotation = 0 }
        }
    },
    ['r34'] = {
        label = 'Nissan Skyline GT-R R34',
        originalTexture = 'r34_body',
        canvasSize = 2048,
        zones = {
            ['capo'] = { label = 'Capô Dianteiro', x = 730, y = 320, width = 590, height = 460, rotation = 0 },
            ['teto'] = { label = 'Teto', x = 750, y = 920, width = 550, height = 430, rotation = 0 },
            ['porta_malas'] = { label = 'Porta-Malas / Traseira', x = 750, y = 1480, width = 550, height = 320, rotation = 0 },
            ['porta_esquerda'] = { label = 'Lateral / Porta Esquerda', x = 120, y = 680, width = 480, height = 580, rotation = 0 },
            ['porta_direita'] = { label = 'Lateral / Porta Direita', x = 1450, y = 680, width = 480, height = 580, rotation = 180 },
            ['parachoque_dianteiro'] = { label = 'Para-choque Dianteiro', x = 720, y = 120, width = 610, height = 180, rotation = 0 },
            ['completo'] = { label = 'Wrap Completo (Carro Inteiro)', x = 0, y = 0, width = 2048, height = 2048, rotation = 0 }
        }
    },
    ['rmodsupra'] = {
        label = 'Toyota Supra MK4 (JZA80)',
        originalTexture = 'supra_sign_1',
        canvasSize = 2048,
        zones = {
            ['capo'] = { label = 'Capô Curvado', x = 740, y = 310, width = 570, height = 480, rotation = 0 },
            ['teto'] = { label = 'Teto Aerodinâmico', x = 760, y = 930, width = 530, height = 410, rotation = 0 },
            ['porta_malas'] = { label = 'Porta-Malas & Hoop Wing', x = 760, y = 1490, width = 530, height = 320, rotation = 0 },
            ['porta_esquerda'] = { label = 'Lateral Esquerda', x = 130, y = 680, width = 470, height = 580, rotation = 0 },
            ['porta_direita'] = { label = 'Lateral Direita', x = 1450, y = 680, width = 470, height = 580, rotation = 180 },
            ['parachoque_dianteiro'] = { label = 'Para-choque Frontal', x = 730, y = 110, width = 590, height = 190, rotation = 0 },
            ['completo'] = { label = 'Wrap Completo (Carro Inteiro)', x = 0, y = 0, width = 2048, height = 2048, rotation = 0 }
        }
    },
    ['rmod911'] = {
        label = 'Porsche 911 GT3 RS',
        originalTexture = 'gt3rs_sign_1',
        canvasSize = 2048,
        zones = {
            ['capo'] = { label = 'Capô c/ Extratores', x = 740, y = 330, width = 570, height = 450, rotation = 0 },
            ['teto'] = { label = 'Teto Dupla Bolha', x = 750, y = 910, width = 550, height = 420, rotation = 0 },
            ['porta_malas'] = { label = 'Tampa Traseira & Asa Swan', x = 750, y = 1470, width = 550, height = 330, rotation = 0 },
            ['porta_esquerda'] = { label = 'Lateral & Saia Esquerda', x = 120, y = 670, width = 480, height = 580, rotation = 0 },
            ['porta_direita'] = { label = 'Lateral & Saia Direita', x = 1450, y = 670, width = 480, height = 580, rotation = 180 },
            ['parachoque_dianteiro'] = { label = 'Splitter & Para-choque Frontal', x = 730, y = 130, width = 590, height = 190, rotation = 0 },
            ['completo'] = { label = 'Wrap Completo (Carro Inteiro)', x = 0, y = 0, width = 2048, height = 2048, rotation = 0 }
        }
    },
    ['rmodm8gte'] = {
        label = 'BMW M8 GTE / M4 Comp',
        originalTexture = 'rmodm8gte_sign_1',
        canvasSize = 2048,
        zones = {
            ['capo'] = { label = 'Capô Powerdome', x = 720, y = 300, width = 610, height = 480, rotation = 0 },
            ['teto'] = { label = 'Teto de Fibra de Carbono', x = 740, y = 900, width = 570, height = 440, rotation = 0 },
            ['porta_malas'] = { label = 'Porta-Malas GT Race', x = 740, y: 1460, width = 570, height = 340, rotation = 0 },
            ['porta_esquerda'] = { label = 'Lateral Widebody Esquerda', x = 110, y = 660, width = 490, height = 590, rotation = 0 },
            ['porta_direita'] = { label = 'Lateral Widebody Direita', x = 1450, y = 660, width = 490, height = 590, rotation = 180 },
            ['parachoque_dianteiro'] = { label = 'Frente GTE c/ Canards', x = 710, y = 100, width = 630, height = 190, rotation = 0 },
            ['completo'] = { label = 'Wrap Completo (Carro Inteiro)', x = 0, y = 0, width = 2048, height = 2048, rotation = 0 }
        }
    },
    ['rx7tunable'] = {
        label = 'Mazda RX-7 (FD3S)',
        originalTexture = 'rx7_sign_1',
        canvasSize = 2048,
        zones = {
            ['capo'] = { label = 'Capô Rebaixado', x = 730, y = 320, width = 590, height = 470, rotation = 0 },
            ['teto'] = { label = 'Teto Arredondado', x = 750, y = 910, width = 550, height = 410, rotation = 0 },
            ['porta_malas'] = { label = 'Traseira c/ Lanternas Fumê', x = 750, y = 1460, width = 550, height = 320, rotation = 0 },
            ['porta_esquerda'] = { label = 'Porta Esquerda Fluida', x = 120, y = 670, width = 480, height = 570, rotation = 0 },
            ['porta_direita'] = { label = 'Porta Direita Fluida', x = 1450, y = 670, width = 480, height = 570, rotation = 180 },
            ['parachoque_dianteiro'] = { label = 'Frente com Entradas Rotativas', x = 720, y = 120, width = 610, height = 180, rotation = 0 },
            ['completo'] = { label = 'Wrap Completo (Carro Inteiro)', x = 0, y = 0, width = 2048, height = 2048, rotation = 0 }
        }
    }
}
