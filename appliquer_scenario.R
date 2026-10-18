# =============================================================================
# MANMADE - Application du modele G2 a un nouvel evenement
# R de base uniquement (aucun package requis)
#
# Usage : Rscript appliquer_scenario.R [interpellations] [fdo_min] [fdo_max]
#   ex. : Rscript appliquer_scenario.R 1200 25000 45000
# Sans argument, le script rejoue l'exemple du 17 octobre 2026.
#
# Le modele G2 (quasi-Poisson, lien log) est recale sur 2005 a chaque execution :
#   vehicules ~ log(interpellations) + log(effectifs mobilises)
# Intervalle de prevision a 95 % : incertitude des coefficients (methode delta
# sur le predicteur lineaire) + bruit quasi-Poisson (variance = phi * mu).
# Approximation normale : ordre de grandeur, pas un intervalle exact.
# =============================================================================

args <- commandArgs(trailingOnly = TRUE)
I    <- if (length(args) >= 1) as.numeric(args[1]) else 1200
fmin <- if (length(args) >= 2) as.numeric(args[2]) else 25000
fmax <- if (length(args) >= 3) as.numeric(args[3]) else 45000

d   <- read.csv("data/emeutes_journalier.csv", na.strings = "NA")
e05 <- d[d$evenement == 2005 & !is.na(d$interpellations), ]

g2 <- glm(vehicules_incendies ~ log(interpellations) + log(fdo_mobilises),
          family = quasipoisson(link = "log"), data = e05)
phi <- summary(g2)$dispersion

prevoir <- function(I, F) {
  nd <- data.frame(interpellations = I, fdo_mobilises = F)
  p  <- predict(g2, newdata = nd, type = "link", se.fit = TRUE)
  mu <- exp(p$fit)
  var_tot <- (mu * p$se.fit)^2 + phi * mu   # coefficients + bruit
  data.frame(interpellations = I, fdo_mobilises = F,
             vehicules_central = round(mu),
             ip95_bas  = round(max(0, mu - 1.96 * sqrt(var_tot))),
             ip95_haut = round(mu + 1.96 * sqrt(var_tot)))
}

grille <- unique(round(c(fmin, (fmin + fmax) / 2, fmax)))
res <- do.call(rbind, lapply(grille, function(F) prevoir(I, F)))

cat("Modele G2 cale sur 2005 (n =", nrow(e05), "nuits)\n")
print(round(coef(g2), 4)); cat("dispersion =", round(phi, 1), "\n\n")
print(res, row.names = FALSE)
cat("\nEnveloppe :", min(res$ip95_bas), "a", max(res$ip95_haut),
    "vehicules ; central (effectif median) :", res$vehicules_central[2], "\n")

dir.create("sorties", showWarnings = FALSE)
write.csv(res, "sorties/scenario.csv", row.names = FALSE)
