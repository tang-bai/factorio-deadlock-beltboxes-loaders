# DSB 模组 API 与维护者文档

本文件面向想调用 DSB API 的模组作者，以及维护本分支的开发者。玩家向的模组介绍见 [README.md](README.md)。

## 目录

* [1. 声明依赖](#1-声明依赖)
* [2. 调用时机](#2-调用时机)
* [3. deadlock.add_stack()](#3-deadlockadd_stack)
* [4. deadlock.destroy_stack()](#4-deadlockdestroy_stack)
* [5. deadlock.destroy_vanilla_stacks()](#5-deadlockdestroy_vanilla_stacks)
* [6. deadlock.add_tier()](#6-deadlockadd_tier)
* [7. deadlock.update_stack_loaders()](#7-deadlockupdate_stack_loaders)
* [8. deadlock.get_item_stack_density()](#8-deadlockget_item_stack_density)
* [9. deadlock.deferred_stacked_item_updates()](#9-deadlockdeferred_stacked_item_updates)
* [10. 旧接口](#10-旧接口)
* [11. 注意事项](#11-注意事项)
* [12. 本地打包与发布](#12-本地打包与发布)

---

## 1. 声明依赖

在你自己模组的 `info.json` 中，把本模组加为**可选依赖**（想在同一个模组里同时兼容上游原版，就把两个都写上）：

~~~json
{
  "name": "DeadlockTweaks",
  "version": "0.1.0",
  "title": "Deadlock's Tweaks",
  "author": "Deadlock989",
  "contact": "",
  "homepage": "",
  "dependencies": [
    "base >= 2.0",
    "?deadlock-beltboxes-loaders-CN",
    "?deadlock-beltboxes-loaders"
  ],
  "description": "Some small quality of life adjustments.",
  "factorio_version": "2.0"
}
~~~

## 2. 调用时机

这些函数应当在你自己模组的 **data-final-fixes.lua** 中调用。调用之前先判断全局 `deadlock` 是否存在，这样没装 DSB 时你的模组也不会报错：

~~~lua
-- [data-final-fixes.lua]
-- 这个模组会制造钻石。别往下挖。
-- 我们已经在前面创建好了自己的物品。

if deadlock then
  -- 对每个想堆叠的物品重复这一步
  deadlock.add_stack("deadlock-uber-diamond", "__DeadlockTweaks__/graphics/icons/stacked-diamond.png", "deadlock-stacking-1", 64)
end
~~~

如果有一长串物品要分别塞进不同的科技，把它们放进表里循环处理即可。

> 模组之间围绕 data.lua、data-updates.lua、data-final-fixes.lua 存在一场「军备竞赛」：大家都在尽量晚地改动原版配方、自己的配方，以及别人的配方。某些函数在更早的阶段也能工作，但不保证。

---

## 3. deadlock.add_stack()

给 DSB 默认不处理的物品创建堆叠版本，并生成堆叠/平分解压配方。完整签名：

~~~lua
deadlock.add_stack(item_name, graphic_path, target_tech, icon_size, item_type, mipmap_levels)
~~~

| 参数 | 可选 / 必填 | 说明 |
| --- | --- | --- |
| `item_name` | 必填 | 字符串。要堆叠的物品原型名，例如 `"iron-plate"`。 |
| `graphic_path` | 可选 | 字符串。堆叠物品图标的路径。省略会触发自动拼图（见「注意事项」）。 |
| `target_tech` | 可选 | 字符串。把堆叠与平分解压配方解锁到的科技名。该科技**必须已经存在**（如果对应档位的堆叠机被关闭，本模组会按需创建堆叠科技）；省略则本模组不修改任何科技，你需要自己让玩家拿到配方。 |
| `icon_size` | 可选 | 整数。自定义图标尺寸，默认 64；只接受 32、64、128。不提供图标时无效。 |
| `item_type` | 可选 | 字符串。物品类型，默认 `"item"`。允许：`item`、`ammo`、`gun`、`tool`、`repair-tool`、`module`、`item-with-label`、`item-with-tags`、`capsule`、`rail-planner`。 |
| `mipmap_levels` | 可选 | 整数。自定义图标的 mipmap 层级，默认 nil。不提供图标时无效。 |

可选参数可以省略，也可以显式传 `nil` 使用默认值。

**生成的内容**

* 物品 `deadlock-stack-<item_name>`；
* 配方 `deadlock-stacks-stack-<item_name>`（分类 `stacking`）与 `deadlock-stacks-unstack-<item_name>`（分类 `unstacking`）；
* 如果给了 `target_tech`，把这两条配方加进该科技。

**堆叠密度**由 `deadlock.get_item_stack_density()` 决定：取「堆叠比例」设置与物品自身 `stack_size` 中较小的那个。因此堆叠数为 100 的物品，在比例 5 下每个堆叠物品包含 5 个基础物品，堆叠物品自身的 `stack_size` 为 20。

**常用目标科技**：`deadlock-stacking-1`、`deadlock-stacking-2`、`deadlock-stacking-3`（原版三档），装了太空时代还有 `deadlock-stacking-4`，Bob's Logistics 还有 `deadlock-stacking-5`。你也可以指向任意已存在的科技。

> 如果物品之前已经堆叠过，再次添加可能出现意料之外的结果。建议先用 `destroy_stack()` 删掉旧的堆叠物品，再用 `add_stack()` 重建。

---

## 4. deadlock.destroy_stack()

只接受一个参数，即基础物品名：

~~~lua
deadlock.destroy_stack(item_name)
~~~

调用后会：

1. 删除该物品的堆叠版本 `deadlock-stack-<item_name>`；
2. 删除**所有**以该堆叠物品为原料或产物的配方（至少包括堆叠/平分解压配方，也可能包括其它模组把堆叠物品当原料的配方）；
3. 从**所有**科技中移除对已删除配方的全部引用。

请记住，可能还有别的模组指望着某个堆叠物品存在。删掉却不再建回来，后果需要你自己处理。也可以用「先 `destroy_stack()`、再 `add_stack()`」的方式重建，用于解决两个大改模组之间的冲突。

## 5. deadlock.destroy_vanilla_stacks()

不接受参数，删除 DSB 默认创建的全部原版堆叠物品与配方，效果等同于对本模组在早期数据阶段创建的每一个物品调用 `destroy_stack()`。适合想推倒重来的场合。

---

## 6. deadlock.add_tier()

为本模组创建新的机器等级，或替换默认等级。它接受一个表：

~~~lua
deadlock.add_tier(tier_table)
~~~

| 字段 | 可选 / 必填 | 说明 |
| --- | --- | --- |
| `transport_belt` | 必填 | 字符串。对应传送带的原型名，例如 `"rapid-transport-belt-mk1"`。用于计算速度、复制贴图与校验。 |
| `underground_belt` | 指定了两种 ingredients 时可省略 | 字符串。对应地下传送带原型名。默认用它的配方推导装卸机/堆叠机配方；省略就必须自己给 ingredients。 |
| `splitter` | 可选 | 字符串。本模组不用，会传给外观点缀模组（如 `deadlock_belt_styling`）。 |
| `colour` | 可选 | 颜色表 `{r, g, b}`，机器染色；默认粉色 `{r=1, g=0.8, b=0.8}`。 |
| `technology` | 建议填写 | 字符串。解锁装卸机的物流科技名。不填则装卸机配方直接可用，但该档不会创建堆叠科技，堆叠机配方需要你自己解锁。 |
| `order` | 建议填写 | 字符串。装卸机/堆叠机的排序串。 |
| `loader` | 可选 | 字符串。装卸机原型名，默认 `transport_belt.."-loader"`。 |
| `loader_ingredients` | `underground_belt` 缺省时必填 | IngredientPrototype 表。装卸机配方材料。 |
| `loader_recipe` | 可选 | 字符串。覆盖装卸机配方原型名（兼容旧名称时用）。 |
| `loader_item` | 可选 | 字符串。覆盖装卸机物品原型名。 |
| `loader_category` | 可选 | 字符串。装卸机配方分类，默认沿用地下带配方的分类；没有时用 `"crafting"`。有流体时用 `"crafting-with-fluid"`。 |
| `stack_loader` | 可选（2.8.0） | 字符串。堆叠装卸机原型名，默认 `transport_belt.."-stack-loader"`。 |
| `stack_loader_item` | 可选（2.8.0） | 字符串。堆叠装卸机的物品/配方原型名，默认等于 `stack_loader`。 |
| `stack_loader_localised_name` | 可选（2.8.0） | LocalisedString。堆叠装卸机显示名；不传时显示为「装卸机名（堆叠）」。 |
| `beltbox` | 可选 | 字符串。堆叠机原型名，默认 `transport_belt.."-beltbox"`。 |
| `beltbox_ingredients` | `underground_belt` 缺省时必填 | IngredientPrototype 表。堆叠机配方材料。 |
| `beltbox_technology` | 可选 | 字符串。解锁该档堆叠机与堆叠配方的科技名，默认等于 `beltbox`。原版与太空时代各档用 `deadlock-stacking-1..4`，Bob 的终极档用 `deadlock-stacking-5`，以兼容旧存档。 |
| `beltbox_recipe` | 可选 | 字符串。覆盖堆叠机配方原型名。 |
| `beltbox_item` | 可选 | 字符串。覆盖堆叠机物品原型名。 |
| `beltbox_category` | 可选 | 字符串。堆叠机配方分类，默认沿用地下带配方的分类；有流体时用 `"crafting-with-fluid"`。 |

示例（来自为某模组添加第四档装卸机与堆叠机的整合模组）：

~~~lua
deadlock.add_tier({
	transport_belt      = "rapid-transport-belt-mk1",
	colour              = {r=10, g=225, b=25},
	underground_belt    = "rapid-transport-belt-to-ground-mk1",
	splitter            = "rapid-splitter-mk1",
	technology          = "logistics-4",
	order               = "d",
	loader_ingredients  = {
		{"express-transport-belt-loader",1},
		{"iron-gear-wheel",20},
		{amount = 40,name = "lubricant",type = "fluid"},
	},
	loader_category     = "crafting-with-fluid",
	beltbox_ingredients = {
		{"express-transport-belt-beltbox",1},
		{"iron-plate",40},
		{"iron-gear-wheel",40},
		{"processing-unit",5},
	},
	beltbox_technology  = "deadlock-stacking-4",
})
~~~

**堆叠装卸机什么时候会生成？** 只有同时满足以下条件时才会真正创建：装了太空时代、启动设置「启用堆叠装卸机」为开、`stack-inserter` 物品与科技都已存在。否则会跳过；如果只是太空时代的数据还没加载完，本模组会在 data-updates 与 data-final-fixes 阶段重试，你也可以调用 `deadlock.update_stack_loaders()` 手动补做。

**校验与日志**：参数不合法（传送带不存在、缺少配方材料等）时，函数通常会写一条 `DBL: Error` 到标准日志并跳过；但个别情况（例如 `technology` 指向一个不存在的科技）仍会让加载中断。物品没出现时先看日志。

---

## 7. deadlock.update_stack_loaders()

~~~lua
deadlock.update_stack_loaders()
~~~

本模组在 data.lua、data-updates.lua 与 data-final-fixes.lua 三个阶段各调用一次，用来：

* 为之前因科技尚未出现而跳过的堆叠装卸机补做生成；
* 把所有堆叠装卸机配方加进 `stack-inserter` 科技的解锁列表；
* 按传送带速度串好堆叠装卸机的 `next_upgrade` 升级链。

其它模组通常不需要调用。只有在你于所有 data 阶段之后才创建等级，或者 `stack-inserter` 科技出现得比等级更晚时，才需要在最后再调用一次。

## 8. deadlock.get_item_stack_density()

~~~lua
local density = deadlock.get_item_stack_density(item_name, item_type)
~~~

返回物品实际生效的堆叠密度：取「堆叠比例」设置与物品自身 `stack_size` 中较小的那个。写配方或计算产物数量时可以用它，不必再去翻堆叠配方。

* `item_name`：基础物品原型名；
* `item_type`：物品类型，默认 `"item"`。

## 9. deadlock.deferred_stacked_item_updates()

~~~lua
deadlock.deferred_stacked_item_updates()
~~~

在数据阶段末尾刷新已经创建的堆叠物品：重新计算分组、堆叠数、显示名，并复制燃料属性（热值按比例放大）。本模组已经在 `data-final-fixes.lua` 调用过一次；如果你的模组在那之后又修改了物品的 `stack_size` 或燃料属性，可以再调用一次。

---

## 10. 旧接口

以下接口保留用于兼容老模组，调用时会在日志里打印弃用警告：

| 旧接口 | 现在的做法 |
| --- | --- |
| `deadlock_loaders.create(tier_table)` | 把旧表转换为 `add_tier()` 的格式，并沿用旧版原型名：`deadlock-loader-<tier>`、`deadlock-beltbox-entity-<tier>`、`deadlock-beltbox-recipe-<tier>`、`deadlock-beltbox-item-<tier>`、`deadlock-stacking-<tier>`。 |
| `deadlock_stacking.create(item_name, graphic_path, target_tech, icon_size)` | 改用 `deadlock.add_stack(...)`。 |
| `deadlock_stacking.create_stack(...)` | 同上。 |
| `deadlock_stacking.reset()` | 从各堆叠科技里移除所有 `deadlock-stacks-` 配方解锁，但保留堆叠机。 |
| `deadlock_stacking.remove(target_tech)` | 从各堆叠科技里移除配方名包含给定字符串的解锁（纯文本匹配）。 |

新代码请直接使用 `deadlock.add_stack()`、`deadlock.add_tier()`、`deadlock.destroy_stack()`。

---

## 11. 注意事项

**自动图标。** 使用 `add_stack()` 时，如果把图标路径传为 nil，DSB 会用基础物品的图标自动拼出一个三层图标。这样做有两个问题：效果不一定好看，而且很吃渲染性能——屏幕上可能同时有成千上万个这样的物品，拼接图标至少让渲染开销变成 4 倍，基础物品本身是多层图标时还会更高。请尽量自带堆叠图标；这个功能只是为了兼容老模组，创建多层图标时标准日志会被警告刷屏。

**科技与迁移。** 如果你把堆叠物品加进 DSB 的科技，之后又改动或删除了它们提供的内容，**迁移需要你自己负责**。可以参考本模组的 [migrations/](migrations/) 文件夹。

**报错。** 某些参数会让游戏根本无法加载，加载过程会中断并给出错误信息，**请认真读它**；另一些参数能让游戏加载，但说不通，函数调用会被跳过，并在标准日志里打印错误或警告。堆叠物品或机器没出现时，先去翻日志。

**「辅助」或「桥接」模组。** 如果你喜欢的模组作者没时间/不愿意为堆叠做支持，可以自己写一个小模组搭桥：把对方模组和 DSB 都写成强制依赖（而不是可选依赖），然后遍历一些物品，并在对方提供不同传送带时创建一个新等级。

**模组改名。** 本分支的内部名称是 `deadlock-beltboxes-loaders-CN`。其它模组里 `if mods["deadlock-beltboxes-loaders"] then` 这类按名字判断的代码不会生效；调用全局 `deadlock` API 的模组不受影响。需要兼容时，请使用 `"deadlock-beltboxes-loaders-CN"`，或改为检测 `deadlock` 表。

---

## 12. 本地打包与发布

推送 master 后，仓库里的两个工作流会自动处理发布：

* [.github/workflows/push.yml](.github/workflows/push.yml)——读取 `info.json` 的 `name`/`version`，校验 `changelog.txt` 里有同版本条目，然后上传到 Factorio Mod Portal；门户上已有该版本时自动跳过；
* [.github/workflows/release.yml](.github/workflows/release.yml)——用 `git archive` 打包，并创建带 zip 的 GitHub Release。

所以发新版本前必须先做两件事：**在 [info.json](info.json) 升版本号**，并在 [changelog.txt](changelog.txt) 里补上同版本号的条目（门户不允许同一版本重复上传）。

### 手动打包

在仓库根目录用 PowerShell 执行（Windows PowerShell 5.1 读取中文必须带 `-Encoding UTF8`）：

~~~powershell
$info  = Get-Content info.json -Raw -Encoding UTF8 | ConvertFrom-Json
$base  = "$($info.name)_$($info.version)"
$stage = "$env:TEMP\dsb\$base"
Remove-Item -Recurse -Force "$env:TEMP\dsb" -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Path $stage | Out-Null
Get-ChildItem -Force . | Where-Object { $_.Name -notin @('.git','.github') } |
  ForEach-Object { Copy-Item $_.FullName $stage -Recurse -Force }

Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem
$zip = "$env:APPDATA\Factorio\mods\$base.zip"
if (Test-Path $zip) { Remove-Item -Force $zip }
$zipStream = [System.IO.File]::Open($zip, [System.IO.FileMode]::CreateNew)
$archive   = New-Object System.IO.Compression.ZipArchive($zipStream, [System.IO.Compression.ZipArchiveMode]::Create)
Get-ChildItem -Recurse -File $stage | ForEach-Object {
  $rel   = $_.FullName.Substring($stage.Length + 1) -replace '\\', '/'
  $entry = $archive.CreateEntry("$base/$rel", [System.IO.Compression.CompressionLevel]::Optimal)
  $s = $entry.Open(); $bytes = [System.IO.File]::ReadAllBytes($_.FullName)
  $s.Write($bytes, 0, $bytes.Length); $s.Dispose()
}
$archive.Dispose(); $zipStream.Dispose()
~~~

zip 内部的路径分隔符必须是正斜杠 `/`。用 `[System.IO.Compression.ZipFile]::CreateFromDirectory()` 或 `Compress-Archive` 在 Windows PowerShell 里可能写成反斜杠 `\`，这样的包游戏会因为找不到文件而加载失败。工作流里的 `git archive` 已经处理好了这一点。

---

模组内容、新增物品与玩家向说明见 [README.md](README.md)。
