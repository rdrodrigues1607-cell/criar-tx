let currentVehicle = null;
let currentZones = {};
let loadedImage = null;

// Configurações do Molde Blueprint 2D
let showBlueprint = true;
let blueprintAlpha = 0.75;

// Estado de transformação da estampa (movimentação, rotação e escala)
let transform = {
    x: 0,
    y: 0,
    scale: 1.0,
    rotation: 0,
    flipH: false,
    flipV: false
};

const app = document.getElementById('app');
const canvas = document.getElementById('uvCanvas');
const ctx = canvas.getContext('2d');

const vehName = document.getElementById('vehName');
const vehPlate = document.getElementById('vehPlate');
const zoneSelect = document.getElementById('zoneSelect');
const zonePills = document.getElementById('zonePills');
const imgUrlInput = document.getElementById('imgUrl');
const dropzoneText = document.getElementById('dropzoneText');
const baseColorInput = document.getElementById('baseColor');
const colorHex = document.getElementById('colorHex');

const btnClose = document.getElementById('btnClose');
const btnApply = document.getElementById('btnApply');
const btnRemove = document.getElementById('btnRemove');
const btnSample = document.getElementById('btnSample');

// Controles de Molde 2D
const btnToggleBlueprint = document.getElementById('btnToggleBlueprint');
const blueprintBadge = document.getElementById('blueprintBadge');
const blueprintOpacity = document.getElementById('blueprintOpacity');
const opacityVal = document.getElementById('opacityVal');

// Controles de Transformação
const rotRange = document.getElementById('rotRange');
const rotVal = document.getElementById('rotVal');
const btnRotMinus90 = document.getElementById('btnRotMinus90');
const btnRotPlus90 = document.getElementById('btnRotPlus90');
const btnRot180 = document.getElementById('btnRot180');
const btnRotZero = document.getElementById('btnRotZero');

const scaleRange = document.getElementById('scaleRange');
const scaleVal = document.getElementById('scaleVal');
const btnScaleDown = document.getElementById('btnScaleDown');
const btnScaleUp = document.getElementById('btnScaleUp');
const btnScale100 = document.getElementById('btnScale100');
const btnFlipH = document.getElementById('btnFlipH');

const posXRange = document.getElementById('posXRange');
const posYRange = document.getElementById('posYRange');
const posVal = document.getElementById('posVal');
const btnMoveUp = document.getElementById('btnMoveUp');
const btnMoveDown = document.getElementById('btnMoveDown');
const btnMoveLeft = document.getElementById('btnMoveLeft');
const btnMoveRight = document.getElementById('btnMoveRight');
const btnCenterPos = document.getElementById('btnCenterPos');
const btnResetTransform = document.getElementById('btnResetTransform');

// Toggle do Molde 2D
btnToggleBlueprint.addEventListener('click', () => {
    showBlueprint = !showBlueprint;
    btnToggleBlueprint.classList.toggle('active', showBlueprint);
    blueprintBadge.textContent = showBlueprint ? 'MOLDE ATIVO' : 'MOLDE OCULTO';
    blueprintBadge.style.color = showBlueprint ? '#10b981' : '#94a3b8';
    blueprintBadge.style.borderColor = showBlueprint ? 'rgba(16, 185, 129, 0.3)' : '#334155';
    renderCanvas(true);
});

// Opacidade do Molde 2D
blueprintOpacity.addEventListener('input', (e) => {
    blueprintAlpha = parseInt(e.target.value) / 100;
    opacityVal.textContent = `${e.target.value}%`;
    renderCanvas(true);
});

// Atualiza a cor de fundo da lataria
baseColorInput.addEventListener('input', (e) => {
    colorHex.textContent = e.target.value;
    renderCanvas(true);
});

// Imagem de Teste Rápido
if (btnSample) {
    btnSample.addEventListener('click', () => {
        const sampleUrl = 'https://i.imgur.com/2m65Vz5.png';
        imgUrlInput.value = sampleUrl;
        loadImageFromUrl(sampleUrl);
    });
}

