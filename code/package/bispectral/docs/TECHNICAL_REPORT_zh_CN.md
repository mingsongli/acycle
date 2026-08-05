# Acycle Bispectral Analysis

双谱与双相干分析工具箱技术报告

算法设计、统计推断、软件实现、验证结果与用户手册

文档版本：v1.0  
软件分支：bispectral  
MATLAB：R2025b  
日期：2026-08-05

## 摘要

本报告说明 Acycle 中新增的 Bispectral Analysis 工具箱。该工具用于从一维古气候或地学时间/深度序列中估计复 bispectrum、biphase、bicoherence 及 magnitude-squared bicoherence。程序 API 可在明确选择 `InputPolicy='prepare'` 时准备不规则输入；弹窗 GUI 固定使用 `InputPolicy='strict'`，不删除、排序、合并、整段去趋势或标准化数据，但超过 10 ppm 的坐标间距偏差会在警告后线性规则化，使 FFT 分析能够继续。GUI 的正式置信推断固定为 IAAFT maximum-statistic FWER；解析 Beta、FT phase 和 pointwise 仅保留为 core API 的高级兼容与方法验证路径。

软件首选 WOSA 分段 FFT 估计；第二条路径在单记录原生 Fourier 网格上采用完整六边形核进行二维频率平滑。两者共享严格的正频、无混叠和频三角域、Kim-Powers 有界归一化、统一的预处理和显著性框架。

> **最重要的解释原则。** 显著且较高的 b² 表示 f₁、f₂ 与 f₁+f₂ 之间存在可重复的二次相位关系；它不单独证明非线性因果、能量传输方向或某个特定古气候机制。非正弦波形、谐波、代理转换、插值、轨道调谐和固定年代模型都可能改变或制造相位耦合。

表 1  工具箱交付概览

| 交付维度 | 实现结果 |
|---|---|
| 菜单与 GUI | 主列表单文件选择；Timeseries > Bispectral Analysis；科学计算参数与即时显示参数分色 |
| 分析量 | complex B、\|B\|、\|B\|²、Re(B)、Im(B)、biphase、b²；不保存冗余 b=sqrt(b²) |
| 估计器 | WOSA segmented FFT；frequency-smoothed direct estimator |
| 推断 | GUI：IAAFT maximum-statistic FWER；core API 兼容 Beta、FT 与 pointwise 高级模式 |
| 保存 | 每次 Save 新建唯一结果文件夹，内含 PDF、FIG、MAT v7.3、分析序列 CSV、复现 JSON |
| 验证 | Synthetic QPC、AR(1)、Newark、Site 1262、LR04；另含 bundled LR04/CENOGRID 800 kyr LOWESS 敏感性流程 |
| 回归 | 已知正/负控、两种估计器独立复算、尺度/反转、零 B/零分母、抗混叠、IAAFT、短记录 |

### 内容导航

1. 目标、范围与设计原则
2. 数学定义与输出量
3. 两种双谱估计算法
4. 数据预处理
5. 显著性推断与多重比较
6. 软件架构与数据流
7. 用户操作说明
8. 参数参考
9. 绘图与结果解释
10. 五数据集验证
11. 数值回归、集成测试与制品 QA
12. 复现、限制与扩展
附录 A-C：输出结构、错误警告、参考文献与版本信息

## 1. 目标、范围与设计原则

### 1.1 目标

工具箱的目标是把第三阶频域分析纳入 Acycle 的标准工作流，使用户无需离开主列表即可完成严格规则数据载入、参数设置、双谱估计、显著性分析、绘图和归档。规则化预处理由 Acycle 专用工具或程序 API 的显式 prepare 流程完成，不隐藏在本 GUI 中。重点不是生成一张高值图，而是输出可审计的复数统计量、规范化耦合强度、显著性掩膜以及完整元数据。

### 1.2 范围

- 输入为至少两列的数值文件：第一列坐标，第二列待分析序列；当前分析单变量 auto-bispectrum/bicoherence。
- FFT 估计要求规则采样；软件可按中位步长或更细的用户步长进行规则化插值，但拒绝无抗混叠滤波的粗化重采样。
- 当前结果描述记录全长上的平均相位耦合，不提供随时间或深度变化的局部双谱。
- 当前不包含 cross-bispectrum、bivariate bicoherence、正式三 taper 组合的 multitaper bispectrum 或年代模型 ensemble。

### 1.3 设计原则

- bispectrum 与 bicoherence 分开报告，避免把幅度与归一化相位一致性混为一谈。
- 严格屏蔽 DC、负频率 wrap、精确 Nyquist 以及 f₁+f₂ 超出有效域的三频组。
- zero padding 不作为新信息或新自由度；频率平滑只使用原生 Fourier bins。
- 发表级判断优先使用固定主域上的 maximum-statistic surrogate 阈值。
- 所有关键参数、实际分段几何、分辨率、警告与随机种子均写入 MAT/JSON。

## 2. 数学定义与输出量

### 2.1 Fourier 三频组与 bispectrum

对满足 f₃=f₁+f₂ 的和频三元组，第 s 个 realization 的 Fourier 系数记为 Xₛ(f)。Acycle 使用下式定义复 bispectrum：

$$B̂(f₁,f₂) = (1/R) Σₛ Xₛ(f₁) Xₛ(f₂) Xₛ*(f₁+f₂)$$

相应 biphase 为三个 Fourier 相位的闭合组合：

$$φᴮ = arg[B̂] = φ(f₁) + φ(f₂) - φ(f₁+f₂)$$

当前 FFT 除以段长，窗函数经 RMS 归一化。未标准化数据的 B 因而具有原变量三次方量纲；这里输出的是明确缩放约定下的 bispectrum amplitude，而不是按单位频率面积校准的 bispectral density。

### 2.2 Kim-Powers magnitude-squared bicoherence

$$Aₛ = Xₛ(f₁)Xₛ(f₂),    Cₛ = Xₛ(f₁+f₂)$$

$$b̂² = |Σₛ Aₛ Cₛ*|² / [(Σₛ|Aₛ|²)(Σₛ|Cₛ|²)]$$

该归一化可解释为两个复向量 A 与 C 的平方相干性。由 Cauchy-Schwarz 不等式，数值上 0≤b²≤1；软件只在数值舍入容差内截断到该范围。若分母为零或非有限，则 b² 与 biphase 都返回 NaN；即使分母有效，只要复 B 恰为 0，arg(B) 在数学上仍未定义，biphase 也返回 NaN，而不是 MATLAB 的默认 angle(0)=0。

表 2  结果结构中保持独立的双谱量

| 输出量 | 定义或单位 | 主要用途 |
|---|---|---|
| Bispectrum | 复数 B；未标准化时量纲为变量³ | 保留幅值与相位信息 |
| \|B\| 和 \|B\|² | bispectrum 的幅值和平方幅值 | 识别复双谱幅值较大的三频组；不能替代 b² |
| Re(B), Im(B) | 复数 B 的实部与虚部 | 研究对称或反对称贡献；方向反转时 Im(B) 变号 |
| Biphase | arg(B)，弧度 | 描述相位闭合关系 |
| Squared bicoherence b² | [0,1]，无量纲 | 主要耦合图与显著性统计量 |

### 2.3 正频、无混叠和频三角域

$$f₁ > 0,   f₂ > 0,   f₂ ≤ f₁,   f₁ + f₂ < fNyq$$

程序按 FFT bin 构造该三角域，排除 DC、wrapped negative frequencies 和偶数长度 FFT 的精确 Nyquist bin。该域服务于图中可直接解释的正频关系 `f3=f1+f2`，有意不包含完整 12-fold 离散时间主域中需要把 `f1+f2` 跨 Nyquist wrap 到负频率的外扇区；后者若要支持，必须作为单独模式重新定义计算与 FWER 检验族，不能静默并入当前结果。frequency-smoothed 模式还要求完整平滑核位于该域内。MaxFrequencyBins 会通过 frequency stride 改变实际计算网格并改变全图检验族；当 stride>1 时，FWER 只覆盖实际计算网格上的有限三频点，不覆盖跳过的 native FFT-bin 组合。FrequencyMin 与 FrequencyMax 都只裁切绘图范围，不进入估计器状态，也不改变显著性检验族。

### 2.4 缩放与方向恒等式

$$y=a x:  Bᵧ=a³Bₓ,  |Bᵧ|²=a⁶|Bₓ|²,  bᵧ²=bₓ²$$

$$reverse(x):  B[reverse(x)] = B*,  b²[reverse(x)] = b²$$

因此跨记录比较 raw bispectrum 必须保持同一单位、去趋势和标准化策略；方向反转不改变 b²，但会使 biphase 和 imaginary bispectrum 变号。

## 3. 两种双谱估计算法

表 3  两种估计路径的定位

| 特性 | WOSA segmented FFT | Frequency-smoothed direct |
|---|---|---|
| realizations | 多个时间或深度分段 | 单记录内的二维局部频率邻域 |
| 默认和用途 | GUI 默认；一般记录推荐 | 短记录、独立核验或平滑估计 |
| 主要参数 | 段数、重叠、窗、段内去趋势、NFFT | span、Daniell/cosine 核、原生 NFFT |
| 分辨率 | 由段长 L 决定；段数越多分辨率越低 | 由全长 N 的原生 Rayleigh 网格决定 |
| 解析自由度 | 重叠和窗导致段间相关 | 邻域 triads 共享 Fourier 系数 |
| 推荐显著性 | surrogate max-statistic | surrogate max-statistic |

### 3.1 WOSA 分段 FFT

设记录长度 N、请求 R 段、重叠比例 r，程序先计算可行段长：

