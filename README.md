Deadlock 的堆叠机与紧凑装卸机（DSB）
==========================

**DSB** 是一个异星工厂（Factorio）模组，添加 1x1 的小型装卸机（loader）和堆叠机（beltbox）。它们可以在传送带上就地堆叠物品，大幅提高传送带吞吐量。

如果你是一名模组作者，可以让 DSB 自动为你自己模组里的物品生成堆叠版本。DSB API 的说明见下文。

> 本仓库是 DSB 的中文分支（fork），新增了 **Bob's Logistics 支持**和**简体中文**，改动明细见下面的「本分支的改动」一节。本节以下的内容是上游原有的模组 API 文档，未作改动。

本分支的改动
==========================

这里只说明本仓库相对上游 [shanemadden/factorio-deadlock-beltboxes-loaders](https://github.com/shanemadden/factorio-deadlock-beltboxes-loaders) 的改动。

版本 2.6.1：支持 Bob's Logistics
------

Bob's Logistics 会重新定义各级传送带的速度，并额外提供「基础传送带」（T0）和「终极传送带」（T5）两档。本版本让 DSB 跟上这些等级：

* **新增 [prototypes/bob_tiers.lua](prototypes/bob_tiers.lua)**，为下面这些等级生成装卸机和堆叠机：

  | 等级 | 传送带 | 解锁科技 | 说明 |
  | --- | --- | --- | --- |
  | T0 基础 | `bob-basic-transport-belt` | `logistics-0` | 仅在 Bob 开启「传送带重置」时存在 |
  | T4 涡轮 | `turbo-transport-belt` | `logistics-4` | 装了 Space Age 时该等级已经有了，只同步速度、不重复生成 |
  | T5 终极 | `bob-ultimate-transport-belt` | `logistics-5` | 由 Bob 的最高级传送带科技解锁 |

* **速度自动匹配 Bob 的设置**：装卸机的 `speed` 直接取 `data.raw["transport-belt"][带名].speed`（在 `data-updates` 阶段读取，此时 Bob 的速度已经算好），堆叠机的 `crafting_speed` = 传送带速度 × 32。因此无论 Bob 的「传送带速度重置 / 每级速度 / 初始速度」怎么设置，每一档装卸机都和它对应的传送带同速。
* **整条等级链都可以升级**：T0 → T1 → T2 → T3 → T4 → T5 全部设置了 `next_upgrade`，升级规划器与快速替换（装卸机和堆叠机都有）可以从基础带一路升到终极带。
* **每一级升级的配方**：上一级装卸机 ×1 + 铁板 ×2 + 铁齿轮 ×2（T0 没有上一级，改用基础传送带 ×1）；并统一为 `crafting` 分类，所以原来需要润滑液/钨板、只能在铸造厂生产的 T3/T4 装卸机现在也可以直接手搓。
* **配方成本和范围都能改**，全部集中在 `prototypes/bob_tiers.lua` 顶部的 `CONFIG` 表里：

  | 字段 | 默认值 | 作用 |
  | --- | --- | --- |
  | `upgrade_iron_plate` | 2 | 每级升级消耗的铁板数 |
  | `upgrade_iron_gear` | 2 | 每级升级消耗的铁齿轮数 |
  | `upgrade_from_previous` | true | 是否消耗上一级装卸机；设为 false 则用本等级的传送带当材料 |
  | `reprice_existing_tiers` | true | 是否把原有的 T1–T3（以及 Space Age 的 T4）也改成同一套升级配方 |
  | `create_basic_tier` | true | 是否给 Bob 的 T0 基础带做装卸机/堆叠机 |
  | `beltbox_recipes` | `"extend"` | 新等级的堆叠机配方：`"extend"` 沿用本模组原有风格；`"upgrade"` 与装卸机同样廉价；`"none"` 不为新等级生成堆叠机 |

* **[data-updates.lua](data-updates.lua)**：检测到 `boblogistics` 时加载 `prototypes.bob_tiers`（放在 data-updates 阶段，能让 Bob 的速度和科技先算完）。
* **[info.json](info.json)**：新增可选依赖 `"? boblogistics"`，保证 Bob 的 data.lua 先执行。
* **[locale/en/deadlock-beltboxes-loaders.cfg](locale/en/deadlock-beltboxes-loaders.cfg)**：补上新等级的英文名。

版本 2.6.2：简体中文本地化
------

* **新增 [locale/zh-CN/deadlock-beltboxes-loaders.cfg](locale/zh-CN/deadlock-beltboxes-loaders.cfg)**：本模组自带完整简体中文，覆盖实体/物品/配方名、实体说明、科技名与说明、全部设置项（名称与说明）、模组名与描述。用词沿用社区汉化包 `chinese` 的习惯译法（简洁装卸机、堆叠机、平分解压、堆叠比例……），并补上汉化包没有的涡轮档、Bob 两档，以及汉化包缺失的两条开关说明。装不装汉化包都会显示中文；同时因为本模组加载在汉化包之后，同名的键以本模组的文本为准（两者文本一致）。
* **[changelog.txt](changelog.txt)**、**[description.md](description.md)** 同步更新。

以上改动如何验证
------

改动都用 Factorio 2.0.77 实际加载 `boblogistics 2.1.1`（外带 `space-age` 与 `chinese` 汉化包）校验过：`--dump-data` 检查每级装卸机速度是否与传送带一致、配方与升级链是否正确；`--dump-prototype-locale` 检查游戏内实际显示的中文文本。

自行打包 / 重新打包
------

改完之后重新打成 `deadlock-beltboxes-loaders_<版本>.zip`（zip 内要带一层 `deadlock-beltboxes-loaders_<版本>/` 目录），放进 `%APPDATA%\Factorio\mods\` 即可。在仓库根目录用 PowerShell 执行：

~~~~
$ver   = (Get-Content info.json -Raw | ConvertFrom-Json).version
$base  = "deadlock-beltboxes-loaders_$ver"
$stage = "$env:TEMP\dsb\$base"
Remove-Item -Recurse -Force "$env:TEMP\dsb" -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Path $stage | Out-Null
Get-ChildItem -Force . | Where-Object { $_.Name -notin @('.git','.github') } |
  ForEach-Object { Copy-Item $_.FullName $stage -Recurse -Force }

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
~~~~

> 注意：zip 内部的路径分隔符必须是正斜杠 `/`。用 `[System.IO.Compression.ZipFile]::CreateFromDirectory()` 或 `Compress-Archive` 在 Windows PowerShell 里可能写成反斜杠 `\`，那样的包游戏会因为找不到文件而加载失败。

步骤 1
------

在你模组的 **info.json** 中把 “?deadlock-beltboxes-loaders” 加为可选依赖。例如：

~~~~
{
  "name": "DeadlockTweaks",
  "version": "0.1.0",
  "title": "Deadlock's Tweaks",
  "author": "Deadlock989",
  "contact": "",
  "homepage": "",
  "dependencies": ["base >= 0.17.0", "?deadlock-beltboxes-loaders"],
  "description": "Some small quality of life adjustments.",
  "factorio_version": "0.17"
}
~~~~

步骤 2
------

DSB 提供了一组函数，帮你完成堆叠物品的创建（以及可选的堆叠机和装卸机等级创建）。这些函数应当在你自己模组的 **data-final-fixes.lua** 中调用。调用之前请先判断 **deadlock** 是否存在，这样在没装 DSB 时你的模组也不会报错。例如：

~~~~
-- [data-final-fixes.lua]
-- 这个模组会制造钻石。别往下挖
-- 我们已经在前面创建好了自己的物品

-- 让 DSB 给我的物品做堆叠版
if deadlock then
  -- 对每一个你想堆叠的物品重复这一步
  deadlock.add_stack("deadlock-uber-diamond", "__DeadlockTweaks__/graphics/icons/stacked-diamond.png", "deadlock-stacking-1", 64)
end
~~~~

另外，如果你有一长串物品要分别塞进不同的科技里，可以把它们放进数组/表里循环处理。

这是最简单的用法。DSB 还提供了其它一些函数，说明见下面几节。

deadlock.add_stack()
----------------------------

这个函数用来堆叠 DSB 默认不处理的物品。它最多接受六个参数，完整调用形式如下：
**deadlock.add_stack(item_name, graphic_path, target_tech, icon_size, item_type, mipmap_levels)**

| **参数** | **可选 / 必填** | **说明** |
| --- | --- | --- |
| **item_name** | 必填 | 字符串。要堆叠的物品名，例如 “iron-plate”。 |
| **graphic_path** | 可选 | 字符串。你的堆叠物品图标路径。可以省略，但会影响性能（见下文「更多细节」）。 |
| **target_tech** | 可选 | 字符串。堆叠配方要解锁到的科技名（例如 “deadlock-stacking-1”）。如果填写，该科技**必须已经存在**于 data.raw 中。如果省略或传 nil，本模组不会修改任何科技，你需要自己想办法让玩家拿到这些配方。 |
| **icon_size** | 可选 | 整数。自定义图标的像素尺寸，默认 64。不提供图标时无效。 |
| **item_type** | 可选 | 字符串。物品类型，例如 "item"、"ammo"、"repair-tool" 等，默认 "item"。 |
| **mipmap_levels** | 可选 | 整数。自定义图标的 mipmap 层级，默认 nil。不提供图标时无效。 |

可选参数可以直接省略，也可以显式传 nil 使用默认值。

注意：如果你指定的物品已经做过堆叠，可能会出现意料之外的结果。建议先用下面介绍的 destroy_stack() 把原来的物品删掉，再重新创建。

deadlock.destroy_stack()
--------------------------------

只接受一个参数，即物品名：
**deadlock.destroy_stack(item_name)**

调用后会把该物品的堆叠版本销毁，并删除**所有**以该堆叠物品为原料或产物的配方（至少包括堆叠/拆堆配方，理论上也可能包括其它模组把堆叠物品当原料的配方），同时从**所有**科技中移除对已被删除配方的**全部**引用。

请记住，可能还有别的模组指望着某个堆叠物品存在。如果你删掉它却不再建回来，由此产生的问题需要你自己负责。你也可以用这个函数先清掉某个堆叠物品、再用 add_stack() 重建它，例如用来解决两个大改模组之间的冲突。

deadlock.destroy_vanilla_stacks()
-----------------------------------------

不接受参数，会删除 DSB 默认创建的全部原版堆叠物品和配方。效果等同于对模组在早期 data 阶段建立的每一个物品调用 destroy_stack()。当你想推倒重来时可以用它。

deadlock.add_tier()
---------------------------

默认情况下 DSB 会创建三档堆叠机和装卸机（对应原版的黄带、红带、蓝带），并创建三个科技，各自解锁对应的机器和一批堆叠配方。你可以用这个函数创建新的机器等级，让它们由新的科技解锁，以对应其它模组提供的传送带（或者任何有理由存在的等级）；也可以用它替换掉默认的等级设置。

该函数只接受一个表作为参数，表中的键值对如下：

| **参数** | **可选 / 必填** | **说明** |
| --- | --- | --- |
| **transport_belt** | 必填 | 字符串。对应传送带的前缀名（例如 "uber-"），用来计算速度。 |
| **underground_belt** | 指定了 beltbox_ingredients 和 loader_ingredients 时可省略 | 字符串。对应地下传送带的名字。默认情况下 DSB 会以地下传送带的配方来计算堆叠机和装卸机的配方；省略它就必须自己指定配方材料。 |
| **splitter** | 可选 | 字符串。本模组目前用不到，如果有外观点缀模组存在会传给它。 |
| **colour** | 可选 | 颜色表。机器的染色，默认粉色。 |
| **technology** | 建议填写 | 字符串。对应物流科技的名字，用来解锁装卸机。不填则不会解锁堆叠配方。 |
| **order** | 建议填写 | 字符串。堆叠机和装卸机的排序串。 |
| **beltbox** | 可选 | 字符串。要创建的堆叠机原型名，默认是 transport_belt.."-beltbox"。 |
| **beltbox_technology** | 可选 | 字符串。解锁同档堆叠机与堆叠物品的科技名。默认等于 beltbox 的名字，也可以覆盖——原版各档用的是 "deadlock-stacking-[1-3]" 以兼容旧存档。 |
| **beltbox_ingredients** | 指定了 underground_belt 时可省略 | IngredientPrototype 表。堆叠机配方的材料，默认按 underground_belt 推导。 |
| **beltbox_recipe** | 可选 | 字符串。用来覆盖堆叠机配方的原型名。 |
| **beltbox_item** | 可选 | 字符串。用来覆盖堆叠机物品的原型名。 |
| **beltbox_category** | 可选 | 字符串。堆叠机的制造分类，默认 "crafting"；配方里有流体时用 "crafting-with-fluid"。 |
| **loader** | 可选 | 字符串。要创建的装卸机原型名，默认是 transport_belt.."-loader"。 |
| **loader_ingredients** | 指定了 underground_belt 时可省略 | IngredientPrototype 表。装卸机配方的材料，默认按 underground_belt 推导。 |
| **loader_recipe** | 可选 | 字符串。用来覆盖装卸机配方的原型名。 |
| **loader_item** | 可选 | 字符串。用来覆盖装卸机物品的原型名。 |
| **loader_category** | 可选 | 字符串。装卸机的制造分类，默认 "crafting"；配方里有流体时用 "crafting-with-fluid"。 |

下面是一个例子，来自为本模组添加第四档堆叠机和装卸机的整合模组：

~~~~
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
~~~~

更多细节
------------

**Data 阶段。** 这些函数应该在什么时候调用？在 **data-final-fixes.lua** 里。某些函数在个别情况下更早调用也能工作，但不保证。模组之间围绕着 data.lua、data-updates.lua、data-final-fixes.lua 存在一场「军备竞赛」：大家都在改动原版配方、自己的配方，以及去改别的模组。总的趋势是越做越晚，因为模组都想拦住或抵消别人的改动，这一点我们也没什么好办法。

**自动图标。** 使用 add_stack() 时，如果把图标路径和图标尺寸都传 nil，DSB 会用基础物品的图标自动拼出一个三层图标。这样做有两个问题：一是效果不一定好看，二是会拖累渲染性能。请记住屏幕上同时可能显示成千上万个这样的物品，用拼接图标至少会让渲染开销变成 4 倍，如果基础物品本身已经是多层图标还会更高。请尽量自己准备堆叠物品的图标，否则用低配显卡的玩家就要遭殃了。这个功能只是为了兼容老模组才保留的：创建多层图标时，游戏标准日志会被警告刷屏。

**科技与迁移。** 如果你把堆叠物品加进了 DSB 的科技，之后又改动或删除了它们提供的内容，**你需要自己负责迁移**。可以参考 DSB 的 migrations 文件夹。

**报错。** 有些情况下，你用某些参数调用 API 创建物品或等级，会导致游戏根本无法加载；这种情况下加载过程会中断并给出错误信息，**请认真读它**。另一些情况下，你指定的内容能让游戏加载，但就是说不通；这时游戏会继续加载，但函数调用可能被跳过，并在标准日志里打印错误或警告。所以如果你的堆叠物品或堆叠机没出现，先去翻日志。

**「辅助」或「桥接」模组。** 如果你喜欢的模组作者没时间/不愿意为堆叠做支持，你可以自己写一个小「辅助」模组来搭桥。这时你要把对方模组和 DSB 都写成强制依赖（而不是可选依赖），然后你的小模组只负责遍历一些物品，并在对方模组提供不同传送带时创建一个新等级。

如果遇到问题、自己尝试解决后仍然卡住，请到 [Factorio 论坛帖](https://forums.factorio.com/viewtopic.php?f=94&t=57264)联系我们，附上错误信息并贴出你的代码——光凭一句模糊的描述我们猜不出来。

本模组最初由 Deadlock989 创作，移植到 0.17 之后由 shanemadden 维护，Deadlock989 亦有贡献。