// Reseta transformação para o padrão centralizado
function resetTransform() {
    transform.x = 0;
    transform.y = 0;
    transform.scale = 1.0;
    transform.rotation = 0;
    transform.flipH = false;
    transform.flipV = false;
    updateUIControls();
    renderCanvas(true);
}

// Atualiza os valores visuais dos controles (badges e sliders)
function updateUIControls() {
    let normRot = Math.round(transform.rotation);
    while (normRot > 180) normRot -= 360;
    while (normRot < -180) normRot -= 360;
    transform.rotation = normRot;
    
    rotRange.value = normRot;
    rotVal.textContent = `${normRot}°`;

    const scalePct = Math.round(transform.scale * 100);
    scaleRange.value = scalePct;
    scaleVal.textContent = `${scalePct}%`;

    posXRange.value = transform.x;
    posYRange.value = transform.y;
    posVal.textContent = `X: ${transform.x} | Y: ${transform.y}`;

    btnFlipH.style.background = transform.flipH ? '#0284c7' : '';
    btnFlipH.style.color = transform.flipH ? '#ffffff' : '';
}

// Eventos de Rotação
rotRange.addEventListener('input', (e) => {
    transform.rotation = parseInt(e.target.value);
    rotVal.textContent = `${transform.rotation}°`;
    renderCanvas(true);
});

btnRotMinus90.addEventListener('click', () => {
    transform.rotation -= 90;
    updateUIControls();
    renderCanvas(true);
});

btnRotPlus90.addEventListener('click', () => {
    transform.rotation += 90;
    updateUIControls();
    renderCanvas(true);
});

btnRot180.addEventListener('click', () => {
    transform.rotation = 180;
    updateUIControls();
    renderCanvas(true);
});

btnRotZero.addEventListener('click', () => {
    transform.rotation = 0;
    updateUIControls();
    renderCanvas(true);
});

// Eventos de Escala / Tamanho
scaleRange.addEventListener('input', (e) => {
    transform.scale = parseInt(e.target.value) / 100;
    scaleVal.textContent = `${e.target.value}%`;
    renderCanvas(true);
});

btnScaleDown.addEventListener('click', () => {
    transform.scale = Math.max(0.1, Math.round((transform.scale - 0.1) * 100) / 100);
    updateUIControls();
    renderCanvas(true);
});

btnScaleUp.addEventListener('click', () => {
    transform.scale = Math.min(3.0, Math.round((transform.scale + 0.1) * 100) / 100);
    updateUIControls();
    renderCanvas(true);
});

btnScale100.addEventListener('click', () => {
    transform.scale = 1.0;
    updateUIControls();
    renderCanvas(true);
});

btnFlipH.addEventListener('click', () => {
    transform.flipH = !transform.flipH;
    updateUIControls();
    renderCanvas(true);
});

// Eventos de Posição (Sliders e D-Pad)
posXRange.addEventListener('input', (e) => {
    transform.x = parseInt(e.target.value);
    posVal.textContent = `X: ${transform.x} | Y: ${transform.y}`;
    renderCanvas(true);
});

posYRange.addEventListener('input', (e) => {
    transform.y = parseInt(e.target.value);
    posVal.textContent = `X: ${transform.x} | Y: ${transform.y}`;
    renderCanvas(true);
});

btnMoveUp.addEventListener('click', () => {
    transform.y -= 30;
    updateUIControls();
    renderCanvas(true);
});

btnMoveDown.addEventListener('click', () => {
    transform.y += 30;
    updateUIControls();
    renderCanvas(true);
});

btnMoveLeft.addEventListener('click', () => {
    transform.x -= 30;
    updateUIControls();
    renderCanvas(true);
});

btnMoveRight.addEventListener('click', () => {
    transform.x += 30;
    updateUIControls();
    renderCanvas(true);
});

btnCenterPos.addEventListener('click', () => {
    transform.x = 0;
    transform.y = 0;
    updateUIControls();
    renderCanvas(true);
});