$$L = ⌊N / [1 + (R-1)(1-r)]⌋$$

R 个起点均匀分布在记录范围内；整数取整造成的实际重叠率会记录为 ActualMedianOverlapPercent。每段先按 SegmentDetrendMethod 去均值或线性趋势，再施加 RMS=1 的窗函数。

$$Xₛ[k] = (1/L) Σₙ w[n] x̃ₛ[n] exp(-i2πkn/NFFT)$$

$$P̂[k] = (1/R) Σₛ |Xₛ[k]|²,    Δfᴿ = 1/(LΔt)$$

默认采用 8 段、50% overlap、Hann 窗、零填充因子 1。增加段数可降低 b² 方差，但会缩短 L，降低最低频率分辨率。研究设计时，最低目标频率最好在每段内至少出现约 3-5 个周期。Window ENBW、RayleighResolution、SegmentStarts、未覆盖样点数等均写入 metadata。

> **Zero padding 的限制。** NFFT 大于段长只会在 Fourier 轴上插值显示网格，不改善 1/(LΔt) 的 Rayleigh 分辨率，不产生新的独立 realization，也不能增加显著性自由度。默认因子 1 表示不补零。

### 3.2 二维频率平滑 direct estimator

备选估计器只对整条记录计算一次原生 FFT。对 half-width h，定义完整六边形邻域：

$$Hₕ = {(a,b): |a|≤h, |b|≤h, |a+b|≤h}$$

$$B̂ₕ = Σ(a,b) qₐᵦ X[k₁+a]X[k₂+b]X*[k₁+k₂+a+b]$$

权重 q 非负且和为 1。Daniell 核为均匀权重；raised-cosine 核分别对 a、b 和 a+b 加权。span=3 即 h=1，共 7 个 triads；span=5 共 19 个。只计算完整核可放入主域的中心，边缘不截断后再重归一化，以避免位置相关带宽。

$$Rₑ = 1 / Σ qₐᵦ²$$

Rₑ 仅为权重诊断；相邻 triads 共享 Fourier 系数，不能当作严格独立自由度。即使用户指定更大的 NFFT，该路径仍强制使用全记录原生 NFFT=N。

### 3.3 为什么没有采用朴素 DPSS multitaper

DPSS 特征向量只定义到任意正负号。三阶同 taper 乘积在 taper 变号时自身变号，因此把 segment×DPSS taper 直接当作独立 realizations，会使平均值依赖 eigensolver 的任意符号约定：

$$[-Xₕ(f₁)][-Xₕ(f₂)][-Xₕ*(f₃)] = -Xₕ(f₁)Xₕ(f₂)Xₕ*(f₃)$$

正式 multitaper bispectrum 需要三个 taper 的组合以及显式三阶 taper-coupling 权重，不能简单令自由度等于段数×taper 数。当前首版选择透明、可验证的单窗 WOSA，并以频率平滑作为第二条独立路径。

## 4. 数据预处理

### 4.1 API prepare 与 GUI strict 的执行边界

第 1--3、6--7 步只属于调用者显式选择的 core API `InputPolicy='prepare'`。GUI 的 `strict` 路径要求两列数据有限、坐标严格递增且无重复，不会删除、排序或合并观测，也不做整段去趋势或标准化。它允许不超过中位步长 10 ppm 的间距偏差，以兼容有限有效数字文本产生的微小量化误差；超过该阈值时，第 5 步改为线性中位步长插值并发出警告，而不是停止分析。第 8 步的 estimator 段内去趋势仍由 GUI 显式设置。

1. 删除第一、第二列中的非有限行。
2. 按坐标升序排序。
3. 对重复坐标的观测值求均值。
4. 由坐标间距中位数或用户指定的更细 SampleInterval 确定 Δt；粗于原始中位间距的设置被拒绝。
5. 根据 Interpolate 策略决定是否规则化采样。
6. 执行整条记录的 none、mean、linear 或 polynomial 去趋势。
7. 可选标准化为零均值、单位标准差。
8. WOSA 内对每段再执行 none、mean 或 linear 去趋势。

### 4.2 不规则采样与插值

$$δirr = maxᵢ |Δxᵢ-Δt| / Δt$$

默认 IrregularTolerance=0.01。prepare/auto 模式在 δirr 超过 1% 时规则化；always 总是规则化；never 在不规则时终止分析。GUI strict 使用独立且严格得多的 10 ppm（0.001%）阈值：阈值以内原样接受，阈值以外自动按中位步长线性插值并警告。core API 的插值方法也可选择 pchip 或 makima。若最大原始间隙超过 GapWarningFactor=5 个采样间隔，软件把警告写入结果元数据。

> **抗混叠保护。** linear、pchip 和 makima 都不是低通抗混叠滤波器。若核心 API 的 SampleInterval 比原始中位间距更粗，程序抛出 Acycle:Bispectral:AliasingRisk。弹窗 GUI 不提供通用预处理模块，也不删除、排序、合并观测或执行整段去趋势与标准化；它只对超过 10 ppm 的可恢复间距不均匀以线性中位步长插值网格替换输入序列。长间隙、插值和解析阈值近似等科学警告保留在 MAT/JSON，并在 GUI 状态栏与 MATLAB Command Window 中报告；自动插值还会显示 warning alert。

> **古气候数据的插值原则。** FFT-based bispectral estimation 要求规则网格，因此不规则坐标通常必须先插值。但插值不能恢复缺失信息，并可能改变相位；应报告原始间距、最大间隙、目标步长、插值方法和年代模型。若年龄不确定性重要，应在外层年龄模型 ensemble 中重复完整分析。

### 4.3 去趋势与标准化

core API `prepare` 默认整条记录线性去趋势、WOSA 分段去均值并标准化；GUI 固定整段 `none`、不标准化，只保留显式的段内去趋势。去趋势通常有助于降低低频泄漏，但不是无条件必须；若研究对象本身是长期非线性趋势，过强去趋势可能删除目标信息。用户应根据研究问题在 GUI 外检查原序列、趋势和处理后序列。标准化不改变 b²，但会改变 B 的幅度和单位。

表 4  古气候序列常见的数据处理风险

| 风险来源 | 可能影响 | 建议 |
|---|---|---|
| 长间断插值 | 制造平滑过渡及相位结构 | 报告 gap factor；进行不插值或不同插值敏感性分析 |
| 轨道调谐 | 把目标轨道频率和相位写入时间轴 | 避免循环论证；用独立年代模型或 ensemble |
| 过强去趋势 | 削弱真实低频耦合 | 比较 none、linear、polynomial；报告阶数 |
| 代理非线性转换 | 产生谐波或组合频率 | 结合代理物理、功率和 bispectrum amplitude 解读 |
| 非平稳耦合 | 全记录 WOSA 平均可能稀释事件 | 分段敏感性或未来使用时变双谱 |

## 5. 显著性推断与多重比较

### 5.1 Beta 点态参考

$$b² ~ Beta(1,R-1)$$

$$b²crit = 1 - α^(1/(R-1)),    p = (1-b²)^(R-1)$$

WOSA 取 R 为段数；频率平滑使用 Reff。Hann taper、50% overlap、频率泄漏和共享 Fourier 系数都会破坏严格独立性，因此该阈值只能作为探索性点态参考，不控制整幅二维图的家族错误率。

### 5.2 GUI IAAFT 与 API FT phase surrogate

- GUI 固定使用 IAAFT：精确保留样本值排序分布，并迭代逼近目标 Fourier amplitude；每个候选还必须通过谱幅相对误差容差，不合格候选会被拒绝并在允许尝试数内替换。
- FT phase-randomized：保持观测 Fourier amplitude 或 periodogram，随机化正频 Fourier 相位；只作为 core API 高级兼容、方法验证或明确的 null-model 敏感性路径。
- IAAFT 谱误差只在独立正频率上计算，排除 DC 与偶数长度的精确 Nyquist；接受数、尝试数、拒绝原因、容差和谱误差摘要均进入保存 metadata。
- 每个 surrogate 都重新执行同样的分段、段内去趋势、窗函数、频率选择和 b² 估计。

$$pⱼ = [1 + Σₘ I(b²ₘⱼ ≥ b²obs,ⱼ)] / (M+1)$$

plus-one 修正确保有限 M 下 p 值不为 0，最小可能值为 1/(M+1)。

### 5.3 Maximum-statistic 全图 FWER

$$Tₘmax = maxⱼ∈Ω b²ₘⱼ$$

Ω 明确定义为观测结果中 b² 有限的完整计算主域三频点。对每个 surrogate 只保留同一个 Ω 内的最大 b²；若候选在 Ω 任一点缺值，则拒绝并替换，而不是缩小该次检验族。有限样本判定不使用插值经验分位数。令 α=1-confidence，并将 M 个 surrogate maxima 从小到大写成 T₍₁₎≤⋯≤T₍M₎。若 c 是不小于观测统计量的 surrogate maximum 数，则 plus-one 全图 p 值为

$$p_{global} = (1+c)/(M+1).$$

取满足 `(1+c)/(M+1) <= α` 的最大非负整数 cmax，并令临界秩 `k=M-cmax`；观测 b² 必须**严格大于** T₍k₎，且其 plus-one p≤α，才判为显著，等于临界值不显著。若不存在这样的非负 cmax，则当前 M 无法达到所请求的 α。95% 时，M=20 使用第 20/20 个（最大）surrogate maximum，M=999 使用第 950/999 个；实现还用与 p 值相同的浮点比较在 α 网格边界校正整数秩。该阈值在所选 IAAFT null、有限迭代近似谱匹配、平稳性与 exchangeability 假设下，控制这个固定有限计算族中的 family-wise error rate；2% 质量门槛是独立正频 Fourier amplitude 的全局相对 L2 误差，并不表示每个窄频点都逐点达到 2%。改变频率 stride 会改变 Ω；FrequencyMin 与 FrequencyMax 都只改变可见范围，不改变 Ω 或阈值。`InferenceFamilyDefinition`、`InferenceFamilyTriadCount` 和严格比较说明进入 MAT、JSON 和真实数据验证汇总。

