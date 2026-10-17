# Deadlock 的堆叠机与紧凑装卸机（DSB · CN 分支）

<img src="thumbnail.png" width="144" align="right" alt="DSB 模组图标">

**DSB**（Deadlock's Stacking Beltboxes & Compact Loaders）是一个 Factorio 2.0 模组，把 Deadlock989 的「堆叠机」与「紧凑装卸机」合并在一起。它添加几类 1x1 机器和一套压缩物品：**堆叠机**把若干同类物品压成一个堆叠物品（默认 5:1），让一条传送带能运更多东西；**装卸机**让箱子、机器和传送带直接对接，吞吐量等于整条传送带。默认堆叠比例为 5，因此通常说它提供 **5 倍传送带压缩**。

本仓库是上游 [shanemadden/factorio-deadlock-beltboxes-loaders](https://github.com/shanemadden/factorio-deadlock-beltboxes-loaders) 的**中文分支**，以独立模组名 `deadlock-beltboxes-loaders-CN` 发布，相对上游新增：

* **Bob's Logistics 支持**——为 T0 基础带和 T5 终极带生成装卸机/堆叠机，速度与 Bob 的传送带一致，T0→T5 全链可用升级规划器；
* **堆叠装卸机**（需要太空时代）——每档装卸机的堆叠版本，能一次搬运整堆物品并把它们分层堆放到传送带上；
* **完整简体中文**——实体、物品、配方、科技、设置项、模组名与描述；
* **两个独立的生成开关**——「生成堆叠机」与「生成堆叠物品」可以分开关闭。

| 项目 | 内容 |
| --- | --- |
| 模组名 | `deadlock-beltboxes-loaders-CN` |
| 版本 | 2.8.2（见 [changelog.txt](changelog.txt)） |
| 游戏版本 | Factorio 2.0 |
| 可选依赖 | Space Age、Bob's Logistics、ReStack |
| 发布页 | [Factorio Mod Portal](https://mods.factorio.com/mod/deadlock-beltboxes-loaders-CN) · [GitHub](https://github.com/tang-bai/factorio-deadlock-beltboxes-loaders) |

## 目录

* [1. 这个模组做了什么](#1-这个模组做了什么)
* [2. 新增物品一览](#2-新增物品一览)
  * [2.1 装卸机](#21-装卸机)
  * [2.2 堆叠机](#22-堆叠机)
  * [2.3 堆叠装卸机](#23-堆叠装卸机)
  * [2.4 堆叠物品](#24-堆叠物品)
* [3. 使用方法](#3-使用方法)
* [4. 设置项](#4-设置项)
* [5. 兼容性与依赖](#5-兼容性与依赖)
* [6. 安装与存档](#6-安装与存档)
* [7. 版本历史](#7-版本历史)
* [8. 模组开发](#8-模组开发)
* [9. 常见问题](#9-常见问题)
* [10. 鸣谢与许可](#10-鸣谢与许可)

---

## 1. 这个模组做了什么

### 1.1 它解决的问题

原版传送带按「个」计算运力：一条黄带 15 个/秒。矿石、板子、电路这类物品产量一大，带子很快就被塞满，而重新拉一条并行带既占地方，又要多花铁。

DSB 给这些物品各加一个压缩版本：

1. 用**堆叠机**把 5 个铁板压成 1 个「铁板（堆叠成 5）」（默认比例，可在设置里改）；
2. 带子上跑压缩版——1 个占 1 格，实际相当于 5 个铁板；
3. 在需要基础物品的地方（组装机、熔炉、发射井……）再用同一台堆叠机拆开。

**装卸机**负责把堆叠机接进传送带，也适合把箱子、机器、车厢直接接到带子上。它不需要机械臂，速度与同档传送带相同。

### 1.2 新增内容的角色

| 新增内容 | 一句话说明 | 典型用途 |
| --- | --- | --- |
| 装卸机 | 1x1 传送带接口，速度 = 同档传送带 | 免机械臂装卸、箱子与机器直连、机器进出带 |
| 堆叠机 | 1x1 的压缩/平分解压机器 | 产线中在线压缩，把带子运力提高（默认 5 倍） |
| 堆叠装卸机 | 装卸机 + 堆叠机械臂的成批搬运能力 | 一次搬整堆物品、往带子上分层堆放 |
| 堆叠物品 | `deadlock-stack-*` 系列的独立物品 | 带子上的压缩包，使用前通常要先拆堆 |

### 1.3 适合和不适合

**适合**：长距离主干带、矿场到冶炼厂、总线上的板子与电路，以及任何「同一种物品被大量运输」的场合。

**不适合**：

* 想把堆叠物品直接当配方原料——它是独立物品，必须先平分解压；
* 想靠它减少箱子或车厢占用的格子——堆叠物品的堆叠数会按比例缩小，总容量基本不变（不能整除时略有损失）；
* 流体——堆叠机只处理固体物品。

> 机器与物品都是数据阶段生成的原生原型。运行期脚本只处理放置时的吸附，以及在开启「自动平分解压」后的拆堆，因此平时几乎没有 UPS 开销。

---

## 2. 新增物品一览

所有内容按传送带**档位**组织。默认 3 档（黄、红、蓝）；装了太空时代会多出 Turbo 档；Bob's Logistics 再补 T0 基础、T5 终极（以及没装太空时代时的 Turbo 档）。表里的「原型名」就是 `data.raw` 里的名字，可在控制台、模组代码或蓝图里直接引用。

> 表中的 15/30/45/60 是原版默认运力。Bob's Logistics 的传送带速度设置会改掉这些数字；装卸机与堆叠机在数据阶段读取实际速度，会自动跟随。

| 新增物品 | 数量 | 说明 |
| --- | --- | --- |
| 装卸机 | 最多 6 档 | 黄、红、蓝，以及 Turbo（太空时代）、基础与终极（Bob's Logistics） |
| 堆叠机 | 最多 6 档 | 与装卸机同档，负责压缩与平分解压 |
| 堆叠装卸机 | 最多 6 档 | 需要太空时代，是每档装卸机的堆叠版本 |
| 堆叠物品 | 原版 23 种 | `deadlock-stack-*`，按科技分三批解锁；其它物品可通过 API 添加 |

### 2.1 装卸机

1x1 的传送带接口（原生 `loader-1x1` 类型），不耗电，生命值 170：

* 一侧贴传送带，另一侧贴库存；放置后用 `R` 旋转，切换输入/输出方向；
* 速度等于同档传送带，所以它能跑满整条带子，不会成为瓶颈；
* 5 个过滤槽，可以只让指定的几种物品通过；
* 默认与传送带同属快速替换组，可以直接把带子「刷」成装卸机，也能刷回去；打开「精确装卸机快速更换」后，只与装卸机互换；
* 放置时可以按运行时设置自动吸附传送带与库存。

| 档位 | 物品（中文 / 英文） | 原型名 | 速度 | 解锁科技 |
| --- | --- | --- | --- | --- |
| T0 基础 <sup>Bob</sup> | 基础装卸机 / Basic compact loader | `bob-basic-transport-belt-loader` | 同 Bob 基础带 | `logistics-0`（Bob 的基础物流科技） |
| T1 黄 | 装卸机 / Compact loader | `transport-belt-loader` | 15 个/秒 | `logistics`（物流学） |
| T2 红 | 快速装卸机 / Fast compact loader | `fast-transport-belt-loader` | 30 个/秒 | `logistics-2`（物流学 2） |
| T3 蓝 | 迅速装卸机 / Express compact loader | `express-transport-belt-loader` | 45 个/秒 | `logistics-3`（物流学 3） |
| T4 Turbo | Turbo 装卸机 / Turbo compact loader | `turbo-transport-belt-loader` | 60 个/秒 <sup>SA</sup> | `turbo-transport-belt`（Turbo 传送带）<sup>SA</sup> / `logistics-4` <sup>Bob</sup> |
| T5 终极 <sup>Bob</sup> | 终极装卸机 / Ultimate compact loader | `bob-ultimate-transport-belt-loader` | 同 Bob 终极带 | `logistics-5`（Bob 的最高级物流科技） |

<sup>Bob</sup>：只有安装 Bob's Logistics 才会生成；T0 还要求 Bob 的「基础传送带」存在（传送带重置设置）。<br>
<sup>SA</sup>：只有安装太空时代才会生成；如果 Turbo 传送带由 Bob's Logistics 提供（没装太空时代），同一台装卸机改由 `logistics-4` 解锁。

**默认配方（未安装 Bob's Logistics）**

| 档位 | 配方 | 制造分类 |
| --- | --- | --- |
| T1 | 传送带 ×1 + 铁板 ×5 | 手工 |
| T2 | 装卸机 ×1 + 铁齿轮 ×20 | 手工 |
| T3 | 快速装卸机 ×1 + 铁齿轮 ×40 + 润滑液 ×20 | 带流体；装了太空时代时也可在铸造厂制造 |
| T4 | 迅速装卸机 ×1 + 钨板 ×20 + 润滑液 ×20 | 带流体或冶金（铸造厂） |

**安装 Bob's Logistics 后**，整条 T0→T5 链（包括原版各档）会统一成同一种升级配方：

> 上一级装卸机 ×1 + 铁板 ×2 + 铁齿轮 ×2

T0 没有上一级，用「Bob 基础传送带 ×1」起步。所有档位的分类都改成「手工」，蓝带和 Turbo 档不再依赖铸造厂。想调成本，改 [prototypes/bob_tiers.lua](prototypes/bob_tiers.lua) 顶部的 `CONFIG`（`upgrade_iron_plate`、`upgrade_iron_gear`、`upgrade_from_previous`、`reprice_existing_tiers`）。

### 2.2 堆叠机

1x1 的电力机器（原型类型是 `furnace`，但只接受 `stacking` 与 `unstacking` 两类配方，不能当熔炉用）：

* 1 格输入、1 格输出、0 个插件槽，不用燃料；
* **同一台机器既能压缩也能平分解压**，具体执行哪条配方由输入物品决定；
* 黄带档耗电 90 kW，待机 15 kW；高档位按传送带速度等比提高；
* 可以像熔炉一样被机械臂喂料，但用装卸机才能跑满整条带子。

**处理能力与传送带严格对齐。** 堆叠配方按「每处理 1 个基础物品 1/15 秒」生成（堆叠比例变化时同步缩放），而机器的制作速度是传送带速度的 32 倍；两者正好抵消，所以它每秒处理的基础物品数**刚好等于同档传送带的运力**——既不会成为瓶颈，也不会让带子空转。

| 档位 | 物品（中文 / 英文） | 原型名 | 处理能力 | 压缩后（比例 5） | 解锁科技 |
| --- | --- | --- | --- | --- | --- |
| T0 基础 <sup>Bob</sup> | 基础堆叠机 / Basic stacking beltbox | `bob-basic-transport-belt-beltbox` | 同 Bob 基础带 | 带速 ÷ 5 | `logistics-0` |
| T1 黄 | 堆叠机 / Stacking beltbox | `transport-belt-beltbox` | 15 个/秒 | 3 个堆叠物品/秒 | 堆叠科技 1（`deadlock-stacking-1`） |
| T2 红 | 快速堆叠机 / Fast stacking beltbox | `fast-transport-belt-beltbox` | 30 个/秒 | 6 个/秒 | 堆叠科技 2（`deadlock-stacking-2`） |
| T3 蓝 | 迅速堆叠机 / Express stacking beltbox | `express-transport-belt-beltbox` | 45 个/秒 | 9 个/秒 | 堆叠科技 3（`deadlock-stacking-3`） |
| T4 Turbo | Turbo 堆叠机 / Turbo stacking beltbox | `turbo-transport-belt-beltbox` | 60 个/秒 <sup>SA</sup> | 12 个/秒 | 堆叠科技 4（`deadlock-stacking-4`） |
| T5 终极 <sup>Bob</sup> | 终极堆叠机 / Ultimate stacking beltbox | `bob-ultimate-transport-belt-beltbox` | 同 Bob 终极带 | 带速 ÷ 5 | 堆叠科技 5（`deadlock-stacking-5`） |

**默认配方（未安装 Bob's Logistics）**

| 档位 | 配方 | 制造分类 |
| --- | --- | --- |
| T1 | 传送带 ×4 + 铁板 ×10 + 铁齿轮 ×10 + 电子电路 ×4 | 手工 |
| T2 | 堆叠机 ×1 + 铁板 ×20 + 铁齿轮 ×20 + 高级电路 ×2 | 手工 |
| T3 | 快速堆叠机 ×1 + 铁板 ×30 + 铁齿轮 ×30 + 润滑液 ×100 | 带流体（装了太空时代时含冶金） |
| T4 | 迅速堆叠机 ×1 + 钨板 ×15 + 铁齿轮 ×15 + 润滑液 ×100 | 带流体或冶金 |

**Bob's Logistics 额外档位**

| 档位 | 配方 | 制造分类 |
| --- | --- | --- |
| T0 基础 | 基础传送带 ×4 + 铁板 ×5 + 铁齿轮 ×5 | 手工 |
| T5 终极 | Turbo 堆叠机 ×1 + 铁板 ×40 + 铁齿轮 ×40 + 处理器 ×10 | 手工 |

如果 Turbo 传送带由 Bob 提供（没装太空时代），T4 的堆叠机配方是「迅速堆叠机 ×1 + 铁板 ×30 + 铁齿轮 ×30 + 处理器 ×5」，并且可以直接手搓。Bob 的廉价升级规则默认只改装卸机，不改堆叠机；想连堆叠机一起改，把 [prototypes/bob_tiers.lua](prototypes/bob_tiers.lua) 里的 `CONFIG.beltbox_recipes` 设为 `"upgrade"`。

**堆叠科技**：

* `deadlock-stacking-1` ~ `deadlock-stacking-5` 由对应物流科技复制而来：以该物流科技为前置，研究量为它的 1.5 倍，并解锁该档的堆叠机与堆叠/平分解压配方；
* 原版与太空时代各档还会把上一档堆叠科技加为前置，形成研究顺序；
* T0 基础档没有独立堆叠科技，堆叠机配方直接挂在 Bob 的 `logistics-0` 上；
* 关掉「生成堆叠机」时，这些科技仍会在需要时创建，只解锁压缩/平分解压配方，不再解锁机器。

### 2.3 堆叠装卸机

**需要太空时代。** 每一档装卸机都有一个堆叠版本：保留装卸机的全部行为，速度也与同档装卸机相同，另外加上太空时代堆叠机械臂的能力：

| 引擎字段 | 取值 | 作用 |
| --- | --- | --- |
| `bulk` | `true` | 允许一次搬运一整堆物品 |
| `stack_size_bonus` | 堆叠量设置（默认 4） | 一次搬运的物品数量 |
| `max_belt_stack_size` | 堆叠量设置（默认 4） | 往传送带上堆放的最大层数 |

* 这三个都是 `loader-1x1` 原生支持的字段，**没有运行期脚本**，不增加 UPS 开销；
* 往传送带上实际能堆几层，还受势力当前的传送带堆叠研究限制，和堆叠机械臂一致；
* 配方统一为「同档装卸机 ×1 + 堆叠机械臂 ×1 + 处理器 ×1」，由太空时代的**堆叠机械臂科技**（`stack-inserter`）解锁；
* 图标沿用同档装卸机，右下角叠加堆叠机械臂徽标；
* 在物流分组里单独占一行（物品子组「堆叠装卸机」），顺序是：装卸机 → 堆叠装卸机 → 堆叠机；
* 各档按传送带速度串成升级链，升级规划器与快速替换可以直接使用；它与同档普通装卸机共享快速替换组，两者可以互相替换。

| 档位 | 物品（中文 / 英文） | 原型名 |
| --- | --- | --- |
| T0 基础 <sup>Bob</sup> | 基础堆叠装卸机 / Basic stack loader | `bob-basic-transport-belt-stack-loader` |
| T1 黄 | 堆叠装卸机 / Stack loader | `transport-belt-stack-loader` |
| T2 红 | 快速堆叠装卸机 / Fast stack loader | `fast-transport-belt-stack-loader` |
| T3 蓝 | 迅速堆叠装卸机 / Express stack loader | `express-transport-belt-stack-loader` |
| T4 Turbo | Turbo 堆叠装卸机 / Turbo stack loader | `turbo-transport-belt-stack-loader` |
| T5 终极 <sup>Bob</sup> | 终极堆叠装卸机 / Ultimate stack loader | `bob-ultimate-transport-belt-stack-loader` |

其他模组通过 [API](API.md) 创建的等级，其堆叠装卸机默认显示为「装卸机名（堆叠）」。

### 2.4 堆叠物品

原版可压缩物品各会多出一个独立物品，原型名是 `deadlock-stack-<原物品名>`，例如：

* `deadlock-stack-iron-plate` ——「铁板（堆叠成 5）」/ "Iron plate (stack of 5)"；
* 显示名里的数字取自当前的**堆叠比例**设置；
* 堆叠物品会排进原物品所在的分组末尾（例如铁板在「中间产品」的最后）；
* 每个原版可压缩物品都有专门绘制的堆叠图标。

**堆叠比例与容量**

* 默认 5：1，即 5 个基础物品 = 1 个堆叠物品；物品自身堆叠数小于比例时，以物品的堆叠数为准；
* 堆叠物品自身的堆叠数 = 向下取整（基础物品堆叠数 ÷ 生效比例）。例如堆叠数为 100 的物品，比例 5 时堆叠物品的堆叠数为 20——一格箱子仍然装 100 个基础物品；
* 因此它**压缩的是传送带上的占用**，不是箱子/车厢的总容量。比例不能整除基础堆叠数时会有一点损失，模组会在日志里提示。

**配方**

| 配方 | 原型名 | 配方分类 | 说明 |
| --- | --- | --- | --- |
| 堆叠压缩 | `deadlock-stacks-stack-<物品>` | `stacking` | 5 个基础物品 → 1 个堆叠物品（按比例），只能由堆叠机执行 |
| 平分解压 | `deadlock-stacks-unstack-<物品>` | `unstacking` | 反向；默认可以在玩家制作栏手动拆堆 |

* 堆叠物品是独立物品，**不能直接当别的配方的原料**；要先把它们拆回基础物品；
* 固体燃料、煤这类燃料的堆叠版本保留燃料属性，热值按比例提高；
* 打开「批量堆叠」后，配方一次处理 4 组（材料、产物与时间同步 ×4），总吞吐不变，只是装带更均匀；
* 打开「自动平分解压」后，捡起或挖出堆叠物品时会自动拆成基础物品；
* 打开「隐藏平分解压配方」后，平分解压配方会从玩家制作栏里移除，只能靠堆叠机拆堆。

**原版可堆叠物品**

| 解锁科技 | 物品 |
| --- | --- |
| 堆叠科技 1（`deadlock-stacking-1`） | 木材、铁矿石、铜矿石、石矿、煤、铁板、铜板、钢板、石砖、钨矿石 <sup>*</sup> |
| 堆叠科技 2（`deadlock-stacking-2`） | 铜线、铁齿轮、铁棒、硫磺、塑料棒、固体燃料、电子电路、高级电路 |
| 堆叠科技 3（`deadlock-stacking-3`） | 处理器、电池、铀矿石、铀-235、铀-238 |

<sup>*</sup> 钨矿石来自太空时代；未安装时该物品不存在，会被跳过。

其它模组可以调用 `deadlock.add_stack()` 为自己的物品生成堆叠版本，见 [API.md](API.md)。

---

## 3. 使用方法

### 3.1 最简布局

压缩和平分解压共用同一台堆叠机，只是摆放方向不同：

```
压缩：  传送带 ──▶ [装卸机] ──▶ [堆叠机] ──▶ [装卸机] ──▶ 传送带
                      输入模式      5 合 1       输出模式

解压：  传送带 ──▶ [装卸机] ──▶ [堆叠机] ──▶ [装卸机] ──▶ 传送带
                      输入模式      1 拆 5       输出模式
```

1. 研究对应档位的物流科技，再研究「堆叠科技」，解锁堆叠机与压缩配方；
2. 造 1 台堆叠机、2 台同档装卸机（需要堆叠装卸机时还要研究堆叠机械臂科技）；
3. 按上图摆成三格：装卸机把物品送进堆叠机的输入槽，堆叠机自动压缩，第二台装卸机把产物放回带子；
4. 接电。堆叠机会按输入物品自动选择压缩或平分解压配方。

### 3.2 使用技巧

* **放置**：装卸机可以用 `R` 旋转，切换它在哪一侧取货。默认与传送带同属快速替换组，可以直接把一段带子「刷」成装卸机/堆叠机，也可以刷回带子。
* **对齐**：两个运行时设置可以让装卸机在放下时自动对准相邻传送带（默认开）与库存（默认关）。
* **升级**：装卸机、堆叠机、堆叠装卸机都按档位串好了升级链，升级规划器与快速替换可以直接换档。
* **缓冲**：堆叠机有 1 格输入和 1 格输出，短时间断料或堵料不会立刻影响上下游。
* **手动拆堆**：默认可以在玩家制作栏里手动执行平分解压；嫌配方太多可以打开「隐藏平分解压配方」。
* **查看配方**：开启「在传送带箱上显示 alt 模式图标」后，按 `Alt` 可以在堆叠机上看到当前配方的图标。
* **堆叠装卸机**：适合把箱子里的整堆物品直接搬到带子上，或反过来；它往带上分层堆放的最大层数由「堆叠装卸机堆叠量」控制。

### 3.3 吞吐量参考

| 档位 | 传送带运力 | 堆叠机处理能力 | 压缩后带子上的物品数（比例 5） |
| --- | --- | --- | --- |
| 黄 | 15 个/秒 | 15 个基础物品/秒 | 3 个堆叠物品/秒 |
| 红 | 30 个/秒 | 30 个基础物品/秒 | 6 个/秒 |
| 蓝 | 45 个/秒 | 45 个基础物品/秒 | 9 个/秒 |
| Turbo | 60 个/秒 | 60 个基础物品/秒 | 12 个/秒 |

Bob's Logistics 各档按 Bob 的实际带速等比变化；修改「堆叠比例」只改变最后一列，基础物品吞吐仍与带子对齐。

---

## 4. 设置项

### 4.1 启动设置

改完需要重新开始游戏（或重启）才生效。

| 设置（原型名） | 默认 | 说明 |
| --- | --- | --- |
| 生成堆叠机（`deadlock-enable-beltboxes`） | 开 | 是否生成各档堆叠机（机器、配方与科技）。关掉后没有堆叠机，但堆叠物品由下一项单独控制。 |
| 生成堆叠物品（`deadlock-enable-stacks`） | 开 | 是否生成堆叠物品、堆叠/平分解压配方与堆叠科技。关掉就没有压缩体系。 |
| 启用装卸机（`deadlock-enable-loaders`） | 开 | 是否生成装卸机（以及它们的堆叠版本）。 |
| 启用堆叠装卸机（`deadlock-enable-stack-loaders`） | 开 | 是否为每档装卸机生成堆叠版本。需要太空时代。 |
| 堆叠装卸机堆叠量（`deadlock-stack-loader-stack-size`） | 4 | 可选 4/5/6/7/8/10/12/16；一次搬运数量，也是往带上堆放的最大层数。 |
| 堆叠比例（`deadlock-stack-size`） | 5 | 可选 4/5/8/10/16/25/32/50/64/100/128；每个堆叠物品包含的基础物品数。**不建议在已有存档里改。** |
| 自动平分解压（`deadlock-stacking-auto-unstack`） | 关 | 从地面、传送带或容器里捡到堆叠物品时自动拆开。 |
| 隐藏平分解压配方（`deadlock-stacking-hide-unstacking`） | 关 | 从玩家制作栏移除平分解压配方，禁止手动拆堆。 |
| 批量堆叠（`deadlock-stacking-batch-stacking`） | 关 | 堆叠机一次处理 4 组，均匀装带，适合超高速模组带。 |
| 在传送带箱上显示alt模式图标（`deadlock-stacking-show-alt-info`） | 开 | alt 模式下在堆叠机上显示当前配方图标。 |
| 精确堆叠机快速更换（`deadlock-strict-fast-replace-beltboxes`） | 关 | 打开后堆叠机只能与其它堆叠机快速替换。 |
| 精确装卸机快速更换（`deadlock-strict-fast-replace-loaders`） | 关 | 打开后装卸机只能与其它装卸机快速替换。 |

「生成堆叠机」与「生成堆叠物品」是两项独立开关：

| 生成堆叠机 | 生成堆叠物品 | 结果 |
| --- | --- | --- |
| 开 | 开 | 默认：各档堆叠机 + 可执行的压缩体系 |
| 关 | 开 | 不生成堆叠机，但堆叠物品、配方与科技仍在（没有机器可压缩，堆叠物品只能手动拆堆） |
| 开 | 关 | 生成堆叠机，但没有可执行的压缩配方 |
| 关 | 关 | 整套压缩体系消失，只剩装卸机 |

### 4.2 运行时设置（每玩家）

| 设置（原型名） | 默认 | 说明 |
| --- | --- | --- |
| 将装卸机卡到传送带上（`deadlock-loaders-snap-to-belts`） | 开 | 放置时自动设置朝向与模式，匹配相邻传送带。 |
| 将装卸机与库存对齐（`deadlock-loaders-snap-to-inventories`） | 关 | 放置时自动输入到它所面对或背对的库存。 |

---

## 5. 兼容性与依赖

| 依赖 | 关系 | 说明 |
| --- | --- | --- |
| base ≥ 2.0 | 必需 | 仅支持 Factorio 2.0。 |
| Space Age | 可选 | 提供 Turbo 档、堆叠装卸机与传送带分层堆放；没有它时这些内容不会生成。 |
| Bob's Logistics | 可选 | 增加 T0 基础、T5 终极（以及没装太空时代时的 Turbo 档），并启用廉价升级配方；速度自动同步 Bob 的设置。 |
| ReStack | 可选 | 沿用上游的加载顺序安排；本分支没有针对它的特殊代码。 |
| [deadlock-integrations](https://mods.factorio.com/mod/deadlock-integrations) | 另装 | 为 Factorio Extended（含 Plus）与 Xander Mod 的传送带等级提供整合。 |

**关于模组改名。** 本分支的内部名称是 `deadlock-beltboxes-loaders-CN`。其它模组里针对旧名字的条件判断（例如 `if mods["deadlock-beltboxes-loaders"] then`）不会生效；调用全局 `deadlock` API 的模组不受影响。旧名字的整合需要上游或整合模组自行兼容。

**已知限制**：传送带重贴图与地图重新配色两个选项尚未实现。

---

## 6. 安装与存档

* 在 Mod Portal 订阅，或下载 zip 放进 `%APPDATA%\Factorio\mods\`；
* 需要 Factorio 2.0；Space Age 与 Bob's Logistics 都是可选的；
* **已有存档可以直接继续**：本分支沿用上游的原型名，装卸机、堆叠机、堆叠物品与科技名称都没有变化；第一次加载会提示模组版本变化，这是正常的；
* 从上游 2.5.x / 2.6.0 切换过来时，存档里的机器与物品同样有效（会提示模组列表变化）。更早的 Deadlock's Stacking / Compact Loaders 独立模组，请先按上游说明迁移；
* 更新后如果发现配方或科技没解锁，重新加载一次存档即可——`on_configuration_changed` 会给已研究的科技补解锁；
* 不建议在已有存档里修改「堆叠比例」，已有的堆叠物品与配方会对不上。

---

## 7. 版本历史

完整的更新记录见 [changelog.txt](changelog.txt)。

| 版本 | 主要变化 |
| --- | --- |
| 2.8.2 | 堆叠机开关拆成「生成堆叠机」与「生成堆叠物品」两项 |
| 2.8.1 | 堆叠装卸机改用独立物品子组，单独占一行 |
| 2.8.0 | 新增堆叠装卸机（需要太空时代）与相关设置、API 字段 |
| 2.7.0 | 首个 CN 发行版：Bob's Logistics 支持、廉价升级配方、完整简体中文 |
| 2.6.3 | 改为独立模组名 `deadlock-beltboxes-loaders-CN` |
| 2.6.2 | 内置简体中文本地化 |
| 2.6.1 | 新增 Bob's Logistics 传送带等级支持 |
| 2.6.0 | 修正 T4 配方，支持在铸造厂制造 |
| 2.5.0 | 适配 Factorio 2.0 与太空时代 |

---

## 8. 模组开发

* **API 文档**：[API.md](API.md)。包含 `add_stack()`、`add_tier()`、`destroy_stack()`、`update_stack_loaders()` 等函数的完整说明与示例。
* **本分支新增的 API**（2.8.0）：`add_tier()` 支持 `stack_loader`、`stack_loader_item`、`stack_loader_localised_name` 三个字段；新增 `deadlock.update_stack_loaders()`，供在数据阶段末尾才创建等级的模组补做解锁与升级链。
* **打包与发布**：推送 master 后，[.github/workflows/](.github/workflows/) 会自动打包 zip、发布到 Mod Portal，并在 GitHub 创建 Release。手动打包脚本见 [API.md](API.md) 附录。

代码结构：

| 路径 | 作用 |
| --- | --- |
| [data.lua](data.lua) | 创建原版各档，初始化 API |
| [data-updates.lua](data-updates.lua) | Bob's Logistics 各档、原版堆叠物品、补做解锁与升级链 |
| [data-final-fixes.lua](data-final-fixes.lua) | 延迟创建的堆叠装卸机、堆叠物品属性更新、给角色加 `unstacking` 分类 |
| [prototypes/shared.lua](prototypes/shared.lua) | 共享常量、日志与子组定义 |
| [prototypes/create_beltbox.lua](prototypes/create_beltbox.lua) | 堆叠机实体、物品、配方与科技 |
| [prototypes/create_loader.lua](prototypes/create_loader.lua) | 装卸机与堆叠装卸机 |
| [prototypes/create_stack.lua](prototypes/create_stack.lua) | 堆叠物品与堆叠/平分解压配方 |
| [prototypes/public.lua](prototypes/public.lua) | 全局 `deadlock` API |
| [prototypes/vanilla_tiers.lua](prototypes/vanilla_tiers.lua) | 原版与太空时代各档 |
| [prototypes/bob_tiers.lua](prototypes/bob_tiers.lua) | Bob's Logistics 各档与配方定价 |
| [prototypes/vanilla_stacks.lua](prototypes/vanilla_stacks.lua) | 原版可压缩物品清单 |
| [settings.lua](settings.lua) | 全部设置项 |
| [control.lua](control.lua) | 放置吸附、自动拆堆、配置变更补解锁 |

---

## 9. 常见问题

**为什么没有堆叠机 / 压缩配方？**<br>
先确认「生成堆叠机」「生成堆叠物品」两个启动设置（默认都开），再确认已研究对应物流科技与堆叠科技。改动启动设置后需要重启游戏。

**为什么堆叠物品不能拿来造东西？**<br>
它是独立物品，所有普通配方只认基础物品。先平分解压，或打开「自动平分解压」。

**为什么压缩之后，箱子/车厢的容量没变？**<br>
堆叠物品的堆叠数按比例缩小了，一格仍然装同样多的基础物品。它优化的是传送带占用，不是库存容量。

**为什么没有 Turbo 档 / 堆叠装卸机？**<br>
它们需要太空时代。堆叠装卸机还需要先研究太空时代的「堆叠机械臂」科技。

**为什么没有基础档 / 终极档？**<br>
它们来自 Bob's Logistics；基础档还要求 Bob 的「基础传送带」存在。

**更新模组后配方或科技不见了？**<br>
重新加载存档，`on_configuration_changed` 会为已研究的科技补解锁；仍然缺失的话，检查 Factorio 日志里 `DBL:` 开头的警告。

**可以中途改堆叠比例吗？**<br>
不建议。已有的堆叠物品、配方与库存会对不上；新开存档最稳妥。

---

## 10. 鸣谢与许可

* 概念、美术与最初作者：[Deadlock989](https://mods.factorio.com/user/deadlock989)；
* 由 [shanemadden](https://mods.factorio.com/user/shanemadden) 维护，MasterBuilder 亦有贡献；
* 中文分支（Bob's Logistics 支持、堆叠装卸机与简体中文）由 tang-bai 维护；
* 日语、法语、意大利语、俄语翻译来自上游贡献者。

本模组以 **GPL-3.0 或更高版本** 发布，见 [LICENSE](LICENSE)。

反馈问题：本仓库 [Issues](https://github.com/tang-bai/factorio-deadlock-beltboxes-loaders/issues)，或上游 [Factorio 论坛帖](https://forums.factorio.com/viewtopic.php?f=94&t=57264)。附上错误信息、日志和复现步骤会快很多。

---

<sub>本 README 面向玩家；模组作者请转到 [API.md](API.md)。上游英文说明保留在 [README.en.md](README.en.md)，Mod Portal 简介见 [description.md](description.md)。</sub>