btnResetTransform.addEventListener('click', resetTransform);

// Interação Direta com Mouse no Canvas (Arrastar e Zoom)
let isDragging = false;
let startMouseX = 0;
let startMouseY = 0;
let startTransformX = 0;
let startTransformY = 0;

canvas.addEventListener('mousedown', (e) => {
    if (!loadedImage) return;
    isDragging = true;
    startMouseX = e.clientX;
    startMouseY = e.clientY;
    startTransformX = transform.x;
    startTransformY = transform.y;
});

window.addEventListener('mousemove', (e) => {
    if (!isDragging || !loadedImage) return;
    const rect = canvas.getBoundingClientRect();
    const scaleFactor = 2048 / rect.width;

    const deltaX = (e.clientX - startMouseX) * scaleFactor;
    const deltaY = (e.clientY - startMouseY) * scaleFactor;

    transform.x = Math.round(startTransformX + deltaX);
    transform.y = Math.round(startTransformY + deltaY);

    updateUIControls();
    renderCanvas(true);
});

window.addEventListener('mouseup', () => {
    if (isDragging) {
        isDragging = false;
    }
});

// Zoom / Redimensionar com a roda do mouse sobre o molde
canvas.addEventListener('wheel', (e) => {
    if (!loadedImage) return;
    e.preventDefault();

    const zoomStep = 0.05;
    if (e.deltaY < 0) {
        transform.scale = Math.min(3.0, Math.round((transform.scale + zoomStep) * 100) / 100);
    } else {
        transform.scale = Math.max(0.1, Math.round((transform.scale - zoomStep) * 100) / 100);
    }

    updateUIControls();
    renderCanvas(true);
}, { passive: false });

// Pills de seleção rápida de peças da carroceria
if (zonePills) {
    zonePills.addEventListener('click', (e) => {
        const btn = e.target.closest('.pill-btn');
        if (!btn) return;
        const targetZone = btn.dataset.zone;
        if (targetZone && zoneSelect.value !== targetZone) {
            zoneSelect.value = targetZone;
            updatePillSelection(targetZone);
            resetTransform();
        }
    });
}

function updatePillSelection(selectedKey) {
    if (!zonePills) return;
    zonePills.querySelectorAll('.pill-btn').forEach(b => {
        b.classList.toggle('active', b.dataset.zone === selectedKey);
    });
}

zoneSelect.addEventListener('change', (e) => {
    updatePillSelection(e.target.value);
    resetTransform();
});