表 5  GUI 正式模式与 core API 兼容模式

| 模式 | 控制对象 | 建议用途 |
|---|---|---|
| GUI: None | 立即隐藏最新缓存轮廓；新 Run 跳过 surrogate | 关闭推断/显示的状态；不是另一种 null 方法 |
| GUI: IAAFT surrogate max-statistic | 最大统计量统一阈值 | GUI 唯一正式二维推断；控制固定计算主域 FWER |
| API: none | 不执行统计推断 | 算法调试、程序化数值检查 |
| API: analytical | 近似点态 Beta | 兼容与方法验证；不可称为全图显著 |
| API: surrogate-pointwise | 每个格点的 Monte Carlo p | 高级兼容；不控制整图多重比较 |
| API: FT phase surrogate-global | FT phase null 下的最大统计量 | 高级兼容与 null-model 敏感性，不是 GUI 正式设置 |

> **默认层次需区分。** `bispectralDefaults` 的显著性默认是 `none`，而其正式 surrogate 参数默认是 999 个 IAAFT；仅当 API 调用者显式选择推断时才使用。GUI 选择 IAAFT 后，Run 使用 `surrogate-global` IAAFT：199 个是交互预览，研究结果建议至少 999 个。从已算 IAAFT 切到 `None` 只隐藏缓存轮廓；在 `None` 状态重新 Run 会跳过 surrogate 并生成新的无推断结果。切回与最新缓存完全一致的 IAAFT 设置可立即恢复，否则等待下一次 Run。

## 6. 软件架构与数据流

![图 1  从 Acycle 主列表到分析、推断与多格式保存的数据流。]({{FIG_WORKFLOW}})

### 6.1 菜单接入

入口为 Acycle 主列表 > Timeseries > Bispectral Analysis。AC.m 要求且只允许选择一个文件，拒绝文件夹和不支持扩展名；先尝试 load，失败后使用 readmatrix。至少需要两列数值，随后把数据和路径写入 handles 并调用 bispectralGUI(handles)。

支持扩展名为 .txt、.csv、.res、.dat、.out、.tab 以及无扩展名文件。第一列解释为坐标，第二列解释为分析值；额外列不会参与本模块分析。

### 6.2 模块职责

表 6  code/package/bispectral 中 15 个正式 MATLAB 文件

| 文件 | 职责 |
|---|---|
| bispectralGUI.m | 参数窗、控件联动、进度或取消、Run 与 Run & Save |
| bispectralDefaults.m | 默认参数；短记录动态 estimator 或段数选择 |
| bispectralAnalyze.m | 公共 API；串联预处理、估计、显著性和结果结构 |
| bispectralPreprocess.m | 清洗、排序、去重、规则化、去趋势、标准化 |
| bispectralEstimate.m | WOSA 或频率平滑、主域、FFT、B 与 b² |
| bispectralSignificance.m | none、Beta、逐点 surrogate、max-stat FWER |
| bispectralSurrogate.m | FT phase-randomized 与 IAAFT null |
| bispectralPlot.m | overview、单量图、色标、显著轮廓、周期轴、峰值 |
| bispectralSave.m | 每次保存创建唯一目录，并事务性写入 PDF、FIG、MAT、CSV、JSON |
| bispectralSelfTest.m | 确定性数值回归；不写文件 |
| bispectralValidateExamples.m | 五数据 IAAFT 方法验证驱动及汇总 |
| bispectralLocalDataValidation.m | bundled LR04 与三段 CENOGRID 的规则化、LOWESS 敏感性和实际 Overview QA |
| bispectralAcycleDirectory.m | 统一解析 Acycle 实时地址栏、保存目录 fallback 与数据载入目录 |
| bispectralLoadAcycleSelection.m | AC 菜单选择到模块 reader 的最薄适配层 |
| bispectralReadDataFile.m | 无弹窗读取并验证真实两列数值文件 |

### 6.3 短记录与控件联动

WOSA 每段至少 32 点。GUI 先按 strict/auto 规则预演采样处理，再根据预期规则网格的样本数（而不是原始行数）把默认 8 段向下调整；预期网格只有 32--63 点、无法容纳 3 个 WOSA 分段时，自动切换到 frequency-smoothed。同一个预期样本数也用于 WOSA 可行性和预期频率轴校验，实际运行仍由处理后网格再次接受 estimator 的硬校验。WOSA 模式启用段数、overlap 与 zero padding；frequency-smoothed 模式启用 span 与 kernel。

### 6.4 运行控制与异常恢复

Run 与 Run & Save 共用参数读取和分析流程。运行期间 Run、Run & Save 与 Close 暂时禁用，并显示可取消进度框。取消产生 Acycle:Bispectral:Canceled；其他异常写入状态栏与 MATLAB Command Window。超过 10 ppm 的可恢复采样不均匀会自动插值，分析完成后在状态栏、Command Window 和 warning alert 中报告；alert 调用本身有异常隔离，不会反向中断已经完成的分析。可恢复的 GUI 参数错误包括越界、整数控件含小数、参数组合冲突，以及参考周期或频率对超出理论 Nyquist 频率/频率和上限；每次操作只汇总一次，数值项恢复为该数据的推荐值，文本项恢复为上次有效值。编辑回调已纠正的记录会跨普通 Preview Run 保留到下一次成功 Run & Save，并连同实际生效参数写入 MAT/JSON；只有原子结果目录已经建立后才消费这批记录。新数值结果也只在候选图完整渲染后提交给 GUI；保存失败保留可操作的新结果和未归档纠正记录，并明确显示 Save failed。只要分析与绘图已完成，后续保存失败不会吞掉科学警告或自动插值 alert。strict 下的 NaN、乱序、重复或过短数据仍直接停止；只有采样间距不均匀被警告并规则化。onCleanup 在成功或失败后恢复控件并关闭进度框；方法帮助仍可由用户主动打开信息窗。

## 7. 用户操作说明

### 7.1 图形界面操作

1. 在 Acycle 主列表中选择一个至少两列的数值文件。不要同时选择多个文件。
2. 打开 Timeseries > Bispectral Analysis。确认顶部文件名、有效样本数、坐标范围、中位步长、Nyquist 和最大间距偏差。
3. GUI 不提供通用预处理控件。输入必须有限、严格递增且无重复；不超过 10 ppm 的间距偏差原样通过，超过 10 ppm 时 GUI 警告并线性插值到中位步长规则网格后继续。GUI 仅保留显式的段内去趋势设置。
4. 选择 WOSA 或 Frequency-smoothed。WOSA 通常从 8 段、50% overlap、Hann、pad=1 开始。
5. 设置频率范围。最低目标频率应在每段内有足够周期；不要把 zero padding 当作分辨率。
6. GUI 预览默认使用 199 个 IAAFT maximum-statistic surrogates；用于研究定稿时设置至少 999 个 IAAFT surrogates。
7. 点击 Run 仅绘图；点击 Run & Save 新建一个不重名的结果文件夹，并将 PDF、FIG、MAT、CSV 与 JSON 全部写入其中。
8. 先在独立的数据准备步骤检查分析序列，再看 Overview 顶部两个 power 轴、下方 \|B\| 与 b²，最后以全图显著轮廓和 biphase 辅助解释。

### 7.2 推荐的研究工作流

- 探索阶段：在 GUI 外比较数据准备或去趋势策略，在 GUI 内比较分段数；用 99-199 个 surrogate 快速检查。
- 定稿阶段：固定外部数据准备和实际计算参数；使用至少 999 个 surrogate；保存随机种子与所有 metadata。
- 稳健性阶段：改变段长、外部插值方式和年代模型，检查结论是否稳定；FrequencyMin/Max 只改变显示窗，不能当作新的计算敏感性试验。
- 发表阶段：同时报告 power、bispectrum amplitude、b²、阈值方法、有效域及非显著结果。

### 7.3 MATLAB 命令行 API

```matlab
repo = '/path/to/acycle';
addpath(genpath(fullfile(repo,'code')));

data = load('your-two-column-data.txt');
options = bispectralDefaults(data);
options.SignificanceMethod = 'surrogate-global';
options.NumSurrogates = 999;
options.SurrogateType = 'iaaft';
options.MaxFrequencyBins = 1024;
options.InputName = 'your-two-column-data.txt';
options.CoordinateUnit = 'kyr';

result = bispectralAnalyze(data,options);
fig = bispectralPlot(result,'Quantity','overview');
files = bispectralSave(result,fig,pwd,options.InputName);
```

## 8. 参数参考

表 7  GUI 与主要程序参数

