library(ggplot2)
library(ggforce)
library(dplyr)

set.seed(as.numeric(Sys.time()))

club_stats <- tribble(
  ~club,            ~mean, ~sd,  ~min, ~max,
  "Driver",          11,   1.2,   8,   14,
  "3 Wood",          10.5, 1.1,   8,   14,
  "Hybrid",           9.5, 1.0,   6,   12.5,
  "4 Iron",           9.0, 0.9,   8,   12.5,
  "6 Iron",           7.5, 0.8,   4.9, 11,
  "8 Iron",           6.5, 0.7,   4.8, 10,
  "PW",               3.5, 0.8,   0.5, 6
)

# === TARGETS ===
targets <- tribble(
  ~x, ~y, ~size, ~color,   ~name,     ~points,
   1, 1, 0.5, "red",    "red1",    1,
   3, 1, 0.5, "red",    "red2",    1,
   5, 1, 0.5, "red",    "red3",    1,
   2, 3, 0.75, "yellow","yellow1", 3,
   4, 3, 0.75, "yellow","yellow2", 3,
   3, 5.25, 1, "green", "green",   5,
   4, 7.5, 1, "brown",  "brown",   7,
   2, 9.25, 1, "blue",  "blue",    10,
   4, 11.5, 1, "white", "white",   12
)

colors <- c(
  red    = "#F00016",
  yellow = "#FFBB00",
  green  = "#27B028",
  brown  = "#BF5107",
  blue   = "#006EB4",
  white  = "#BDC1C0",
  trench = "#141615"
)

score_target <- function(x, y, targets) {
  # Check trench first
  if (x >= 1.2 && x <= 4.8 && y >= 13.5 && y <= 14) {
    return(5)
  }
  # Check circular targets
  for (i in seq_len(nrow(targets))) {
    dist <- sqrt((x - targets$x[i])^2 + (y - targets$y[i])^2)
    if (dist <= targets$size[i]) {
      return(targets$points[i])
    }
  }
  return(0)
}

simulate_hits <- function(club = NULL, n = 20, skill = 1) {
  if (is.null(club)) club <- sample(club_stats$club, 1)
  stats <- filter(club_stats, club == !!club)
  
  # player bias and wind
  player_bias <- runif(1, -0.5, 0.5)
  wind_x <- runif(1, -0.2, 0.2)
  wind_y <- runif(1, -0.2, 0.2)
  
  y <- rnorm(n, stats$mean, stats$sd * skill)
  y <- pmin(pmax(y, stats$min), stats$max)
  
  x <- rnorm(n, mean = 3 + player_bias, sd = (0.3 + 0.05 * y) * skill)
  x <- x + wind_x
  y <- y + wind_y
  
  df <- data.frame(x, y, club)
  attr(df, "player_bias") <- player_bias
  attr(df, "wind") <- c(wind_x, wind_y)
  return(df)
}

df <- simulate_hits(club = NULL, n = 20, skill = 1.2)
df$points <- mapply(score_target, df$x, df$y, MoreArgs = list(targets))

# Stats
hits <- sum(df$points > 0)
misses <- sum(df$points == 0)
total_points <- sum(df$points)
club_used <- unique(df$club)
player_bias <- attr(df, "player_bias")
wind <- attr(df, "wind")
hit_pct <- hits / nrow(df) * 100
avg_points <- mean(df$points)

played_label <- format(Sys.time(), "%Y-%m-%d %H:%M")

# Build subtitle with conditions
bias_val <- player_bias
bias_dir <- ifelse(bias_val < 0, "L", "R")
bias_text <- paste0(abs(round(bias_val, 2)), bias_dir)

conditions_text <- sprintf(
  "Played: %s\nBias: %s\nWind: %.2f X, %.2f Y",
  played_label, bias_text, wind[1], wind[2]
)

final_plot <- ggplot() +
  geom_circle(
    data = targets,
    aes(x0 = x, y0 = y, r = size, fill = color),
    color = NA, alpha = 0.5
  ) +
  scale_fill_manual(values = colors) +
  geom_rect(
    aes(xmin = 1.2, xmax = 4.8, ymin = 13.5, ymax = 14),
    fill = colors["trench"], alpha = 0.5
  ) +
  geom_point(
    data = df,
    aes(x, y, shape = points > 0),
    color = "black", size = 3
  ) +
  scale_shape_manual(values = c(`TRUE` = 16, `FALSE` = 4)) +
  coord_equal() +
  theme_void() +
  theme(
    panel.background = element_rect(fill = "white", color = NA),
    plot.background  = element_rect(fill = "white", color = NA)
  ) +
  labs(
    title = sprintf("Club: %s | Points: %d",
                    club_used, total_points),
    subtitle = conditions_text
  ) +
  theme(legend.position = "none")

ggsave("topgolf-sim.png", plot = final_plot, width = 8, height = 10, bg = "white")

# unlink("Rplots.pdf")

cat("=== Round Stats ===\n")
cat("Club: ", club_used, "\n")
cat("Hits: ", hits, "\n")
cat("Misses: ", misses, "\n")
cat("Total Points: ", total_points, "\n")
cat("Hit Percentage: ", round(hit_pct, 1), "%\n", sep = "")
cat("Average Points per Shot: ", round(avg_points, 1), "\n")
cat("Player Bias: ", round(player_bias, 2), "\n")
cat("Wind (x,y): ", paste(round(wind, 2), collapse = ", "), "\n")