// ==========================================
// DESENHO VETORIAL DO MOLDE 2D DO SKYLINE R34
// ==========================================
function drawVehicleBlueprint(ctx, size, selectedZoneKey, alpha) {
    ctx.save();
    ctx.globalAlpha = alpha;

    const lineColor = 'rgba(56, 189, 248, 0.7)';
    const dimLineColor = 'rgba(255, 255, 255, 0.25)';
    const glowFill = 'rgba(56, 189, 248, 0.16)';
    const textBg = 'rgba(11, 14, 23, 0.85)';

    ctx.lineWidth = 2.5;

    // ----------------------------------------------------
    // 1. COLUNA CENTRAL: VISTA SUPERIOR (CENITAL)
    // ----------------------------------------------------

    // --- PARA-CHOQUE DIANTEIRO (Y: 100 a 290) ---
    const isBumperActive = selectedZoneKey === 'parachoque_dianteiro' || selectedZoneKey === 'completo';
    if (isBumperActive) {
        ctx.fillStyle = glowFill;
        ctx.fillRect(720, 110, 608, 190);
    }
    ctx.strokeStyle = isBumperActive ? '#38bdf8' : lineColor;
    ctx.strokeRect(720, 110, 608, 190);

    // Detalhes do Para-choque: Intercooler e Dutos R34
    ctx.strokeStyle = dimLineColor;
    ctx.strokeRect(880, 140, 288, 120); // Entrada do intercooler
    ctx.strokeRect(740, 160, 100, 80);  // Duto esquerdo de freio
    ctx.strokeRect(1208, 160, 100, 80); // Duto direito de freio

    // Faróis angulados característicos do R34
    ctx.beginPath();
    ctx.moveTo(730, 270); ctx.lineTo(840, 270); ctx.lineTo(860, 310); ctx.lineTo(730, 310); ctx.closePath();
    ctx.stroke();
    ctx.beginPath();
    ctx.moveTo(1318, 270); ctx.lineTo(1208, 270); ctx.lineTo(1188, 310); ctx.lineTo(1318, 310); ctx.closePath();
    ctx.stroke();

    // Etiqueta Para-choque
    drawZoneBadge(ctx, 1024, 200, "PARA-CHOQUE DIANTEIRO", isBumperActive);

    // --- CAPÔ DIANTEIRO (Y: 310 a 780) ---
    const isHoodActive = selectedZoneKey === 'capo' || selectedZoneKey === 'completo';
    ctx.beginPath();
    ctx.moveTo(730, 320);
    ctx.lineTo(1318, 320);
    ctx.lineTo(1350, 780);
    ctx.lineTo(698, 780);
    ctx.closePath();

    if (isHoodActive) {
        ctx.fillStyle = glowFill;
        ctx.fill();
    }
    ctx.strokeStyle = isHoodActive ? '#38bdf8' : lineColor;
    ctx.lineWidth = isHoodActive ? 3.5 : 2.5;
    ctx.stroke();

    // Vincos agressivos do Capô do Skyline GT-R
    ctx.lineWidth = 1.5;
    ctx.strokeStyle = dimLineColor;
    ctx.beginPath();
    ctx.moveTo(850, 330); ctx.lineTo(880, 770);
    ctx.moveTo(1198, 330); ctx.lineTo(1168, 770);
    ctx.stroke();

    // Duto de ar NACA (V-Spec II) no capô
    ctx.beginPath();
    ctx.moveTo(810, 480); ctx.lineTo(840, 430); ctx.lineTo(870, 480); ctx.closePath();
    ctx.stroke();

    // Etiqueta Capô
    drawZoneBadge(ctx, 1024, 550, "CAPÔ DIANTEIRO (SKYLINE R34)", isHoodActive);

    // --- PARA-BRISA (Y: 790 a 920) ---
    ctx.strokeStyle = dimLineColor;
    ctx.beginPath();
    ctx.moveTo(710, 790); ctx.lineTo(1338, 790);
    ctx.lineTo(1310, 920); ctx.lineTo(738, 920);
    ctx.closePath();
    ctx.stroke();

    // --- TETO (ROOF) (Y: 920 a 1350) ---
    const isRoofActive = selectedZoneKey === 'teto' || selectedZoneKey === 'completo';
    ctx.beginPath();
    ctx.moveTo(740, 920);
    ctx.lineTo(1308, 920);
    ctx.lineTo(1308, 1350);
    ctx.lineTo(740, 1350);
    ctx.closePath();

    if (isRoofActive) {
        ctx.fillStyle = glowFill;
        ctx.fill();
    }
    ctx.strokeStyle = isRoofActive ? '#38bdf8' : lineColor;
    ctx.lineWidth = isRoofActive ? 3.5 : 2.5;
    ctx.stroke();

    // Canais aerodinâmicos do teto
    ctx.lineWidth = 1.5;
    ctx.strokeStyle = dimLineColor;
    ctx.beginPath();
    ctx.moveTo(860, 930); ctx.lineTo(860, 1340);
    ctx.moveTo(1188, 930); ctx.lineTo(1188, 1340);
    ctx.stroke();

    // Etiqueta Teto
    drawZoneBadge(ctx, 1024, 1135, "TETO / ROOF", isRoofActive);

    // --- VIDRO TRASEIRO (Y: 1350 a 1480) ---
    ctx.strokeStyle = dimLineColor;
    ctx.beginPath();
    ctx.moveTo(740, 1350); ctx.lineTo(1308, 1350);
    ctx.lineTo(1300, 1480); ctx.lineTo(748, 1480);
    ctx.closePath();
    ctx.stroke();

    // --- PORTA-MALAS & AEROFÓLIO GTR (Y: 1480 a 1800) ---
    const isTrunkActive = selectedZoneKey === 'porta_malas' || selectedZoneKey === 'completo';
    ctx.beginPath();
    ctx.moveTo(748, 1480);
    ctx.lineTo(1300, 1480);
    ctx.lineTo(1318, 1780);
    ctx.lineTo(730, 1780);
    ctx.closePath();

    if (isTrunkActive) {
        ctx.fillStyle = glowFill;
        ctx.fill();
    }
    ctx.strokeStyle = isTrunkActive ? '#38bdf8' : lineColor;
    ctx.lineWidth = isTrunkActive ? 3.5 : 2.5;
    ctx.stroke();

    // Aerofólio Traseiro GT-R (Wing)
    ctx.strokeStyle = isTrunkActive ? '#38bdf8' : lineColor;
    ctx.strokeRect(690, 1720, 668, 55);

    // Lanternas redondas clássicas do Skyline R34 (2 grandes, 2 menores)
    ctx.strokeStyle = 'rgba(239, 68, 68, 0.7)'; // Vermelho clássico GT-R
    ctx.lineWidth = 2;
    // Esquerda
    ctx.beginPath(); ctx.arc(775, 1795, 20, 0, Math.PI * 2); ctx.stroke();
    ctx.beginPath(); ctx.arc(825, 1795, 15, 0, Math.PI * 2); ctx.stroke();
    // Direita
    ctx.beginPath(); ctx.arc(1273, 1795, 20, 0, Math.PI * 2); ctx.stroke();
    ctx.beginPath(); ctx.arc(1223, 1795, 15, 0, Math.PI * 2); ctx.stroke();

    // Etiqueta Porta-Malas
    drawZoneBadge(ctx, 1024, 1610, "PORTA-MALAS / TRASEIRA", isTrunkActive);

    // --- PARA-CHOQUE TRASEIRO (Y: 1810 a 1980) ---
    ctx.strokeStyle = lineColor;
    ctx.strokeRect(720, 1820, 608, 140);
    drawZoneBadge(ctx, 1024, 1890, "PARA-CHOQUE TRASEIRO", selectedZoneKey === 'completo');

    // ----------------------------------------------------
    // 2. COLUNA ESQUERDA: PERFIL LATERAL ESQUERDO (X: 100 a 600)
    // ----------------------------------------------------
    const isLeftActive = selectedZoneKey === 'porta_esquerda' || selectedZoneKey === 'completo';

    ctx.save();
    ctx.beginPath();
    ctx.rect(100, 260, 520, 1520);
    if (isLeftActive) {
        ctx.fillStyle = glowFill;
        ctx.fill();
    }
    ctx.strokeStyle = isLeftActive ? '#38bdf8' : lineColor;
    ctx.lineWidth = isLeftActive ? 3.5 : 2.5;
    ctx.stroke();

    // Contorno da Porta Esquerda do R34
    ctx.strokeStyle = isLeftActive ? '#38bdf8' : lineColor;
    ctx.lineWidth = 3;
    ctx.strokeRect(120, 680, 480, 580);

    // Maçaneta e retrovisor da porta esquerda
    ctx.fillStyle = isLeftActive ? '#38bdf8' : dimLineColor;
    ctx.fillRect(160, 740, 45, 12); // Maçaneta
    ctx.strokeRect(520, 690, 65, 35); // Retrovisor esquerdo

    // Caixa de roda dianteira esquerda
    ctx.strokeStyle = dimLineColor;
    ctx.lineWidth = 2;
    ctx.beginPath();
    ctx.arc(360, 460, 95, 0, Math.PI);
    ctx.stroke();

    // Caixa de roda traseira esquerda
    ctx.beginPath();
    ctx.arc(360, 1540, 95, 0, Math.PI);
    ctx.stroke();

    drawZoneBadge(ctx, 360, 970, "PORTA ESQUERDA", isLeftActive);
    drawZoneBadge(ctx, 360, 360, "PARA-LAMA DIANT. ESQ.", isLeftActive);
    drawZoneBadge(ctx, 360, 1700, "TRASEIRA ESQUERDA", isLeftActive);
    ctx.restore();

    // ----------------------------------------------------
    // 3. COLUNA DIREITA: PERFIL LATERAL DIREITO (X: 1428 a 1948)
    // ----------------------------------------------------
    const isRightActive = selectedZoneKey === 'porta_direita' || selectedZoneKey === 'completo';

    ctx.save();
    ctx.beginPath();
    ctx.rect(1428, 260, 520, 1520);
    if (isRightActive) {
        ctx.fillStyle = glowFill;
        ctx.fill();
    }
    ctx.strokeStyle = isRightActive ? '#38bdf8' : lineColor;
    ctx.lineWidth = isRightActive ? 3.5 : 2.5;
    ctx.stroke();

    // Contorno da Porta Direita do R34
    ctx.strokeStyle = isRightActive ? '#38bdf8' : lineColor;
    ctx.lineWidth = 3;
    ctx.strokeRect(1448, 680, 480, 580);

    // Maçaneta e retrovisor da porta direita
    ctx.fillStyle = isRightActive ? '#38bdf8' : dimLineColor;
    ctx.fillRect(1843, 740, 45, 12); // Maçaneta
    ctx.strokeRect(1463, 690, 65, 35); // Retrovisor direito

    // Caixa de roda dianteira direita
    ctx.strokeStyle = dimLineColor;
    ctx.lineWidth = 2;
    ctx.beginPath();
    ctx.arc(1688, 460, 95, 0, Math.PI);
    ctx.stroke();

    // Caixa de roda traseira direita
    ctx.beginPath();
    ctx.arc(1688, 1540, 95, 0, Math.PI);
    ctx.stroke();

    drawZoneBadge(ctx, 1688, 970, "PORTA DIREITA", isRightActive);
    drawZoneBadge(ctx, 1688, 360, "PARA-LAMA DIANT. DIR.", isRightActive);
    drawZoneBadge(ctx, 1688, 1700, "TRASEIRA DIREITA", isRightActive);
    ctx.restore();

    ctx.restore();
}