| 分组 | 参数 | API 默认 / GUI 状态 | 说明 |
|---|---|---|---|
| 预处理 | InputPolicy | prepare / strict（固定） | prepare 可显式清洗和规则化；GUI strict 不删除、排序或合并输入行 |
| 预处理 | Interpolate | auto / auto（固定） | API 可选 auto、always 或 never；GUI 在超过 10 ppm 时警告并线性插值 |
| 预处理 | InterpolationMethod | linear / 不显示 | API prepare 可用 linear、pchip 或 makima |
| 预处理 | SampleInterval | [] / []（固定） | API 仅允许自动或更细步长；GUI 使用原始中位步长，必要时据此建立规则插值网格 |
| 预处理 | DetrendMethod | linear / none（固定） | GUI 不做整段去趋势；API 可用 none、mean、linear 或 polynomial |
| 预处理 | PolynomialOrder | 2 / 不显示 | 仅 API polynomial 使用 |
| 预处理 | SegmentDetrendMethod | mean | none、mean 或 linear |
| 预处理 | Standardize | on / off（固定） | GUI 不标准化；API prepare 可选择 |
| 估计 | Estimator | wosa | WOSA 或 frequency-smoothed |
| 估计 | NumSegments | 8（动态） | 至少 3；每段至少 32 点 |
| 估计 | OverlapPercent | 50 | 范围 [0,90) |
| 估计 | Window | hann | hann、hamming、blackman 或 rectangular |
| 估计 | ZeroPaddingFactor | 1 | 只改变 FFT 网格，不改变 Rayleigh 分辨率 |
| 估计 | FrequencySmoothingSpan | 3 | 奇数且至少 3；3=7 triads，5=19 |
| 估计 | FrequencySmoothingKernel | daniell | daniell 或 cosine |
| 频率 | FrequencyMin | 0 | 仅控制绘图下限；计算始终保留完整可计算正频域并排除 DC |
| 频率 | FrequencyMax | Nyquist | 仅控制绘图上限；计算仍到最高正 bin |
| 频率 | MaxFrequencyBins | 512 | 过多 bins 时用 stride 限制实际计算二维矩阵 |
| 推断 | SignificanceMethod | none / surrogate-global | API 默认 none；GUI 的 None 新 Run 跳过推断，IAAFT 新 Run 计算 max-stat；切换显示优先复用最新匹配缓存 |
| 推断 | ConfidenceLevel | 0.95 | 范围 (0.5,1) |
| 推断 | NumSurrogates | 199 | GUI 预览 199；研究建议至少 999 |
| 推断 | SurrogateType | iaaft | GUI 固定 IAAFT；API 的 phase 仅为高级兼容与方法验证 |
| 推断 | IAAFTIterations | 200 | 仅 IAAFT 使用；另以谱幅相对误差容差筛除不合格 surrogate |
| 推断 | RandomSeed | 1 | 保证复现 |
| 输出 | PlotQuantity | overview | GUI 提供 overview、b²、\|B\| 或 biphase；不单独显示与 b² 单调等价的 b，也不把 Re、Im 作为常规图件 |
| 输出 | PlotKeepStrongestBispectrumFraction | 0.5 | 仅绘图：按 \|B\| 自身分布独立保留最高 50% |
| 输出 | PlotKeepStrongestBicoherenceFraction | 0.5 | 仅绘图：按 b² 自身分布独立保留最高 50%；biphase 也使用此强度蒙版 |
| 输出 | PlotColorGrid | 32 | 所有二维图共享的离散 colormap 颜色级数；GUI 可设 4–256 |
| 输出 | PlotReferencePeriods | [] | 仅绘图：周期序列 b 对应参考线 f1+f2=1/b；GUI 空格分隔并以 Tab/Enter 提交，且要求 1/b<Nyquist |
| 输出 | PlotFrequencyPairs | 0×2 | 仅绘图：GUI 语法 `f1 f2; f3,f4`；每对要求两频率均小于 Nyquist 且 f1+f2<Nyquist，绘制 x=f1、y=f2 细点线，外侧仅标 1/f1、1/f2 数值；顶端文字中心对齐竖线，右侧文字中心对齐横线 |
| 输出 | PlotPeakCount | 5 | 只在有可报告峰值时标注 |
| 输出 | ShowPeriodAxes | on | 在频率轴上方添加 period 轴 |

## 9. 绘图与结果解释

### 9.1 Overview 布局

overview 顶部为左右两个 log-y 能谱轴。两者重复同一条对处理后序列先去均值、再计算的 Thomson 2π MTM（NW=2、K=3、NFFT=5N）；该能谱独立于 WOSA 或 frequency-smoothed 双谱估计器，只为两个二维列提供一致的一维频率参照。左轴与下方 log10\|B\| 图严格对齐，右轴与下方 b² 图严格对齐，并共享相同频率横轴范围；上轴不重复 xlabel，下方 map 不另加重叠标题，也不再显示输入序列。每次重绘都只用当前可见频率区间内有限且为正的功率设置两个共同 y-limit：最小值落在 log-y 轴底部，最大值位于对数高度 80% 处，顶部保留 20% 供后续写字；每个 y 轴至少保留 3 个非空数字刻度。能谱图名采用 normalized 坐标上移，能谱轴与下方 map 的垂直间距也稍加大。对齐依据是 axis square 后真正可见的 plot box，而不是可能更宽的 axes 外框；两个水平 colorbar 保持在 map 与底部 caption 之间。图窗标题会去掉已知输入文件扩展名。图面参考 Da Silva et al. (2019) Figure 2 将一维功率谱与二维 bicoherence 并置的呈现原则；布局、配色和绘图代码为原创实现。GUI 只保留 overview、b²、\|B\| 和 biphase；复 B 的实部与虚部仍保存在 MAT 中供专门研究使用，但不作为常规独立图件。

所有 Overview 与单图统一使用完整 CData、加密 meshgrid、pcolor、shading interp、独立 AlphaData 掩膜、同一 Colormap grid # 和 5 条细数值等高线；不绘制非冗余三角域的两条边线，域外仍为透明白色。完整保留 100% 时使用红-白-蓝发散色系；strongest-value 比例低于 100% 时，弱值透明，保留的 \|B\| 与 b² 使用白-红子色系以避免低值蓝区主导视觉，biphase 仍保留红-白-蓝相位色系。显著性仍在原始 FFT 格点上判定，但逻辑掩膜会先双线性投影到与色面完全相同的显示网格，再绘制粗黑 0.5 轮廓，避免粗格点锯齿。与 plot box 对齐的顶部 period 轴、方法注释和可用峰值标签同步绘制。图中所有具有 FontSize 的对象都以 point 为准执行不低于 6 pt 的最终防线；主轴、period 轴与标题、频率对数字、colorbar 及底部说明使用更大的显式字号。

GUI 将计算状态与显示状态分离。完成一次 Run 后，FrequencyMin/FrequencyMax、Figure、两套 strongest-value 比例、Colormap grid #、参考周期、frequency pairs、峰值标注和顶部 period 轴都只重绘缓存结果。从 IAAFT 切到 None 时立即隐藏显著性轮廓；选回与最新计算完全一致的 inference 配置时直接恢复；未计算的 IAAFT 或改变后的置信参数必须等待下一次 Run。若在 None 状态点击 Run，则本次明确跳过 surrogate 推断并用无推断结果更新缓存。估计器、分段、窗、平滑和 computed-bin 等实质计算参数改变时，已有图仍保留并由状态栏提示等待 Run。每张图把最终 canonical quantity、裁剪后的有效频率范围、两套 retain、色级、参考周期、frequency pairs、标注、period 轴、2π-MTM 元数据和显著性显示记录为 `BispectralRenderSettings`；Run & Save 将其原样写入 MAT 与 JSON，避免程序 API plot override 与保存配置不一致。

### 9.2 推荐读图顺序

1. 检查处理后序列是否保留研究信号，并识别异常值、间断和非平稳区段。
2. 检查 2π-MTM power：目标 f₁、f₂、f₁+f₂ 是否有可解释的频谱能量。
3. 查看 \|B\|：确认耦合候选不是只由极低分母产生的高归一化值。
4. 查看 b² 与全图显著轮廓：只有超过固定主域 max-stat 阈值的格点才称为全局显著。
5. 查看 biphase，并结合坐标方向、代理物理和外部机制约束；只有专门研究相位对称性或方向反转时，才从 MAT 中进一步使用 Re(B) 与 Im(B)。

### 9.3 可以和不可以得出的结论

表 8  双相干结果的审慎措辞

| 可以说 | 不能仅凭 bicoherence 说 |
|---|---|
| 某三频组在设定分段或频域上具有稳定二次相位关系 | f₃ 必然由 f₁、f₂ 的非线性动力过程生成 |
| 该三频组超过了所述 surrogate 全图阈值 | 存在确定的因果方向或能量传输方向 |
| 结果在特定预处理与固定年代模型条件下成立 | 结果自动排除了谐波、插值、调谐或代理转换 |
| 非显著表示本次设置下未检出 | 记录中绝对不存在任何非线性或时变耦合 |

## 10. 五数据集验证驱动与历史数值基线

### 10.1 当前验证驱动与历史制品的边界

当前 `bispectralValidateExamples` 使用 WOSA、Hann、zero padding=1、`MaxFrequencyBins=256` 的实际计算网格上限、标准化、auto/linear 插值和 IAAFT maximum-statistic 全图阈值。程序默认 199 个 IAAFT surrogate；研究定稿应显式设为至少 999。FrequencyMin/Max 仅控制显示，不改变计算网格或检验族。Synthetic 使用 16 段、0% overlap；其余四组使用 7 段、50% overlap。五组包括数值正控、数值负控和 Newark、Site 1262、LR04 三组真实记录。

> **历史数值限制。** 下列 10.2--10.8 表格、数值和嵌图来自 2026-08-01 的 999 个 FT phase-randomized maximum-statistic core 回归制品。它们只用于追踪旧实现的数值基线，不是当前 GUI 的 IAAFT 正式置信结论，也不能替代重新运行当前 `bispectralValidateExamples(...,'NumSurrogates',999)`。Newark 与 Site 1262 尚无这条当前 IAAFT 五数据路径的正式制品；bundled LR04/CENOGRID 的独立 999-IAAFT 正式复验及其不同准备流程见 10.9，不能与本历史表混用。

