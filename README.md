# golfr

Daily Topgolf Simulation in R ⛳️📊 [![daily-game](https://github.com/bradfordjohnson/golfr/actions/workflows/daily-game.yml/badge.svg)](https://github.com/bradfordjohnson/golfr/actions/workflows/daily-game.yml)

Welcome to **golfr**, an R-powered project that simulates a daily Topgolf round with realistic shot physics, player tendencies, and environmental effects — all visualized beautifully.

## See the Latest Game

*Timestamp and conditions appear on the plot subtitle.*

<img src="topgolf-sim.png" width="65%">

## What golfr Does

- Runs a daily simulation of 20 shots using R, modeling various clubs and player skill.
- Simulates realistic shot distributions around specific targets, incorporating **player bias** (left/right tendencies) and **wind effects**.
- Scores shots against multiple colored targets and a bonus trench zone.
- Produces a clean plot showing shots as hits (dots) or misses (crosses), with detailed round stats.

## How It Works

- **Automated via GitHub Actions:**  
  The workflow triggers daily at 5:00 AM UTC, running the R script `simulate_game.R` and updating the plot.

- **Shot Simulation Details:**  
  - Clubs modeled with distance means and variability  
  - Shots aimed at multiple targets with randomness based on skill, bias, and wind  
  - Player bias and wind offset shots horizontally and vertically  
  - Skill factor adjusts shot spread (consistency)

- **Features & Modeling Details:**  
  - **Target-Based Shot Aiming:** Shots are simulated as attempts aimed around specific Topgolf-style targets with defined location, size, and point values.  
  - **Club-Specific Distance Profiles:** Each club has distinct distance and variability parameters reflecting realistic shot ranges and target zones suited for that club’s typical distances.
  - **Player Bias Simulation:** Left/right shot tendencies simulate player quirks and consistent directional offsets.  
  - **Environmental Wind Effects:** Horizontal and vertical offsets model wind influence on shots.  
  - **Dynamic Scoring System:** Shots are scored based on landing inside circular targets or a rectangular trench, with higher points for farther zones.  
  - **Extensible Design:** Easily add or customize clubs, targets, and environmental effects for more complex simulations.

- **Outputs:**  
  - A plot (`topgolf-sim.png`) visualizing targets, shot distribution, and round stats  
  - Console output with detailed round metrics (hits, misses, points, bias, wind)

## Running golfr Locally

1. Install R packages:

   ```r
   install.packages(c("dplyr", "ggplot2", "ggforce"))
   ```

2. Run the simulation script:

   ```bash
   Rscript src/simulate_game.R
   ```

3. View the updated plot:

   [topgolf-sim.png](topgolf-sim.png)