// Desenha caixa de texto destacada para o molde
function drawZoneBadge(ctx, x, y, text, isActive) {
    ctx.save();
    ctx.font = 'bold 24px Rajdhani, sans-serif';
    ctx.textAlign = 'center';
    ctx.textBaseline = 'middle';

    const metrics = ctx.measureText(text);
    const paddingX = 16;
    const paddingY = 8;
    const w = metrics.width + paddingX * 2;
    const h = 34;

    ctx.fillStyle = isActive ? 'rgba(2, 132, 199, 0.85)' : 'rgba(11, 14, 23, 0.82)';
    ctx.fillRect(x - w / 2, y - h / 2, w, h);

    ctx.strokeStyle = isActive ? '#38bdf8' : 'rgba(56, 189, 248, 0.4)';
    ctx.lineWidth = isActive ? 2 : 1;
    ctx.strokeRect(x - w / 2, y - h / 2, w, h);

    ctx.fillStyle = isActive ? '#ffffff' : '#cbd5e1';
    ctx.fillText(text, x, y);
    ctx.restore();
}

// Renderizar o mapa 2048x2048
// showGizmo: true para prévia visual na tela com molduras; false para aplicar limpo no carro
function renderCanvas(showGizmo = true) {
    const size = canvas.width;
    
    // 1. Pinta a cor base da lataria
    ctx.fillStyle = baseColorInput.value;
    ctx.fillRect(0, 0, size, size);

    // 2. Se for para visualização na tela e o Molde estiver ligado, desenha o Molde 2D do Skyline
    const selectedZoneKey = zoneSelect.value;
    if (showGizmo && showBlueprint) {
        drawVehicleBlueprint(ctx, size, selectedZoneKey, blueprintAlpha);
    }

    // 3. Informações da zona selecionada
    const zone = currentZones[selectedZoneKey] || {
        x: 0,
        y: 0,
        width: size,
        height: size,
        rotation: 0
    };

    // 4. Desenha a estampa transformada
    if (loadedImage) {
        ctx.save();
        
        // Posição: centro da peça + offset configurado pelo usuário
        const centerX = (zone.x + zone.width / 2) + transform.x;
        const centerY = (zone.y + zone.height / 2) + transform.y;
        ctx.translate(centerX, centerY);

        // Rotação: ângulo base da peça + rotação ajustada pelo usuário
        const totalRotationDeg = (zone.rotation || 0) + transform.rotation;
        ctx.rotate((totalRotationDeg * Math.PI) / 180);

        // Espelhamento e Escala
        const scaleX = (transform.flipH ? -1 : 1) * transform.scale;
        const scaleY = (transform.flipV ? -1 : 1) * transform.scale;
        ctx.scale(scaleX, scaleY);

        // Proporção base da imagem
        const hRatio = zone.width / loadedImage.width;
        const vRatio = zone.height / loadedImage.height;
        const ratio = Math.min(hRatio, vRatio);

        const drawWidth = loadedImage.width * ratio;
        const drawHeight = loadedImage.height * ratio;

        // Desenha a imagem centralizada no ponto
        ctx.drawImage(
            loadedImage,
            -drawWidth / 2,
            -drawHeight / 2,
            drawWidth,
            drawHeight
        );

        // Gizmo / Moldura interativa (somente na prévia da NUI)
        if (showGizmo) {
            ctx.strokeStyle = '#38bdf8';
            ctx.lineWidth = 3;
            ctx.strokeRect(-drawWidth / 2, -drawHeight / 2, drawWidth, drawHeight);

            // Marcadores de canto
            const cSize = 14;
            ctx.fillStyle = '#ffffff';
            ctx.fillRect(-drawWidth / 2 - cSize / 2, -drawHeight / 2 - cSize / 2, cSize, cSize);
            ctx.fillRect(drawWidth / 2 - cSize / 2, -drawHeight / 2 - cSize / 2, cSize, cSize);
            ctx.fillRect(-drawWidth / 2 - cSize / 2, drawHeight / 2 - cSize / 2, cSize, cSize);
            ctx.fillRect(drawWidth / 2 - cSize / 2, drawHeight / 2 - cSize / 2, cSize, cSize);

            // Linha e indicador de rotação no topo
            ctx.beginPath();
            ctx.moveTo(0, -drawHeight / 2);
            ctx.lineTo(0, -drawHeight / 2 - 28);
            ctx.strokeStyle = '#38bdf8';
            ctx.lineWidth = 2;
            ctx.stroke();

            ctx.beginPath();
            ctx.arc(0, -drawHeight / 2 - 28, 7, 0, Math.PI * 2);
            ctx.fillStyle = '#38bdf8';
            ctx.fill();
        }

        ctx.restore();
    }
}