表 9  历史 FT 回归数据与实际估计几何（估计几何不代表当前 IAAFT 已重跑）

| 数据 | N→处理 N | dt | 段数×L | stride / triads | 处理说明 |
|---|---:|---:|---:|---:|---|
| Synthetic QPC | 4096→4096 | 1 sample | 16×256 | 1 / 4032 | 无插值；whole none / segment mean |
| AR(1) 0.7 | 2001→2001 | 1 sample | 7×500 | 1 / 15500 | 无插值；linear / linear |
| Newark 2-km | 2353→2352 | 0.85 m | 7×588 | 2 / 5402 | 0.80-0.90 m；auto linear；linear / linear |
| Site 1262 XRF-Fe | 3016→2946 | 0.02 m | 7×736 | 2 / 8464 | 0.01-0.18 m；最大 gap=9；linear / linear |
| LR04 benthic δ18O | 2115→2129 | 2.5 kyr | 7×532 | 2 / 4422 | 1-5 kyr 原始间距；auto linear；linear / linear |

### 10.2 历史 FT 结果汇总

表 10  2026-08-01 历史 999-FT-surrogate maximum-statistic 结果

| 数据 | max b² | (f₁,f₂,f₁+f₂) | 95% 阈值 | 最小全局 p | 显著 triads |
|---|---:|---|---:|---:|---:|
| Synthetic | 0.996769 | 0.117188, 0.066406, 0.183594 | 0.528406 | 0.001 | 7 |
| AR(1) | 0.845651 | 0.256, 0.136, 0.392 | 0.883294 | 0.194 | 0 |
| Newark | 0.856738 | 0.238095, 0.002001, 0.240096 | 0.860751 | 0.057 | 0 |
| Site 1262 | 0.834872 | 14.198370, 5.774457, 19.972826 | 0.864173 | 0.159 | 0 |
| LR04 | 0.880499 | 0.173684, 0.009774, 0.183459 | 0.855824 | 0.020 | 1 |

> **历史基线结论。** 在旧 FT phase null、旧预处理和旧计算网格下，QPC 正控通过、AR(1) 阴性对照未检出；Newark 与 Site 1262 未超过旧阈值，LR04 有 1 个旧阈值以上格点。这些陈述严格限定于该历史 FT 制品。当前 GUI 改用 IAAFT 后，阈值和显著格点必须重新计算；旧结果不能外推为当前科学结论。

### 10.3 Synthetic QPC 正控（历史 FT 基线）

合成信号按 256 点分段构造，每段随机 f₁、f₂ 相位，并设置 φ₃=φ₁+φ₂+0.45；因此理论 biphase 为 -0.45 rad。目标频率落在精确 FFT bins：f₁=30/256、f₂=17/256、f₃=47/256；十进制值分别为 0.117188、0.066406 和 0.183594。

目标三频组 b²=0.996769，超过全图阈值 0.528406；估计 biphase=-0.434932，圆周误差 0.015068 rad。目标 bin 同时为全图最强峰，共检出 7 个显著 triads。完整精度保存在 MAT、JSON 和表 11 中。

![图 2  历史 FT 回归的 Synthetic QPC 正控；黑色轮廓不代表当前 IAAFT 已重跑。]({{FIG_SYNTHETIC}})

### 10.4 AR(1) 0.7 阴性对照（历史 FT 基线）

Acycle 示例 AR(1) 序列用于检查强红噪声背景下是否出现全图伪阳性。网格内最大 b²=0.845651，低于阈值 0.883294；最小全局 p=0.194，显著 triads=0。该单一 realization 是回归阴性对照，不等同于对 5% FWER 的完整 Monte Carlo 校准。

![图 3  历史 FT 回归的 AR(1) 0.7 阴性对照；图中阈值不是当前 GUI IAAFT 阈值。]({{FIG_AR1}})

### 10.5 Newark 2-km 记录（历史 FT 基线）

输入原始间距为 0.80-0.90 m，相对中位步长最大偏离 5.88%，因此 auto 模式规则化为 dt≈0.85 m。最大 b²=0.856738，位于 (0.238095, 0.002001, 0.240096) m⁻¹，略低于阈值 0.860751；最小全局 p=0.057，显著 triads=0。

该数据因 MaxFrequencyBins 限制采用 stride=2，报告中的最大值是实际计算网格上的最大值，而不是对每一个原生 FFT bin 的穷举；FrequencyMax 只控制图中显示的子范围。

![图 4  Newark 2-km 的历史 FT 回归图；当前 IAAFT 正式结论需重新计算。]({{FIG_NEWARK}})

### 10.6 Site 1262 XRF-Fe（历史 FT 基线）

原始间距为 0.01-0.18 m，规则化步长约 0.02 m；最大原始间隙为 9 个步长。线性插值跨越该间隙，不能恢复缺失信息，因此任何局部高值都必须结合数据覆盖与敏感性分析解释。

网格内最大 b²=0.834872，位于 (14.198370, 5.774457, 19.972826) m⁻¹，低于阈值 0.864173；最小全局 p=0.159，显著 triads=0。该数据同样采用 stride=2。

![图 5  Site 1262 XRF-Fe 的历史 FT 回归图；当前 IAAFT 正式结论需重新计算。]({{FIG_SITE1262}})

### 10.7 LR04 benthic δ18O stack（历史 FT 基线）

LR04 输入覆盖 0-5320 ka，共 2115 点，原始间距 1-5 kyr；auto 模式按中位间距 2.5 kyr 规则化，处理后 N=2129。该记录本身使用固定并受轨道调谐影响的年代模型，因此本测试是软件实测数据验证，不是 Liebrand & de Bakker (2019) 移动 imaginary bispectrum 工作流的复现。

网格内最大 b²=0.880499，位于 (0.173684, 0.009774, 0.183459) kyr⁻¹，对应约 5.76、102.31 和 5.45 kyr；超过阈值 0.855824，全图 p=0.020，显著 triads=1，biphase=-0.289891 rad。峰值靠近高频端，其稳健性需通过采样分辨率、插值、低通和年代模型 ensemble 敏感性分析评估，不能直接命名为轨道能量传输或组合音。

![图 6  LR04 的历史 FT 回归图；旧 FT null 下 1 个格点超过阈值，不是当前 IAAFT 结论。]({{FIG_LR04}})

### 10.8 历史 FT 制品的九项验收判据

表 11  2026-08-01 历史 FT 回归 9 项判据

| 判据 | 预设标准 | 实际结果 | 结论 |
|---|---|---|---|
| 目标 b² | >0.90 | 0.9967688053 | 通过 |
| 目标全局显著 | mask=true | threshold=0.528406；true | 通过 |
| 目标频率恢复 | 误差≤0.5 Rayleigh | f₁/f₂ 误差均为 0 | 通过 |
| biphase 恢复 | 圆周误差<0.12 rad | 0.0150684 rad | 通过 |
| 目标为最强峰 | 最大峰位于目标 bin | k₁=30, k₂=17 | 通过 |
| AR(1) 无显著 | 显著 triads=0 | 0 | 通过 |
| b² 有界 | [0,1] 容差内 | 五组全部满足 | 通过 |
| 无定义 biphase | 零分母或零 B 为 NaN | 五组均满足；专门精确零 B 自测覆盖 | 通过 |
| 输出完整 | 历史判据为 5×5 文件非空 | 25/25 非空；当前 driver 另要求每个结果目录恰有 5 个标准文件 | 通过 |

### 10.9 Bundled LR04/CENOGRID LOWESS 敏感性流程

`bispectralLocalDataValidation(outputParent)` 默认读取仓库 `data/Examples` 中的 LR04 与 CENOGRID 原始文件，分析 LR04 全记录以及 CENOGRID 0--5、10--15、50--55 Ma 三段。外层准备明确使用核心 `InputPolicy='prepare'`：删除非有限值、排序、合并重复坐标，并总是按原始中位步长重建严格等距的线性网格，避免低于 1% prepare 容差的轻微抖动在后续 strict 分析才失败。metadata 分开记录 `OriginallyIrregular`（strict 10 ppm 容差）和 `RegularGridReconstructed`。随后保留 regularized 敏感性对照，并以 `smoothdata(...,'lowess',spanSamples)` 去除用户指定的趋势；默认窗口为 800 kyr，正式 driver 默认 999 个 accepted IAAFT surrogate 与 `MaxFrequencyBins=1024`。

每个 result 的 `ExternalPreprocessing` 同时记录 prepare metadata、LOWESS 样点数、按 `(spanSamples-1)×dt` 定义的有效支撑宽度，以及端点只使用可用观测、不反射、不填充、不外推的策略。实际双谱计算重新进入 strict 策略，因而不会第二次修改外层准备后的序列。验证汇总逐例记录 computed axis-bin count、原生频率 bin stride、Rayleigh resolution 与 computed frequency maximum，明确区分数值网格和加密显示 mesh；同时记录实际 IAAFT 类型、接受数、迭代数、谱误差容差、尝试或拒绝数、随机种子、固定检验族定义及其有限三频点数。命名由 LOWESS 参数自动生成，例如 `lowess800kyr`，避免窗口改变后仍留下固定的 `800k` 文件名。

