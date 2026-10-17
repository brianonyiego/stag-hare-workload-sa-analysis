# Human Supervision of MARL Teams 🦌

R analysis code for an experiment on how human supervisors select pre-trained multi-agent reinforcement-learning (MARL) teams in environments with varying risk of "stag illness". It compares workload (NASA-TLX), situation awareness (SART) and task performance across three conditions.

## Background 🎯
Thirty human supervisors each chose one of three pre-trained AI teams in environments that differed in the likelihood that stags were sick (0%, 30%, 90%).

| Team | Strategy |
| --- | --- |
| **Stag** | Reward-seeking, pursues high-reward stags |
| **Hare** | Risk-averse, avoids stags |
| **DisAdv** | Adaptive, one agent detects and shares stag-illness information |

| Code | Condition | Description |
| --- | --- | --- |
| **E** | `Extreme_Hare` | Environment where the Hare strategy is favoured |
| **O** | `Ambiguous` | Intermediate (30%) stag-illness likelihood |
| **R** | `Extreme_Stag` | Environment where the Stag strategy is favoured |

## Hypotheses 🧪
- **H1:** Choice accuracy and performance are better in extreme environments than in the ambiguous one.
- **H2:** The adaptive DisAdv team is chosen more often in the ambiguous environment.
- **H3:** Selection latency is longer in the ambiguous environment.
- **H4:** Higher situation awareness is associated with higher choice accuracy and shorter response times.
- **H5:** Workload is higher in the ambiguous environment and is negatively related to choice accuracy.

## Features ✨
- Descriptive statistics by condition (mean, SD, SE, min, max)
- Five publication-style plots (boxplots, violin plot, subscale bar chart, correlation heat map)
- One-way ANOVAs with Levene and Shapiro-Wilk assumption checks and Tukey HSD post-hocs
- Bayesian ANOVA for workload using the `BayesFactor` package
- Separate ANOVAs for the six NASA-TLX subscales
- Pearson correlation matrix with p-values and an attempted polychoric correlation of SA items
- Cronbach's alpha reliability analysis and pairwise Cohen's d
- Summary table of Mental Demand, Effort and Physical Demand by condition

## Prerequisites 🛠️
Before running this project, ensure you have the following installed:
- R (version 4.2 or higher)
- RStudio (optional, but recommended)
- The following R packages:

```r
install.packages(c(
  "tidyverse", "janitor", "skimr", "lme4", "lmerTest",
  "BayesFactor", "psych", "polycor", "reshape2", "readxl",
  "car", "effectsize", "knitr"
))
```

> `car` is called with `car::leveneTest()` and `effectsize` is loaded conditionally, so both must be installed even though they are not in the library block.

## Installation 📦
Get your environment running by following these steps:

```bash
# Clone the repository
git clone https://github.com/<your-username>/stag-hare-workload-sa-analysis.git

# Navigate into the directory
cd stag-hare-workload-sa-analysis

# Create a folder for the data
mkdir data
```

Then copy your `Expt2_final.xlsx` workbook into the `data/` folder.

## Project Structure 📁
```
stag-hare-workload-sa-analysis/
├── README.md
├── analysis.R              # main analysis script (rename to match your file)
├── data/
│   └── Expt2_final.xlsx    # not tracked, add locally
├── figures/                # optional: saved plots
└── .gitignore              # should exclude data/*.xlsx
```

## Data 📊
The script reads one Excel workbook with four sheets:

| Sheet | Contents |
| --- | --- |
| `Workload` | NASA-TLX subscales and total (`total_score_sum_6`) per participant and condition |
| `SA` | SART items and `sa_total` per participant (`demand_condition`) |
| `FullData` | Score, choice accuracy, response time, clicks, NASA-TLX and SART per participant |
| `FullData2` | Condition-level data imported as character and coerced to numeric by the script |

**Measures:** performance score, choice accuracy, response time (`time_respond_env`), team-selection clicks, NASA-TLX (six subscales plus total) and SART total.

> **Data availability:** The raw workbook contains participant-level data and is **not included** in this repository.

## Usage 💡
Run the script from the project root:

```r
source("analysis.R")
```

Console output is organised under labelled headings such as `=== DESCRIPTIVE STATISTICS ===` and `=== STATISTICAL ANALYSES ===`. Five plots are drawn to the active graphics device.

| Section | What it does |
| --- | --- |
| **Load data** | Reads the four sheets, cleans column names with `janitor::clean_names()`, coerces `FullData2` columns to numeric |
| **Descriptives** | Summary statistics by condition for workload, SART and performance |
| **Visualisations** | Workload boxplot, NASA-TLX subscale bars, SART boxplot, performance violin plot, correlation heat map |
| **Inferential tests** | One-way ANOVA, assumption checks, Tukey HSD, eta-squared, Bayesian ANOVA |
| **Subscale analyses** | One-way ANOVA for each of the six NASA-TLX subscales |
| **Correlations** | Pearson matrix with p-values, attempted polychoric correlations of SA items |
| **Reliability and effect sizes** | Cronbach's alpha for NASA-TLX, pairwise Cohen's d |
| **Summary table** | Mean (SD) for Mental Demand, Effort and Physical Demand (E / O / R) |

