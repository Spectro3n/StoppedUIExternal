# StoppedUI (NexUI) — Documentação

Biblioteca de interface para Roblox (Luau) com janela flutuante, abas em formato *Dynamic Island*, seções recolhíveis, temas, keybinds e vários tipos de elementos (Toggle, Slider, Dropdown, ColorPicker etc.).

> **Nota sobre o nome:** o repositório se chama *StoppedUIExternal*, mas internamente a biblioteca se identifica como **NexUI** (ver `warn("[NexUI] ...")` e o título padrão da janela). São a mesma coisa.

---

## Sumário

1. [Instalação](#instalação)
2. [Início rápido](#início-rápido)
3. [Conceitos básicos](#conceitos-básicos)
4. [Janela (`Library.new`)](#janela-librarynew)
5. [Abas (`new_tab`)](#abas-new_tab)
6. [Seções (`new_section`)](#seções-new_section)
7. [Elementos (`section:element`)](#elementos-sectionelement)
   - [Opções comuns](#opções-comuns)
   - [Toggle](#toggle)
   - [Slider](#slider)
   - [Dropdown](#dropdown)
   - [MultiDropdown](#multidropdown)
   - [Button](#button)
   - [TextBox](#textbox)
   - [ColorPicker](#colorpicker)
   - [Label](#label)
   - [Separator](#separator)
8. [Métodos comuns dos elementos](#métodos-comuns-dos-elementos)
9. [Keybinds](#keybinds)
10. [Dependências entre elementos](#dependências-entre-elementos)
11. [Flags: lendo valores](#flags-lendo-valores)
12. [Temas](#temas)
13. [Ícones](#ícones)
14. [Outras funções](#outras-funções)
15. [Exemplo completo](#exemplo-completo)
16. [Notas e armadilhas conhecidas](#notas-e-armadilhas-conhecidas)

---

## Instalação

```lua
local Library = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/Spectro3n/StoppedUIExternal/refs/heads/main/UI.lua"
))()
```

**Requisitos**

- Um executor com suporte a `loadstring` e `game:HttpGet`.
- Funções opcionais do executor (`gethui`, `syn.protect_gui`, `getcustomasset`, `writefile`, `isfile`) são usadas quando existem. Sem elas, a UI cai para o `PlayerGui` e ícones por URL/arquivo local não funcionam (IDs do Roblox continuam funcionando).

---

## Início rápido

```lua
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Spectro3n/StoppedUIExternal/refs/heads/main/UI.lua"))()

local Window  = Library.new("Minha UI", Enum.KeyCode.RightShift)
local Tab     = Window:new_tab("Main", "⚙")
local Section = Tab:new_section("Geral", "Left")

Section:element("Toggle", "Ativar", { flag = "ativar", default = false }, function(t)
    print("Toggle:", t.Toggle)
end)

Section:element("Slider", "Velocidade", {
    flag = "velocidade", min = 0, max = 100, default = 50, suffix = "%",
}, function(t)
    print("Slider:", t.Slider)   -- ⚠ o callback recebe uma TABELA, não um número
end)
```

---

## Conceitos básicos

A hierarquia é sempre:

```
Library.new()  →  Window
   └─ Window:new_tab()      →  Tab
        └─ Tab:new_section() →  Section
             └─ Section:element()  →  Element
```

Regras que valem para **todos** os elementos:

| Regra | Detalhe |
|---|---|
| **Callback sempre recebe uma tabela** | Ex.: `{Toggle = true}`, `{Slider = 42}`, `{Dropdown = "A"}`. Veja a tabela em [Elementos](#elementos-sectionelement). |
| **Callbacks rodam dentro de `pcall`** | Se o seu callback gerar erro, **nada é exibido**: ele falha em silêncio. |
| **Cada elemento tem um `flag` único** | Se você não passar `flag`, ele é gerado como `NomeDaSeção_NomeDoElemento`. |
| **Valores ficam em `Library.Flags[flag]`** | Ex.: `Library.Flags["velocidade"].Slider`. |
| **Todos os elementos ficam em `Library.Elements[flag]`** | Útil para buscar um elemento por flag e chamar métodos nele. |

---

## Janela (`Library.new`)

```lua
local Window = Library.new(title, toggleKey)
```

| Parâmetro | Tipo | Padrão | Descrição |
|---|---|---|---|
| `title` | `string` | `"NexUI"` | Título exibido na barra superior. |
| `toggleKey` | `Enum.KeyCode` | `RightShift` | Tecla que abre/fecha a janela. |

O que a janela cria automaticamente:

- `ScreenGui` com nome aleatório (`__NexUI_XXXXX`), protegido via `syn.protect_gui` / `gethui` quando disponível.
- Efeito de blur em `Lighting` (`__NexBlur`).
- Barra superior arrastável com avatar, nome de exibição e data do jogador local.
- **Dynamic Island** inferior com os botões de aba (também arrasta a janela).
- Tooltip global, camada `Overlay` para popups e handler global de keybinds.

Propriedades úteis do objeto `Window`: `Window.Title`, `Window.Tabs`, `Window.ActiveTab`, `Window.Open`, `Window.Gui`, `Window.Main`, `Window.ToggleKey`.

---

## Abas (`new_tab`)

```lua
local Tab = Window:new_tab(name, icon)
```

| Parâmetro | Tipo | Descrição |
|---|---|---|
| `name` | `string` | Nome da aba (aparece no tooltip do botão). |
| `icon` | `string?` | Emoji/letra **ou** ID de imagem do Roblox. Se omitido, usa a primeira letra do nome em maiúscula. |

Formatos aceitos em `icon` para abas:

```lua
Window:new_tab("Combat", "⚔")                       -- emoji / texto
Window:new_tab("Visuals", "1234567890")             -- ID numérico (vira rbxassetid://...)
Window:new_tab("Misc", "rbxassetid://1234567890")   -- asset completo
```

A **primeira aba criada** é selecionada automaticamente.

No Dynamic Island, apenas a aba ativa fica visível; passe o mouse sobre a ilha para expandir e ver todas.

---

## Seções (`new_section`)

```lua
local Section = Tab:new_section(name, side, options)
```

| Parâmetro | Tipo | Padrão | Descrição |
|---|---|---|---|
| `name` | `string` | — | Título do card (exibido em maiúsculas). |
| `side` | `"Left"` \| `"Right"` | `"Left"` | Coluna onde o card será colocado. |
| `options` | `table?` | `{}` | `{ collapsed = true }` inicia a seção recolhida. |

Métodos da seção:

| Método | Descrição |
|---|---|
| `section:element(type, name, options, callback)` | Cria um elemento. Veja [Elementos](#elementos-sectionelement). |
| `section:set_collapsed(bool)` | Recolhe/expande a seção com animação. |
| `section:sub_folder(name)` | Cria uma subpasta recolhível dentro da seção. Retorna um objeto com `folder:element(...)`. |

Clicar no cabeçalho do card também recolhe/expande.

### Sub-pastas

```lua
local folder = Section:sub_folder("Avançado")
folder:element("Toggle", "Opção interna", { flag = "interna" }, function(t) end)
```

---

## Elementos (`section:element`)

```lua
local elem = Section:element(type, name, options, callback)
```

Os dois últimos argumentos são **flexíveis** — qualquer uma das ordens abaixo funciona:

```lua
Section:element("Toggle", "X", { default = true }, function(t) end)   -- options, callback
Section:element("Toggle", "X", function(t) end, { default = true })   -- callback, options
Section:element("Toggle", "X", function(t) end)                       -- só callback
Section:element("Toggle", "X", { default = true })                    -- só options
```

O método retorna o objeto do elemento (`elem`), que possui [métodos comuns](#métodos-comuns-dos-elementos) e métodos específicos do tipo.

### Resumo: o que cada callback recebe

| Tipo | Payload do callback | Chave em `Library.Flags[flag]` |
|---|---|---|
| `Toggle` | `{ Toggle = boolean }` | `.Toggle`, `.Active` |
| `Slider` | `{ Slider = number }` | `.Slider` |
| `Dropdown` | `{ Dropdown = string }` | `.Dropdown` |
| `MultiDropdown` | `{ Selected = { [opção] = true } }` | `.Selected` |
| `Button` | `{}` (tabela vazia) | — |
| `TextBox` | `{ Text = string, Enter = boolean }` | `.Text` |
| `ColorPicker` | `{ Color = Color3 }` | `.Color` |
| `Label` / `Separator` | sem callback | — |

### Opções comuns

Valem para todos os tipos (exceto onde indicado):

| Opção | Tipo | Descrição |
|---|---|---|
| `flag` | `string` | Identificador único. Padrão: `SeçãoNome_ElementoNome`. **Defina sempre que puder.** |
| `desc` | `string` | Linha de descrição pequena sob o título (aumenta a altura da linha em 14 px). |
| `tooltip` | `string` | Texto exibido após ~0,8 s com o mouse parado sobre o elemento. |

---

### Toggle

```lua
local t = Section:element("Toggle", "Auto Farm", {
    flag    = "autofarm",
    default = false,
    desc    = "Farma automaticamente",
    tooltip = "Liga/desliga o farm",
    locked  = false,
}, function(data)
    print(data.Toggle)
end)
```

| Opção | Tipo | Padrão | Descrição |
|---|---|---|---|
| `default` | `boolean` | `false` | Estado inicial. |
| `locked` | `boolean` | `false` | Trava o toggle **desligado**, com ícone de cadeado. `set_value` e keybinds são ignorados. |

Métodos: `set_value(bool)`, `add_keybind(key, mode)` (veja [Keybinds](#keybinds)).

> O estado inicial `default = true` é aplicado **silenciosamente** (o callback não dispara na criação).

---

### Slider

```lua
Section:element("Slider", "Distância", {
    flag     = "distancia",
    min      = 0,
    max      = 500,
    default  = 100,
    decimals = 0,
    step     = 10,
    suffix   = " studs",
    desc     = "Alcance máximo",
}, function(data)
    local valor = data.Slider      -- ✅ use data.Slider
    print(valor)
end)
```

| Opção | Tipo | Padrão | Descrição |
|---|---|---|---|
| `min` | `number` | `0` | Valor mínimo. |
| `max` | `number` | `100` | Valor máximo. Se `max <= min`, vira `min + 1`. |
| `default` | `number` | `min` | Valor inicial (é limitado a `[min, max]`). |
| `decimals` | `number` | `0` | Casas decimais do valor **e** da exibição. |
| `step` | `number?` | — | Incremento fixo (ex.: `5` → 0, 5, 10…). |
| `suffix` | `string` | `""` | Texto após o valor (`"%"`, `" studs"`…). |

Interações: arrastar a barra (mouse ou toque) ou **clicar no valor** para digitar um número manualmente. O valor digitado também passa por `step`, `decimals` e `min/max`.

Métodos: `set_value(n)`, `set_range(min, max)`.

#### ⚠ Slider: o detalhe na construção

O slider funciona corretamente, mas **o jeito de construí-lo tem um detalhe que pega muita gente**. Todos estes pontos vêm do comportamento real do código:

**1. O callback recebe uma tabela `{ Slider = valor }`, não o número.**

Isso é o ponto mais importante. Como todos os callbacks da biblioteca rodam dentro de `pcall`, usar o argumento como número **não mostra erro nenhum**: o slider se move normalmente, mas o seu código não faz efeito.

```lua
-- ❌ ERRADO — o erro "arithmetic on a table value" é engolido pelo pcall
Section:element("Slider", "Speed", { min = 0, max = 100 }, function(v)
    humanoid.WalkSpeed = v          -- v é uma tabela!
end)

-- ✅ CERTO
Section:element("Slider", "Speed", { min = 0, max = 100 }, function(data)
    humanoid.WalkSpeed = data.Slider
end)
```

O callback é disparado **uma única vez** por atualização (versões antigas da biblioteca chamavam duas vezes, uma com número e outra com tabela; isso já foi corrigido). Se você migrou um script antigo que esperava o número cru, basta trocar `v` por `data.Slider`.

**2. Se usar `step` com valores fracionados, defina `decimals` também.**

O valor passa primeiro por `step` e **depois** é arredondado por `decimals`. Com `decimals = 0` (padrão), um `step = 0.5` acaba arredondado para inteiros.

```lua
-- ❌ step 0.5 mas decimals = 0 → o valor volta a ser inteiro
{ min = 0, max = 5, step = 0.5 }

-- ✅ combine step e decimals
{ min = 0, max = 5, step = 0.5, decimals = 1 }
```

**3. Use `flag` explícito e único.**

O flag padrão é `Seção_Nome`. Dois sliders com o mesmo nome na mesma seção (ex.: "Speed" em duas sub-pastas) compartilham o mesmo flag e um sobrescreve o outro em `Library.Flags` e `Library.Elements`.

**4. Leitura fora do callback.**

```lua
local atual = Library.Flags["velocidade"].Slider
-- ou
local atual = Library.Elements["velocidade"]:get_value()
```

**5. Padrão recomendado de construção:**

```lua
Section:element("Slider", "Velocidade", {
    flag     = "velocidade",   -- único
    min      = 0,
    max      = 100,
    default  = 16,
    decimals = 0,
    step     = 1,
    suffix   = "",
}, function(data)
    local value = data.Slider  -- sempre via .Slider
    -- sua lógica aqui
end)
```

---

### Dropdown

```lua
Section:element("Dropdown", "Alvo", {
    flag    = "alvo",
    options = { "Cabeça", "Torso", "Pernas" },
    default = "Torso",
}, function(data)
    print(data.Dropdown)
end)
```

| Opção | Tipo | Padrão | Descrição |
|---|---|---|---|
| `options` | `{string}` | `{"Option"}` | Lista de opções. |
| `default` | `string` | `options[1]` | Opção inicial. |

Com **mais de 7 opções** o menu ganha uma caixa de busca automaticamente.

Métodos: `set_value(str)`, `set_options(newOptions, keepValue)`.
`keepValue = true` mantém o valor atual se ele ainda existir na nova lista; caso contrário seleciona a primeira opção.

---

### MultiDropdown

```lua
Section:element("MultiDropdown", "Partes", {
    flag    = "partes",
    options = { "Cabeça", "Torso", "Braços", "Pernas" },
    default = { "Cabeça", "Torso" },   -- ← array
}, function(data)
    for opcao, ativo in pairs(data.Selected) do
        print(opcao, ativo)
    end
end)
```

- `default` é um **array** de strings.
- O valor (`data.Selected` / `Library.Flags[flag].Selected`) é um **dicionário** `{ [opção] = true }`. Opções desmarcadas **não aparecem** na tabela.
- O texto exibido mostra os nomes (até 2), `N selected` (3+) ou `None`.

```lua
if Library.Flags["partes"].Selected["Cabeça"] then ... end
```

Métodos: `set_value(dict)`, `set_options(newOptions, keepSelection)`.

---

### Button

```lua
Section:element("Button", "Resetar", { desc = "Volta tudo ao padrão" }, function()
    print("clicado")
end)
```

Métodos: `set_text(str)`.

---

### TextBox

```lua
Section:element("TextBox", "Nome", {
    flag        = "nome",
    default     = "",
    placeholder = "Digite aqui...",
}, function(data)
    print(data.Text, data.Enter)   -- Enter = true se confirmou com Enter
end)
```

O callback dispara quando o campo **perde o foco**. `Library.Flags[flag].Text` é atualizado em tempo real, a cada caractere.

Métodos: `set_value(str)` — atualiza o texto e a flag sem disparar callback.

---

### ColorPicker

```lua
Section:element("ColorPicker", "Cor do ESP", {
    flag    = "esp_cor",
    default = Color3.fromRGB(255, 0, 0),
}, function(data)
    print(data.Color)
end)
```

Clique no quadradinho de cor para abrir o seletor (quadrado SV, barra de matiz, preview e campo HEX). O popup abre à esquerda do swatch e vai para a direita se não houver espaço.

Métodos: `set_value(Color3)`.

---

### Label

```lua
local lbl = Section:element("Label", "Texto informativo com quebra de linha automática.")
lbl:set_text("Novo texto")
```

---

### Separator

```lua
Section:element("Separator", "")          -- linha simples
Section:element("Separator", "Avançado")  -- linha com título centralizado
```

---

## Métodos comuns dos elementos

Disponíveis em **todos** os elementos retornados por `section:element`:

| Método | Descrição |
|---|---|
| `elem:set_visible(bool)` | Mostra/oculta a linha do elemento. |
| `elem:get_value()` | Retorna o valor atual (`boolean`, `number`, `string`, `table` ou `Color3`, conforme o tipo). |
| `elem:set_value(v)` | Define o valor **e dispara o callback** (não existe em Button/Label/Separator). |
| `elem:depends_on(flag, fn)` | Veja [Dependências](#dependências-entre-elementos). Retorna o próprio elemento. |
| `elem:set_callback(fn)` | Veja a [nota nas armadilhas](#notas-e-armadilhas-conhecidas). |

Propriedades do elemento: `elem.Type`, `elem.Name`, `elem.Flag`.

### Indicador de alteração (dirty dot)

Toggle, Slider, Dropdown, MultiDropdown e ColorPicker mostram um pontinho amarelo no canto esquerdo quando o valor atual é **diferente do padrão** (`default`). Ele some quando o valor volta ao padrão.

---

## Keybinds

Somente elementos **Toggle** suportam keybind.

```lua
local t = Section:element("Toggle", "Fly", { flag = "fly" }, function(d) end)
t:add_keybind(Enum.KeyCode.F, "Toggle")   -- tecla padrão e modo
```

Ao chamar `add_keybind`, um ícone de engrenagem aparece ao lado do toggle. Clicando nele o usuário abre o popup para:

- Trocar a tecla (clicar → pressionar nova tecla) ou limpar com **Clear**.
- Escolher o modo.

| Modo | Comportamento |
|---|---|
| `"Toggle"` | Cada pressionar alterna ligado/desligado. |
| `"Hold"` | Ligado enquanto a tecla estiver pressionada. |
| `"Always"` | Pressionar liga o toggle e ele permanece ligado. |

Os keybinds **não disparam** se o jogo estiver capturando o input (ex.: digitando no chat — `gameProcessedEvent`). A tecla definida em `Library.new(…, toggleKey)` para abrir/fechar a janela é tratada antes dessa verificação.

Quando o usuário altera tecla/modo pelo popup, os valores ficam em `Library.Flags[flag].Keybind` e `Library.Flags[flag].Mode`.

### Lista de keybinds na tela

```lua
Library.KeybindList(Window, true)    -- mostra (arrastável pelo título)
Library.KeybindList(Window, false)   -- oculta
```

Ou, usando a sintaxe de método: `Window:KeybindList(true)`. Ela atualiza a cada 0,5 s e lista apenas toggles **ligados** que tenham keybind, no formato `[TECLA M]` (`T` = Toggle, `H` = Hold, `A` = Always).

---

## Dependências entre elementos

Mostra/oculta um elemento conforme o valor de outro.

```lua
Section:element("Toggle", "Usar FOV", { flag = "usar_fov" }, function() end)

Section:element("Slider", "Tamanho do FOV", { flag = "fov_size", min = 10, max = 400, default = 100 }, function() end)
    :depends_on("usar_fov", function(flags)
        return flags.Toggle        -- flags = Library.Flags["usar_fov"]
    end)
```

- `fn` recebe a tabela `Library.Flags[targetFlag]` e deve retornar `true` (visível) ou `false` (oculto).
- A condição é avaliada na criação e **a cada mudança** do elemento alvo.
- Cada elemento pode depender de **um** alvo por vez (o registro é por `flag` do dependente).

---

## Flags: lendo valores

```lua
-- Por tabela de flags
local on   = Library.Flags["autofarm"].Toggle
local spd  = Library.Flags["velocidade"].Slider
local alvo = Library.Flags["alvo"].Dropdown
local cor  = Library.Flags["esp_cor"].Color
local txt  = Library.Flags["nome"].Text
local sel  = Library.Flags["partes"].Selected

-- Por elemento
local el = Library.Elements["velocidade"]
print(el:get_value())
el:set_value(80)
```

Útil para ler configurações dentro de loops (`RunService`) sem depender de callbacks.

---

## Temas

```lua
Library:SetTheme("Ocean")
```

Temas disponíveis: `Default`, `Stopped`, `Midnight`, `Ocean`, `Rose`, `Sunset`, `Mono`.

- A troca é animada (tween de 0,4 s) e afeta todos os elementos já criados.
- Nome inválido gera `warn` e não altera nada.
- `Library.CurrentTheme` guarda o nome do tema ativo.
- `Library.Themes` contém as paletas. Para criar um tema próprio, adicione uma tabela com **todas** as chaves de `Library.Themes.Default`:

```lua
Library.Themes.Meu = {
    BG = Color3.fromRGB(10,10,10), IconBar = ..., Panel = ..., Elevated = ..., Hover = ..., Active = ...,
    Card = ..., CardHead = ..., Accent = ..., AccentDim = ..., AccentGlow = ...,
    Text = ..., TextSub = ..., TextMut = ..., TextDis = ...,
    Border = ..., BorderLight = ..., Success = ..., Warning = ..., Danger = ...,
    ToggleBg = ..., ToggleKnob = ..., SliderTrack = ..., SliderFill = ..., SliderKnob = ...,
}
Library:SetTheme("Meu")
```

---

## Ícones

`Library.Icons` contém os ícones nativos usados internamente:

| Chave | Uso |
|---|---|
| `Lock` | Cadeado dos toggles `locked`. |
| `Arrow` | Setas de seções, subpastas e dropdowns. |
| `Gear` | Engrenagem de keybind. |

O renderizador interno de ícones aceita: emoji/texto, ID numérico, `rbxassetid://…`, `rbxasset://…`, arquivo local `.png/.jpg` e URL `http(s)` (baixada e cacheada com `writefile`, quando o executor suporta).

---

## Outras funções

### `Library:Dialog(title, message, onConfirm, onCancel)`

Abre um diálogo modal com botões **Confirm** e **Cancel**.

```lua
Library:Dialog("Resetar", "Deseja restaurar as configurações?",
    function() print("confirmou") end,
    function() print("cancelou") end
)
```

> A função **aguarda** o fim da animação de abertura (~0,35 s) antes de continuar. Se chamar dentro de um callback e não quiser bloquear, use `task.spawn`.

### `Window:SelectTab(tab)`

Seleciona uma aba por código.

### `Window:UpdateIslandState()`

Reaplica o estado visual da ilha de abas (normalmente você não precisa chamar).

### `Library:Watermark(...)`

Existe apenas por compatibilidade; **não faz nada** (recurso removido).

---

## Exemplo completo

```lua
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Spectro3n/StoppedUIExternal/refs/heads/main/UI.lua"))()

Library:SetTheme("Stopped")
local Window = Library.new("Stopped Hub", Enum.KeyCode.RightShift)

-- ═════════ ABA: COMBAT ═════════
local Combat = Window:new_tab("Combat", "⚔")

local Aim = Combat:new_section("Aimbot", "Left")

Aim:element("Toggle", "Ativar", {
    flag = "aim_on", default = false, desc = "Liga a mira assistida",
}, function(d)
    print("Aimbot:", d.Toggle)
end):add_keybind(Enum.KeyCode.E, "Hold")

Aim:element("Slider", "Suavidade", {
    flag = "aim_smooth", min = 0, max = 1, default = 0.25, decimals = 2, step = 0.05,
}, function(d)
    print("Suavidade:", d.Slider)
end):depends_on("aim_on", function(f) return f.Toggle end)

Aim:element("Dropdown", "Alvo", {
    flag = "aim_target", options = { "Cabeça", "Torso", "Pernas" }, default = "Cabeça",
}, function(d)
    print("Alvo:", d.Dropdown)
end)

Aim:element("MultiDropdown", "Ignorar", {
    flag = "aim_ignore", options = { "Amigos", "Time", "NPCs" }, default = { "Amigos" },
}, function(d)
    print("Ignorando amigos?", d.Selected["Amigos"] == true)
end)

local Fov = Combat:new_section("FOV", "Right")

Fov:element("ColorPicker", "Cor do círculo", {
    flag = "fov_color", default = Color3.fromRGB(45, 125, 255),
}, function(d)
    print("Cor:", d.Color)
end)

local adv = Fov:sub_folder("Avançado")
adv:element("TextBox", "Prefixo", { flag = "prefix", placeholder = "ex: !" }, function(d)
    print("Prefixo:", d.Text)
end)

-- ═════════ ABA: SETTINGS ═════════
local Settings = Window:new_tab("Settings", "🛠")
local UI = Settings:new_section("Interface", "Left")

UI:element("Dropdown", "Tema", {
    flag = "ui_theme",
    options = { "Default", "Stopped", "Midnight", "Ocean", "Rose", "Sunset", "Mono" },
    default = "Stopped",
}, function(d)
    Library:SetTheme(d.Dropdown)
end)

UI:element("Toggle", "Lista de keybinds", { flag = "kb_list" }, function(d)
    Window:KeybindList(d.Toggle)
end)

UI:element("Button", "Resetar tudo", function()
    task.spawn(function()
        Library:Dialog("Resetar", "Tem certeza?", function() print("resetado") end)
    end)
end)

-- Lendo valores em um loop
game:GetService("RunService").Heartbeat:Connect(function()
    if Library.Flags["aim_on"].Toggle then
        local alvo   = Library.Flags["aim_target"].Dropdown
        local smooth = Library.Flags["aim_smooth"].Slider
        -- ...
    end
end)
```

---

## Notas e armadilhas conhecidas

| Situação | Explicação |
|---|---|
| **Callback "não faz nada" e sem erro** | Todos os callbacks rodam em `pcall`. Um erro dentro deles é silencioso. Para depurar, envolva o corpo em `local ok, err = pcall(function() ... end); if not ok then warn(err) end` ou use `print` no início. |
| **Tratei o argumento como número** | O callback do Slider (e de todos os outros) recebe tabela. Use `data.Slider`, `data.Toggle`, etc. |
| **`elem:set_callback(fn)` não troca o comportamento** | Ele só grava `elem._callback`, mas os elementos chamam o callback passado na criação. Para trocar a lógica, use uma função intermediária que consulte uma variável sua. |
| **`set_value` dispara o callback** | Para atualizar sem disparar, não há método público; a função interna `elem._setValue(valor, true)` (segundo argumento = silencioso) existe em Toggle, Dropdown, MultiDropdown e ColorPicker, mas é API privada e pode mudar. |
| **Flags duplicadas** | Dois elementos com o mesmo `flag` (ou mesmo nome + seção, sem `flag`) se sobrescrevem em `Library.Flags` e `Library.Elements`. Sempre defina `flag`. |
| **Várias janelas** | `Library.Overlay` é global e é sobrescrito pela última janela criada; popups e diálogos usam essa referência. Prefira **uma janela por execução**. |
| **Tema aplicado antes/depois** | `SetTheme` funciona antes ou depois de criar a janela; elementos existentes são atualizados com animação. |
| **Executor sem `getcustomasset`** | Ícones por URL/arquivo local não carregam. Use IDs do Roblox (`rbxassetid://`). |
| **`locked = true`** | O toggle fica sempre desligado e ignora `set_value`/keybinds. |
| **Tooltip** | Só aparece depois de ~0,8 s com o mouse parado e desaparece ao sair do elemento. |

---

*Documentação baseada na leitura direta de `UI.lua`.*