每个 raw 与 primary LOWESS 结果在保存前程序核验：Overview 含左右两个 log-y 2π-MTM 轴及两条实际曲线，两曲线逐点相同并与处理后序列重新计算的结果一致；MTM metadata 与 RenderSettings 均明确记录 NW=2、K=3、NFFT=5N 和先去均值；两个 power 实际 plot box 分别与下方 \|B\|、b² 对齐且横坐标范围一致；上轴标题和 y-label 精确，下方 map 坐标标签存在、map title 与上轴 xlabel 为空；两个 horizontal/southoutside colorbar 位于 map 与底部 caption 之间；总标题与 RenderSettings 一致且不含已知数据文件扩展名；两张图的独立 strongest-value AlphaData 均有可见节点，并且两套 retain fraction 与各自原始统计量重新求出的 cutoff 和实际绘图 cutoff 一致。QA 布尔值、MTM metadata、plot-box/colorbar 位置及 cutoff 同时写入外部预处理 metadata。规则化但未去 LOWESS 的结果以相同 Overview 保存作为敏感性对照。每次验证使用毫秒时间戳和冲突后缀创建严格不重名的总目录，不复用旧输出。

2026-08-03 在 MATLAB R2025b 完成正式复验，输出目录为
`/Users/mingsongli/Library/CloudStorage/Dropbox/Acycle/NeedToDo/bispectral/LR04_CENOGRID_validation_20260803_025644_609`。四组 LOWESS 主结果均使用 999 个 accepted IAAFT surrogate、0 个 rejected、999 次 attempts，实际 frequency-bin stride 均为 1；driver 返回 `Passed=true`，进程 exit code 为 0，完整日志没有 MATLAB warning、error、GraphicsView、canvas 或 peer-tree 异常。12 张 PDF（8 张 Overview、4 张 LOWESS diagnostic）均能解析并已逐页视觉检查，没有重叠、裁切、空白 b²、像素块或图形场景故障。

表 12  2026-08-03 bundled 数据 999-IAAFT maximum-statistic FWER 正式结果

| 数据 | FWER 阈值 | 可见窗内显著 triad | 完整计算域显著 triad | ≥800 kyr 功率，raw→LOWESS |
|---|---:|---:|---:|---:|
| LR04 0--5.32 Ma | 0.841139286963534 | 3 | 7 | 0.7315→0.0022 |
| CENOGRID 0--5 Ma | 0.882428296649124 | 0 | 0 | 0.6396→0.0012 |
| CENOGRID 10--15 Ma | 0.846500330328155 | 0 | 1 | 0.7530→0.0113 |
| CENOGRID 50--55 Ma | 0.850417194695958 | 0 | 11 | 0.3675→0.0199 |

“可见窗内”只描述保存图件的显示范围；阈值始终由完整、固定的有限计算族确定。因此 CENOGRID 10--15 Ma 与 50--55 Ma 虽在默认可见范围内均为 0，完整计算域内分别仍有 1 和 11 个超阈值 triad；这不构成显示范围改变 FWER family 的证据。

## 11. 数值回归、集成测试与制品 QA

### 11.1 确定性数值自测

表 13  bispectralSelfTest 的主要数值

| 测试 | 最新数值 | 意义 |
|---|---:|---|
| 已知耦合 b² | 0.9984580031 | 强正控 |
| 非耦合 b² | 0.0094106881 | 同频率、随机 φ₃ 负控 |
| biphase 误差 | 1.49444×10⁻⁴ rad | 相位约定正确 |
| WOSA 独立公式复算：B / b² 误差 | 0 / 0 | 与直接矩阵公式逐点一致 |
| 频率平滑独立复算：B / b² 误差 | 0 / 0 | 七点六边形核逐点一致 |
| 幅度×2：B 缩放误差 | 0 | 验证 B∝a³ |
| 幅度×2：b² 变化 | 0 | 验证归一化尺度不变 |
| WOSA 反转：B 误差 | 1.53×10⁻¹⁶ | 验证 B→B* |
| WOSA 反转：b² 误差 | 2.07×10⁻¹⁵ | 验证 b² 不变 |
| 频率平滑反转：B 误差 | 7.57×10⁻¹⁶ | 第二路径复数恒等式 |
| 频率平滑反转：b² 误差 | 1.13×10⁻¹⁴ | 第二路径归一化恒等式 |
| IAAFT 排序分布 / 谱幅误差 | 0 / 0.0126 | 边缘分布精确保留；谱幅近似收敛 |
| 39-surrogate 阈值 | 0.3533436329 | 快速 global 推断回归 |
| M=20、95% 临界秩 | 20 / 20 | plus-one 边界必须使用最大 surrogate statistic；不虚报依赖种子的阈值数值 |
| 临界值 equality | 不显著 | 严格 `observed > critical`，ties 保守拒绝 |

自测还验证：正分母且复 B 精确为零时 biphase=NaN；常数序列零分母返回 NaN；粗化 SampleInterval 触发 AliasingRisk；重复坐标合并；不规则坐标自动规则化；47 点记录自动走 frequency-smoothed；frequency-smoothed 强制原生 NFFT；span=3 核恰含 7 个 triads；surrogate p 值使用 plus-one 修正。39-surrogate 项只用于快速回归，不应称为正式 FWER 校准。

### 11.2 集成与静态检查

表 14  集成与静态检查

| 检查 | 结果 |
|---|---|
| package 单元与 GUI/绘图/保存回归 | 当前 31 项；R2026a 下 29/31 通过，全部 8 项 I/O/间距测试通过，另 2 项仅为 `-batch` web-component 像素几何断言 |
| Acycle 主列表回归 | test_ac_main_list：19/19 通过 |
| 菜单路由 | 标签、callback、数据加载和 bispectralGUI(handles) 调用均存在 |
| GUI 烟雾测试 | 47 点记录参数窗创建、Run 预览、结果图和 Nyquist 联动通过 |
| 短记录 | 32、33、47、63 点路径核验；47 点正式自测自动切换 frequency-smoothed |
| 重复坐标 GUI | 默认 Nyquist 为有限值，窗口正常打开 |
| MATLAB checkcode | 本轮修改的 Bispectral 文件均为 0 条消息；22 个 bispectral 相关 .m 文件仍纳入完整检查目标 |
| git diff --check | 通过 |

最准确的测试表述是：菜单代码路径核对 + 参数窗口烟雾测试 + 实际分析、绘图和保存运行。报告不把这些软件测试解释为古气候机制证据。

### 11.3 历史五数据制品完整性（2026-08-01）

旧 FT 五组分析共生成 25 个主要制品；连同 synthetic source、summary 与 validation report，历史验证目录共有 28 个文件。5 个 PDF 均为有效单页 PDF并通过当时的逐页视觉检查；5 个 FIG 可由 openfig 打开；5 个 MAT 为 v7.3 且包含完整 result；JSON、MAT、CSV、summary 与 report 的关键参数和维度一致。该段只陈述 2026-08-01 历史制品；当前 bundled LR04/CENOGRID 的 IAAFT 正式复验见 10.9，二者不能混用。

历史 CSV 十进制回读与 MAT 的最大相对差约 4.0×10⁻¹⁵，属于文本序列化舍入；当时 999 个 FT 代理最大值均有效，保存阈值与代理最大值的 95% 分位数一致。当前 bundled IAAFT 制品已另外核验接受数、尝试与拒绝数、谱误差容差、固定检验族和 plus-one 临界秩，结果见 10.9；Newark 与 Site 1262 仍只属于独立五数据历史基线。

## 12. 复现、限制与扩展

### 12.1 复现命令

```matlab
% 确定性算法回归
report = bispectralSelfTest;
assert(report.Passed);

% package 绘图、缓存、真矢量 PDF、描述性命名与规则化链回归
packageResults = runtests('code/package/bispectral/tests');
assertSuccess(packageResults);

% 五数据验证（正式设置；Newark 与 Site 1262 目录需显式提供）
formalOut = fullfile(outputParent,'five-dataset-validation');
validation = bispectralValidateExamples(formalOut, ...
    'DataDirectory', ...
    '/path/to/newark-and-site1262', ...
    'NumSurrogates',999, ...
    'RandomSeed',20260801, ...
    'Visible','off');
assert(validation.Passed);

% bundled LR04 与 CENOGRID 800 kyr LOWESS 正式敏感性
localValidation = bispectralLocalDataValidation(outputParent, ...
    'NumSurrogates',999, ...
    'MaxFrequencyBins',1024);
assert(localValidation.Passed);

% Acycle 主列表回归
results = runtests('code/test/test_ac_main_list.m');
assertSuccess(results);
```

### 12.2 复现时必须同时报告

- 输入数据版本、坐标单位、有效点数、重复坐标与非有限行处理。
- 规则化步长、插值方法、最大间隙、年代模型及其不确定性。
- 全记录与段内去趋势、标准化、窗函数、段数、实际段长和 overlap。
- NFFT、RayleighResolution、frequency stride、仅视窗用的 FrequencyMin/Max 和主域 triad 数。
- 显著性模式、surrogate 类型与数量、置信度、随机种子和检验族。
- 同时展示 power、\|B\|、b² 和显著性；报告不显著结果。

### 12.3 当前限制

- WOSA 估计全记录平均耦合，不能严格定位间歇或时变耦合。
- 7 个 50% overlap 段的 b² 方差较高；解析 Beta 仅近似。
- 插值和固定年代模型条件化了 surrogate null，未传播年龄不确定性。
- 频率 stride 减少二维矩阵规模，也改变被检验的网格；2026-08-01 历史五数据 FT 基线中的 Newark、Site 1262 与 LR04 使用 stride=2，Synthetic 与 AR(1) 使用 stride=1；2026-08-03 bundled LR04/CENOGRID 四组 IAAFT 正式结果均使用 stride=1。
- SampleInterval 不承担降采样；粗化网格必须先用与研究带宽匹配的低通滤波器独立重采样。
- 当前只实现单变量 auto-bispectrum；不能直接推断两个代理之间的 cross-frequency coupling。
- 当前没有正式 multitaper 三 taper coupling estimator，也不应把普通 DPSS 直接叠加。