// Carregar imagem de URL
function loadImageFromUrl(url) {
    if (!url) return;
    dropzoneText.innerHTML = '⏳ Carregando imagem...';

    const img = new Image();
    img.crossOrigin = 'Anonymous';
    img.onload = () => {
        loadedImage = img;
        dropzoneText.innerHTML = '✅ Imagem carregada com sucesso!';
        renderCanvas(true);
    };
    img.onerror = () => {
        dropzoneText.innerHTML = '❌ Erro ao carregar link direto. Tente copiar e colar com CTRL+V!';
    };
    img.src = url;
}

// Evento ao colar link no campo de texto
imgUrlInput.addEventListener('input', (e) => {
    const val = e.target.value.trim();
    if (val.startsWith('http://') || val.startsWith('https://')) {
        loadImageFromUrl(val);
    }
});

// Suporte a colar com CTRL + V em qualquer lugar do painel
window.addEventListener('paste', (e) => {
    const items = (e.clipboardData || window.clipboardData).items;
    if (!items) return;

    for (let i = 0; i < items.length; i++) {
        const item = items[i];

        // Se for uma imagem copiada para a área de transferência
        if (item.type.indexOf('image') !== -1) {
            const blob = item.getAsFile();
            const reader = new FileReader();
            reader.onload = (event) => {
                const img = new Image();
                img.onload = () => {
                    loadedImage = img;
                    dropzoneText.innerHTML = '✅ Imagem colada via <b>CTRL + V</b> com sucesso!';
                    renderCanvas(true);
                };
                img.src = event.target.result;
            };
            reader.readAsDataURL(blob);
            return;
        }

        // Se for texto/link colado
        if (item.type === 'text/plain') {
            item.getAsString((text) => {
                const trimmed = text ? text.trim() : '';
                if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
                    imgUrlInput.value = trimmed;
                    loadImageFromUrl(trimmed);
                }
            });
        }
    }
});