## Configuration ⚙️
The original script uses a hard-coded Windows path. Update `file_path` near the top of the script before running:

```r
# Original
file_path <- "C:/Users/brian/Downloads/Copy of Expt2_final.xlsx"

# Replace with a relative path
file_path <- "data/Expt2_final.xlsx"
# or: file_path <- here::here("data", "Expt2_final.xlsx")
```

To save figures, add `ggsave()` after each plot, for example:

```r
ggsave("figures/performance_by_condition.png", p4, width = 7, height = 5, dpi = 300)
```

## Results 📈
Sample: N = 30 (n = 10 per condition), so all one-way ANOVAs have df = (2, 27). Significance threshold is α = .05.

### Descriptive statistics, Mean (SD)

| Variable | Extreme_Hare (E) | Ambiguous (O) | Extreme_Stag (R) |
| --- | --- | --- | --- |
| NASA-TLX total | 46.2 (15.1) | 38.1 (14.8) | 34.2 (11.0) |
| SART total | 10.2 (4.24) | 15.1 (2.88) | 14.6 (3.92) |
| Performance score | 691.2 (88.8) | 752.0 (95.7) | 795.6 (36.0) |
| Effort (NASA-TLX) | 59 | 52 | 34 |

### Inferential tests

| Outcome | Omnibus test | Key post-hoc (Tukey HSD) | Assumptions |
| --- | --- | --- | --- |
| **Performance** | F(2,27) = 4.49, **p = .021** | R > E: diff = 104.4, 95% CI [17.69, 191.11], **p = .016**; O vs E (p = .215) and R vs O (p = .429) n.s. | Levene p = .269, Shapiro-Wilk p = .091 |
| **Situation awareness (SART)** | F(2,27) = 5.24, **p = .012** | O > E: diff = 4.9, **p = .018**; R > E: diff = 4.4, **p = .035**; R vs O: p = .952 | Levene p = .569, Shapiro-Wilk p = .427 |
| **Workload (NASA-TLX total)** | F(2,27) = 1.98, p = .158 (n.s.) | No significant pairs (O-E p = .400, R-E p = .145) | Levene p = .774, Shapiro-Wilk p = .388 |
| **Workload, Bayesian ANOVA** | BF = 0.733 | Weak evidence for the null | n/a |
| **Effort subscale** | F(2,27) = 4.45, **p = .021** | Lowest in R | n/a |
| **Physical demand subscale** | F(2,27) = 3.24, p = .055 | Trend only | n/a |

Mental demand, temporal demand, performance and frustration did not differ significantly across conditions.

### Correlations (Pearson)

| Pair | r | p |
| --- | --- | --- |
| Choice accuracy and performance score | .640 | .001 |
| Response time and choice accuracy | -.446 | .014 |
| NASA-TLX total and SART total | -.375 | .041 |
| NASA-TLX and performance | -.120 | n.s. |
| SART and performance | .014 | n.s. |
| NASA-TLX and choice accuracy | -.263 | n.s. |
| SART and choice accuracy | .060 | n.s. |
| Response time and score | -.156 | n.s. |

### Reliability
Cronbach's alpha for the six NASA-TLX subscales = **.78** (95% CI [.64, .88]).

### Key takeaways 🔑
- Supervisors performed best in the clear Stag-favouring environment, with higher and less variable scores than in the Hare-favouring environment.
- Situation awareness was lowest in the Hare-favouring environment and higher in the ambiguous and Stag-favouring environments.
- Overall workload did not differ reliably between conditions, although the effort subscale did.
- Accurate choices went with higher rewards and faster responses, and higher workload went with lower situation awareness.
- Ambiguity raised reported situation awareness, but supervisors did not clearly prefer the adaptive DisAdv team. Transparency and training may help supervisors see its value.

## Known Limitations ⚠️
- **Small sample:** N = 30 limits power to detect small effects.
- **Between-subjects analysis:** The ANOVAs treat conditions as independent groups. If each participant saw all conditions, use a repeated-measures or mixed-effects model (`lme4` and `lmerTest` are loaded but unused).
- **Polychoric correlations:** `polycor::hetcor` returns Pearson correlations for numeric columns. Convert items to ordered factors or use `psych::polychoric()`.
- **Cronbach's alpha:** NASA-TLX subscales are not strictly unidimensional, and the Performance subscale is scored in the opposite direction.
- **Multiple comparisons:** The six subscale ANOVAs use unadjusted p-values and should be treated as exploratory.
- **Cohen's d:** The routine uses an unweighted pooled SD, and group order depends on row order. Check signs before reporting.

## Contributing 🤝
Contributions are welcome! Please open an issue or submit a pull request for any changes.

## License 📄
This project is licensed under the MIT License - see the `LICENSE` file for details. The data are not covered by this license and are not distributed here.