### 12.4 合理的后续扩展

- 年龄模型 ensemble：在每个 chronology realization 上重复完整预处理、估计和全图推断。
- 时变或滑窗 bicoherence，并对时间×频率二维或三维检验族进行明确校正。
- 跨变量 cross-bispectrum 与 cross-bicoherence，配合方向性假设和物理模型。
- 依据 Birkelund & Hanssen 路径实现严格三 taper 组合的 multitaper bispectrum。
- 并行 surrogate 计算、内存估算和可恢复的长任务状态。
- 敏感性分析报告自动汇总：段长、去趋势、插值、频率域与 null 模型。

### 12.5 结论

当前工具箱已经形成从 Acycle 主列表到可复现双谱结果的完整链路。核心实现覆盖有界归一化、正频无混叠和频三角域、尺度与方向恒等式，并由两条独立公式复算交叉验证；GUI 正式推断统一为 IAAFT maximum-statistic FWER。2026-08-03 的 bundled LR04/CENOGRID 正式复验已用每组 999 个 accepted surrogate 通过数值、保存、图形和制品 QA；其阈值与显著 triad 数见 10.9。旧 FT 五数据制品仅保留为历史软件回归，不能替代当前 IAAFT null 下的结论。软件输出同时保留 B、b²、biphase、显著性与元数据，适合进一步科学审查和方法敏感性分析。

## 附录 A. 输出文件与结果结构

### A.1 文件命名与保存

Run & Save 每次在 Acycle 实时地址栏目录中创建 `<输入名>-bispectral-<递增编号>` 结果文件夹；仅当实时主窗不可用时才回退到已保存的 Acycle 工作目录或 MATLAB 当前目录。若编号空间耗尽则使用毫秒时间戳。已有文件或目录绝不覆盖。结果文件夹名同时作为五个内部文件的 `<stem>`，避免 `figure.fig` 一类脱离目录后失去含义的通用名称。五类文件先在同文件系统的私有临时目录完整生成，全部成功后才将整个目录改名提交，因此失败不会留下半套结果。

表 A1  五类输出文件

| 文件 | 内容 |
|---|---|
| `<stem>.pdf` | 真矢量归档图；私有导出副本将平滑交互色面转换为离散矢量多边形，再以 `exportgraphics(ContentType='vector')` 写出；文字、坐标、等高线和填色均不含 Image XObject |
| `<stem>.fig` | 可编辑 MATLAB figure；保留交互用 pcolor、shading interp 与透明掩膜 |
| `<stem>.mat` | MAT v7.3；完整 result、矩阵、逐点 p 或阈值、metadata |
| `<stem>-preprocessed.csv` | 无表头的两列实际分析序列 |
| `<stem>-config.json` | 紧凑复现配置；移除完整趋势数组以控制体积；明确记录 maximum-statistic FWER、完整计算主域检验族及显示频率不改变检验族 |

### A.2 MAT result 主要字段

表 A2  MAT 结果结构

| 类别 | 字段 |
|---|---|
| 频率或功率 | Frequency, Power |
| Bispectrum | Bispectrum, BispectrumMagnitude, BispectrumSquaredMagnitude, BispectrumReal, BispectrumImaginary, Biphase |
| Bicoherence | BicoherenceSquared, Denominator；不保存冗余的 Bicoherence=sqrt(BicoherenceSquared) |
| 掩膜 | PrincipalDomainMask, ValidMask, InvalidDenominatorMask, SignificantMask |
| 紧凑三频组 | PairBicoherenceSquared, PairLinearIndex |
| 输入或处理 | InputData, ProcessedData, Preprocessing |
| 配置或推断 | Options, RenderSettings, Meta, Significance；本地真实数据验证另含 ExternalPreprocessing |
| 溯源 | InputName, CoordinateUnit, Created, Version, Interpretation |

### A.3 主要错误与科学警告

硬错误包括：少于 32 个有效点；不规则采样且禁止插值；无抗混叠滤波的粗化 SampleInterval；插值网格过短或超过 10⁷ 点；去趋势后常数；WOSA 少于 3 段或每段少于 32 点；overlap 超出 [0,90%)；NFFT 小于段长；平滑 span 不是大于等于 3 的奇数；频率域为空；surrogate 数不在 19-99999；pointwise surrogate 预计工作内存超过 1 GiB；置信度或 null 类型无效；输出目录、figure 或 JSON 写入失败。

科学警告写入 metadata；GUI 在分析与绘图完成后把警告数量写入状态栏，并逐条打印到 MATLAB Command Window，包括：自动规则化插值、最大 gap>5、WOSA 少于 8 段而方差较高、core API 解析 Beta 在 overlap 下仅为近似，以及频率平滑的有效样本数仅为诊断。只有 strict/auto 自动插值警告会另外打开 warning alert；其他科学警告不打开 modal dialog。若随后的 Run & Save 归档失败，这些警告仍会照常报告。

## 附录 B. 古气候应用文献与方法证据

### B.1 检索口径与结论

以 2016-2025 为“最近十年”，严格限定为论文实际对古气候或深时地质记录计算 bispectrum、imaginary bispectrum 或 bicoherence，而不是仅在引言中提及高阶谱。按这一口径核实到 8 篇近十年直接应用；因此本报告不把普通功率谱、互谱或软件论文凑成 10 篇。为满足 10 个真实案例的阅读需求，另单列 2 篇奠基性的历史古气候应用。下述“软件未披露”表示论文或可访问补充材料没有给出足以复现的程序环境，不能据此推定使用 Acycle、HOSA 或 astrochron。

> **共同解释边界。** bicoherence 或 bispectrum 支持三频组的稳定相位耦合或非线性统计依赖，但不单独证明因果、能量传输方向或具体气候机制。imaginary-bispectrum 积分论文中所称的相对“energy”是代理序列的谱交换量，不等于有物理单位的能量通量。二维图上的点态 95% 轮廓也不能自动解释为整幅图 95% FWER。

### B.2 最近十年直接应用：8 篇

#### 1. Liebrand et al. (2017), PNAS

**文献。** Liebrand, D., et al. Evolution of the early Antarctic ice ages. *Proceedings of the National Academy of Sciences*, 114, 3867-3872. https://doi.org/10.1073/pnas.1615440114

- **数据：** ODP Site 1264 benthic δ18O，约 30.1-17.1 Ma，2.5 kyr 等间距。
- **方法与软件：** moving imaginary bispectrum；2 Myr 窗、0.1 Myr 步长；每窗 8 blocks、block 长 1 Myr，报告 16 DOF 和 0.001 cycle/kyr 网格。实现软件或代码未披露。
- **结果：** middle Oligocene glacial interval 与 Oligocene-Miocene transition 均见偏心率频带间耦合；后者的耦合结构更复杂，早中新世约 110 kyr 波动呈更强锯齿不对称。
- **谨慎解读：** 文中的能量再分配是记录的相对谱量，不能当作冰盖系统的绝对物理能量通量；滑窗内低频周期数有限。

#### 2. Da Silva et al. (2019; online 2018), Geology

**文献。** Da Silva, A.-C., et al. Millennial-scale climate changes manifest Milankovitch combination tones and Hallstatt solar cycles in the Devonian greenhouse world. *Geology*, 47, 19-22. https://doi.org/10.1130/G45511.1

- **数据：** 比利时 Frasnian 层序；两个约 3 m、1 cm 间距的 pXRF log(Ti) 段用于高分辨率谱分析，而 Figure 2 bicoherence 的输入是完整约 5.7 Myr、轨道调谐的 magnetic-susceptibility 序列。二者不能混写。
- **方法与软件：** R/astrochron 的 MTM、F-test 与滤波，Morlet continuous wavelet；MATLAB HOSA toolbox 计算 bicoherence。分段数、overlap、taper 和显著性参数未完整披露。
- **结果：** 6-8 kyr 与 10-12 kyr 峰被解释为 Milankovitch combination tones；约 2.5 kyr 成分与 Hallstatt 周期相近。
- **谨慎解读：** 组合频率解释受到调谐年代模型和未披露 bicoherence 参数的限制；约 2.5 kyr 的太阳归因是周期对应关系，不是 bispectrum 单独证明的机制。

#### 3. Liebrand and de Bakker (2019), Climate of the Past

**文献。** Liebrand, D., & de Bakker, A. T. M. Bispectra of climate cycles show how ice ages are fuelled. *Climate of the Past*, 15, 1959-1983. https://doi.org/10.5194/cp-15-1959-2019

- **数据：** LR04 global benthic δ18O stack，0-5333 ka；经 SiZer 规则化到 1 kyr。
- **方法与软件：** notch detrending、Hann taper、imaginary bispectrum、全域与 15 个频率分区积分；主滑窗 668 kyr、步长 50 kyr；自定义 MATLAB。
- **结果：** 作者提出 precession、obliquity 与 eccentricity 频带之间的相对谱级联，并描述 Mid-Pleistocene Transition 前后 40 kyr 分量角色的改变。
- **谨慎解读：** 作者明确指出序列非遍历且低频周期数少，不能给出正式 bispectral confidence levels；“energy”是归一化后的记录统计量。本报告的 LR04 固定窗 WOSA 验证不是该滑窗 imaginary-bispectrum 工作流的复现。

#### 4. Sullivan et al. (2023), PNAS

**文献。** Sullivan, N. B., et al. Millennial-scale variability of the Antarctic ice sheet during the early Miocene. *Proceedings of the National Academy of Sciences*, 120, e2304152120. https://doi.org/10.1073/pnas.2304152120