// Botão Aplicar no Carro
btnApply.addEventListener('click', () => {
    if (!currentVehicle) {
        alert('Nenhum veículo selecionado!');
        return;
    }

    if (!loadedImage && !imgUrlInput.value.trim()) {
        alert('Por favor, cole uma imagem (com CTRL+V) ou insira o link de uma foto antes de aplicar!');
        return;
    }

    // Renderiza limpo (sem molde 2D, sem gizmos de seleção nem molduras de ajuste) para aplicar na lataria
    renderCanvas(false);
    const targetUrl = canvas.toDataURL('image/jpeg', 0.88);
    // Restaura o molde e gizmo na tela da NUI
    renderCanvas(true);

    console.log('[Custom Livery] Enviando textura final posicionada para o veículo...');

    fetch(`https://${GetParentResourceName()}/applyLivery`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json; charset=UTF-8' },
        body: JSON.stringify({
            netId: currentVehicle.netId,
            plate: currentVehicle.plate,
            model: currentVehicle.model,
            imageUrl: targetUrl
        })
    });

    closeUI();
});

// Botão Remover Estampa e restaurar pintura original
if (btnRemove) {
    btnRemove.addEventListener('click', () => {
        if (!currentVehicle) return;

        loadedImage = null;
        imgUrlInput.value = '';
        dropzoneText.innerHTML = '📋 Copie qualquer foto no seu PC e aperte <b>CTRL + V</b> nesta tela!';
        resetTransform();

        fetch(`https://${GetParentResourceName()}/removeLivery`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json; charset=UTF-8' },
            body: JSON.stringify({
                netId: currentVehicle.netId,
                plate: currentVehicle.plate
            })
        });

        closeUI();
    });
}

function closeUI() {
    app.classList.add('hidden');
    fetch(`https://${GetParentResourceName()}/close`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json; charset=UTF-8' },
        body: JSON.stringify({})
    });
}

btnClose.addEventListener('click', closeUI);

window.addEventListener('keydown', (e) => {
    if (e.key === 'Escape') {
        closeUI();
    }
});

// Escuta mensagem vinda do FiveM (client/main.lua) para abrir o painel
window.addEventListener('message', (event) => {
    const data = event.data;
    if (data.action === 'open') {
        currentVehicle = {
            netId: data.netId,
            plate: data.plate,
            model: data.model
        };
        currentZones = data.zones || {};

        vehName.textContent = data.vehicleLabel || 'Nissan Skyline GT-R R34';
        vehPlate.textContent = data.plate || 'DESCONHECIDO';

        if (data.zones) {
            zoneSelect.innerHTML = '';
            for (const [key, zoneData] of Object.entries(data.zones)) {
                const opt = document.createElement('option');
                opt.value = key;
                opt.textContent = zoneData.label || key;
                zoneSelect.appendChild(opt);
            }
        }

        updatePillSelection(zoneSelect.value);
        resetTransform();
        app.classList.remove('hidden');
    }
});
