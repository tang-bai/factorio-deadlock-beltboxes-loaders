![beltbox](https://i.imgur.com/JoFG35F.gif)

# Deadlock 的堆叠机与紧凑装卸机

[Deadlock's Stacking Beltboxes](https://mods.factorio.com/mod/DeadlockStacking) 和 [Deadlock's Compact Loaders](https://mods.factorio.com/mod/DeadlockLoaders) 现在已经合并成同一个模组。

对于已有存档：你需要先加载原来使用的那些 Deadlock 模组的新版本，才能把存档里的装卸机和堆叠机迁移到本模组——具体迁移方法请参考那些模组的页面。

**本模组直接内置了 Bob's Logistics 支持**：会为 Bob 的传送带等级（T0 基础传送带，以及由 Bob 提供的涡轮带和终极带）生成装卸机和堆叠机，速度与 Bob 的传送带完全一致；从基础带一直到终极带的每一档都设置了升级关系，升级规划器可以直接使用。每升一级只需要「上一级装卸机 + 铁板 ×2 + 铁齿轮 ×2」，想调整成本请改 `prototypes/bob_tiers.lua`。

**堆叠装卸机（需要太空时代）**：每一档装卸机都有一个堆叠版本，保留原有的装卸功能，并具备太空时代堆叠机械臂的堆叠能力——一次搬运整堆物品，并能把整堆物品分层放到传送带上。配方为「同档装卸机 + 堆叠机械臂 + 处理单元」，由太空时代的「堆叠机械臂」科技解锁；堆叠量可以在设置里调整（默认 4，与堆叠机械臂一致）。没装太空时代时不会生成。

与 Factorio Extended（含 Extended Plus）和 Xander Mod 的整合仍然放在另一个模组里——如果你要配合它们的传送带等级使用装卸机/堆叠机，请另外[安装整合模组](https://mods.factorio.com/mod/deadlock-integrations)。

注意：传送带重新贴图和地图重新配色这两个选项目前还没有实现。

新版有问题？欢迎到[论坛帖](https://forums.factorio.com/viewtopic.php?f=94&t=57264)反馈。

# 简体中文

本分支自带完整的简体中文（`locale/zh-CN`），装不装汉化包都能正常显示中文；用词沿用社区汉化包 `chinese` 的习惯译法，并补上了汉化包没有的涡轮档、Bob 两档以及两条设置说明。

# 鸣谢

* 概念、美术与最初作者：[Deadlock989](https://mods.factorio.com/user/deadlock989)。
* 由 [shanemadden](https://mods.factorio.com/user/shanemadden) 维护。
* 中文分支（Bob's Logistics 支持与简体中文）由 tang-bai 维护。

# 模组间支持（API）

新版提供的模组 API 与旧版几乎完全一致。专门文档还在准备中，先说明你需要知道的几点：

 - 用于添加堆叠物品的 API 调用，默认 `icon_size` 已改为 64x64。你的图标如果还是 32x32，就需要显式传入图标尺寸。（原版图标当时仍是 32x32；按 fff-277，预计 0.17 实验版期间会更新）

像这样的调用：

    deadlock_stacking.create("raw-wood", icon_path, "deadlock-stacking-1")

如果图标是 32x32，在 0.17 里要改成：

    deadlock_stacking.create("raw-wood", icon_path, "deadlock-stacking-1", 32)

 - 新提供了一个 API 函数，可以为任意等级的传送带创建装卸机和堆叠机。完整文档稍后补充，心急的模组作者可以先看[参数注释](https://github.com/shanemadden/factorio-deadlock-beltboxes-loaders/blob/master/prototypes/public.lua#L5)和[基础代码里的例子](https://github.com/shanemadden/factorio-deadlock-beltboxes-loaders/blob/master/prototypes/vanilla_tiers.lua)。

更完整的 API 文档见 [README.md](README.md)。