- **数据：** ANDRILL AND-2A 约 800-900 m 深度段的 >2 mm clast counts，10 cm bins；TimeOpt 年代模型给出约 484 kyr 时长、约 0.5 kyr 分辨率。
- **方法与软件：** R/astrochron `bicoherence`；Kim-Powers WOSA，7 segments、50% overlap、Hann 窗、linear detrend；主图 zero-padding factor 10，全频补图 factor 5。
- **结果：** 约 4.5、3.7 与 3.0 kyr 成分的一部分被解释为轨道频率组合；8.6 kyr 分量来源不确定。
- **谨慎解读：** 一维谱使用 FDR，但二维 bicoherence 轮廓是点态 95% 阈值，并未控制整图 FWER；TimeOpt 带有轨道先验，zero padding 不增加真实分辨率。

#### 5. Liebrand et al. (2023), Climate of the Past

**文献。** Liebrand, D., et al. Disparate energy sources for slow and fast Dansgaard-Oeschger cycles. *Climate of the Past*, 19, 1447-1459. https://doi.org/10.5194/cp-19-1447-2023

- **数据：** NGRIP δ18Oice，约 123 kyr 长，20 yr 等间距。
- **方法与软件：** linear detrend、Hamming taper及能量校正、imaginary bispectrum、总积分和 9 个频率分区；自定义 MATLAB，代码声明为可向作者索取。
- **结果：** slow DO variability（12.5-2.5 kyr）主要与轨道频带交换相对谱量，fast DO variability（1.5 ± 0.5 kyr）主要与百年及更快频带交换。
- **谨慎解读：** 记录只含约一个 110 kyr 周期，最低频结果不稳定；论文中的“energy source”仍不是具有物理单位的能量源诊断。

#### 6. Gao et al. (2025), Science Bulletin

**文献。** Gao, P., et al. Obliquity and precession forcing of the amplitude of millennial-scale East Asian monsoon variability during the late Miocene. *Science Bulletin*, 70, 1338-1346. https://doi.org/10.1016/j.scib.2025.01.042

- **数据：** Jiarang late Miocene 记录，8.6-7.104 Ma；χlf、χfd、χARM 与 SIRM，约 1 kyr 分辨率。
- **方法与软件：** 去趋势 WOSA bicoherence（补图 S13）及 MTM、wavelet、Hilbert 包络调制、circular-Rayleigh 检验。bicoherence 的 segments、overlap、taper、null 和软件未披露。
- **结果：** 多代理结果被作者解释为：千年尺度东亚季风变率的幅度主要与地轴倾角及约 173 kyr 的倾角调制相关，岁差信号较弱。
- **谨慎解读：** 因关键 bicoherence 参数未披露，不能把该结果称为 Acycle 计算，也不能仅凭轮廓强度比较不同代理的物理耦合强弱。

#### 7. Wang et al. (2025), Climate Dynamics

**文献。** Wang, Z., et al. Late Pliocene lacustrine deposits expose the nonlinear response of the East Asian summer monsoon to insolation forcing. *Climate Dynamics*, 63, Article 254. https://doi.org/10.1007/s00382-025-07754-0

- **数据：** Huangdigou 约 500 个 2 cm 间距 magnetic susceptibility 样点，3.03-2.59 Ma、约 800 yr 分辨率，并与约 4 cm 间距 Rb/Sr 比较；年代模型结合 GPTS2020 与 TimeOpt。
- **方法与软件：** AnalySeries 2.0.8 与 R/astrochron；晚段 7 segments、早段 9 segments，均为 50% overlap、linear detrend 的 WOSA bicoherence。主图未明确窗函数；补充的整段 5-segment 分析写明 Hann 窗。
- **结果：** 报告多组三频组合，例如 1/9.6 ≈ 1/12.1 + 1/45、1/5.8 ≈ 2/11.6、1/3.1 ≈ 1/4.6 + 1/9.6 和 1/2.1 ≈ 1/12.1 + 1/2.5 kyr⁻¹。
- **谨慎解读：** 二维图采用点态 95% 阈值；主图窗函数披露不完整。组合式的一致性支持非线性响应假说，但不唯一确定湖泊-季风机制。

#### 8. Zhang et al. (2025), Nature Communications

**文献。** Zhang, Z., et al. Precession-induced millennial climate cycles in greenhouse Cretaceous. *Nature Communications*, 16, 10696. https://doi.org/10.1038/s41467-025-66219-4

- **数据：** SK2 core grayscale、log(Ca/Ti) 与 Rb/Sr，以及 DSDP 516F L*；early Campanian 年代模型。
- **方法与软件：** R/astrochron 用于 bicoherence、TimeOpt、periodogram 与 FDR；Acycle 仅用于 MTM、滤波和 Hilbert；ImageJ 提取灰度。SK2 为 4 segments、50% overlap、Hann、detrend、pad factor 8。
- **结果：** 支持 (1/5.8, 1/22)→1/4.5、(1/9.2, 1/18.2)→1/6.1 kyr⁻¹ 等高阶组合，4-5 kyr 成分解释为四分之一岁差或赤道日照响应。
- **谨慎解读：** DSDP 516F 的 segment 数在补充 R 代码（20）与 Figure 3 caption 的笼统表述（4）之间存在复现冲突；二维 bicoherence 仍是点态 95% 阈值，不能称为二维 FDR/FWER。

### B.3 历史经典应用：2 篇

#### 9. Hagelberg, Pisias and Elgar (1991), Paleoceanography

**文献。** Hagelberg, T. K., Pisias, N. G., & Elgar, S. Linear and nonlinear couplings between orbital forcing and the marine δ18O record during the Late Neocene. *Paleoceanography*, 6, 729-746. https://doi.org/10.1029/91PA02281

- **数据与方法：** ODP 677、DSDP 607 marine δ18O 与 orbital/insolation，约 2.6-0 Ma；使用 bispectral phase coupling，并结合 skewness 与 asymmetry。可核实页面未充分披露现代意义下的分段、窗和软件参数。
- **结果与解读：** 约 1-0 Ma 的同位素记录相位耦合更接近辐射强迫中的耦合，作者认为这与线性传递或线性共振响应相容；2.6-1 Ma 的记录耦合与日照强迫不同，且记录随更新世演化更趋 sawtooth。该文奠定了轨道频带相位耦合的古气候用法，但未提供今天常用的 surrogate 全图推断。

#### 10. Wara, Ravelo and Revenaugh (2000), Paleoceanography

**文献。** Wara, M. W., Ravelo, A. C., & Revenaugh, J. The pacemaker always rings twice. *Paleoceanography*, 15, 616-624. https://doi.org/10.1029/2000PA000500

- **数据与方法：** DSDP 607/609 North Atlantic 高分辨率沉积代理，约 225-970 ka；与 ODP 663 尘埃与 CaCO3 记录及赤道日照比较，使用 bispectral 与 cross-bispectral 分析。可核实页面未充分披露软件和全部估计参数。
- **结果与解读：** 作者认为多数 7-19 kyr 方差可由 23 kyr 与 40 kyr 尺度变化的 harmonics 或 combination tones 解释，而非简单的低纬 forcing 直接输入。这一结论依赖频率组合与相位关系，不能由单个功率峰得到。

### B.4 算法与软件基础文献（不计入上述 10 篇应用）

1. Welch, P. D. (1967). 基于短时修正周期图平均的 FFT 功率谱估计；原文题名以 The use of fast Fourier transform for the estimation of power spectra 开头。https://doi.org/10.1109/TAU.1967.1161901
2. Kim, Y. C., & Powers, E. J. (1979). Digital bispectral analysis and its applications to nonlinear wave interactions. https://doi.org/10.1109/TPS.1979.4317207
3. Theiler, J., et al. (1992). Testing for nonlinearity in time series: The method of surrogate data. https://doi.org/10.1016/0167-2789(92)90102-S
4. Schreiber, T., & Schmitz, A. (1996). Improved surrogate data for nonlinearity tests. https://doi.org/10.1103/PhysRevLett.77.635
5. Birkelund, Y., & Hanssen, A. (1999). Multitaper estimators for bispectra. https://doi.org/10.1109/HOST.1999.778727
6. Choudhury, A. A. S., Shah, S. L., & Thornhill, N. F. (2008). Bispectrum and bicoherence. In *Diagnosis of Process Nonlinearities and Valve Stiction*, pp. 29-41. https://doi.org/10.1007/978-3-540-79224-6
7. Li, M., Hinnov, L., & Kump, L. (2019). Acycle: Time-series analysis software for paleoclimate research and education. *Computers & Geosciences*, 127, 12-22. https://doi.org/10.1016/j.cageo.2019.02.011

## 附录 C. 路径与版本信息

表 C1  可复现环境摘要

| 项目 | 路径或状态 |
|---|---|
| 仓库 | 用户本机 Acycle 仓库根目录（文档与测试使用相对路径） |
| 分支 | bispectral |
| 基线 commit | 8eea94423759；报告生成时功能尚未 commit |
| 工具箱 | code/package/bispectral |
| 正式验证 | `/Users/mingsongli/Library/CloudStorage/Dropbox/Acycle/NeedToDo/bispectral/LR04_CENOGRID_validation_20260803_025644_609`；源代码不硬编码该个人路径 |
| MATLAB | R2025b |
| 报告日期 | 2026-08-03（Asia/Shanghai） |

> **版本声明。** 本报告记录 bispectral 分支当前工作树中的实现；保存格式、GUI 状态或验证流程改变后必须重新运行相应回归与真实数据验证，再更新结果数字和制品路径。后续若修改算法、默认参数、主域、surrogate 生成或结果文件格式，应同时更新版本号、回归基线和本报告。
