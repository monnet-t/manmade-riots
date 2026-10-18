# =============================================================================
# MANMADE - Emeutes et violences urbaines : modelisation simple des pertes
# Calage sur 2005, controle hors echantillon sur 2023
# R de base uniquement (aucun package requis)
#
# Usage : Rscript modele_emeutes.R        (depuis le dossier du projet)
# Entrees : data/emeutes_journalier.csv, data/mouvement_2026.csv
# Sorties : sorties/*.csv, sorties/*.png, impression console
#
# Convention de date : une ligne = bilan AU MATIN du jour (nuit precedente).
# =============================================================================

options(stringsAsFactors = FALSE, scipen = 999)
dir.create("sorties", showWarnings = FALSE)

d <- read.csv("data/emeutes_journalier.csv", na.strings = "NA")
d$date_bilan <- as.Date(d$date_bilan)
d <- d[order(d$evenement, d$date_bilan), ]

# Variable retardee, calculee par evenement (pas de fuite 2005 -> 2023)
d$veh_lag1 <- ave(d$vehicules_incendies, d$evenement,
                  FUN = function(x) c(NA, head(x, -1)))

e05 <- d[d$evenement == 2005, ]
e23 <- d[d$evenement == 2023, ]

# References 2023 retenues (decision du 2026-10-06) :
#  - tableau journalier Wikipedia (communiques du ministere) : 5 954, sert de PROFIL
#  - borne basse : France Assureurs, 46 % de 16 400 sinistres au 29/11/2023
#    (chiffres repris par le rapport du Senat n 521) = 7 544 sinistres vehicules
#  - borne haute : 12 031, declaration ministerielle provisoire du 05/07/2023,
#    reprise par le rapport du Senat n 521 mais NON etayee ni definie par ce rapport
# Les colonnes vehicules_borne_basse / _haute redressent le profil journalier
# par un facteur uniforme (hypothese : sous-comptage identique chaque nuit).
VEH_2023_TAB  <- sum(e23$vehicules_incendies)
VEH_2023_BAS  <- sum(e23$vehicules_borne_basse)
VEH_2023_HAUT <- sum(e23$vehicules_borne_haute)

# ----------------------------------------------------------------------------
# Outils
# ----------------------------------------------------------------------------
scores <- function(obs, pred, etiquette) {
  ok <- !is.na(obs) & !is.na(pred)
  o <- obs[ok]; p <- pred[ok]
  data.frame(
    modele      = etiquette,
    n           = length(o),
    rmse        = round(sqrt(mean((p - o)^2))),
    mae         = round(mean(abs(p - o))),
    biais_moyen = round(mean(p - o)),
    total_obs   = sum(o),
    total_pred  = round(sum(p)),
    ratio_total = round(sum(p) / sum(o), 2)
  )
}

resume_lm <- function(m, titre) {
  cat("\n---", titre, "---\n")
  print(round(coef(summary(m)), 4))
  s <- summary(m)
  cat(sprintf("n = %d | R2 = %.3f | R2 ajuste = %.3f | sigma = %.1f\n",
              length(residuals(m)), s$r.squared, s$adj.r.squared, s$sigma))
}

# =============================================================================
# 2.1  Vehicules = f(Interpellations), calage 2005, controle 2023
# =============================================================================
cat("\n================ 2.1  V = f(I) ================\n")
m1  <- lm(vehicules_incendies ~ interpellations, data = e05)
m1o <- lm(vehicules_incendies ~ 0 + interpellations, data = e05)   # sans constante
m1l <- lm(log(vehicules_incendies) ~ log(interpellations), data = e05)  # elasticite
resume_lm(m1,  "M1  lineaire, 2005")
resume_lm(m1o, "M1o lineaire sans constante, 2005")
resume_lm(m1l, "M1l log-log, 2005")

# Correction de retransformation (smearing de Duan) pour le log-log
smear <- mean(exp(residuals(m1l)))
p1_23  <- predict(m1,  newdata = e23)
p1o_23 <- predict(m1o, newdata = e23)
p1l_23 <- exp(predict(m1l, newdata = e23)) * smear

# Meme relation estimee directement sur 2023 : la pente a-t-elle change ?
m1_23 <- lm(vehicules_incendies ~ 0 + interpellations, data = e23)
cat(sprintf("\nVehicules par interpellation (pente sans constante) : 2005 = %.2f | 2023 = %.2f\n",
            coef(m1o), coef(m1_23)))
cat(sprintf("Ratio brut des totaux : 2005 = %.2f | 2023 tableau = %.2f | borne basse = %.2f | borne haute = %.2f\n",
            sum(e05$vehicules_incendies) / sum(e05$interpellations, na.rm = TRUE),
            VEH_2023_TAB / sum(e23$interpellations),
            VEH_2023_BAS / sum(e23$interpellations),
            VEH_2023_HAUT / sum(e23$interpellations)))

# =============================================================================
# 2.2  Vehicules = f(Interpellations, Forces de l'ordre mobilisees)
#      ATTENTION : la serie FDO 2005 est reconstituee a dire d'expert
#      (voir colonne fdo_qualite et METADATA.md)
# =============================================================================
cat("\n================ 2.2  V = f(I, FDO) ================\n")
m2 <- lm(vehicules_incendies ~ interpellations + fdo_mobilises, data = e05)
resume_lm(m2, "M2  lineaire, 2005")
cat(sprintf("Correlation I / FDO en 2005 : %.2f\n",
            cor(e05$interpellations, e05$fdo_mobilises, use = "complete.obs")))
cat(sprintf("Plage FDO 2005 : %d a %d | plage FDO 2023 : %d a %d  -> extrapolation\n",
            min(e05$fdo_mobilises, na.rm = TRUE), max(e05$fdo_mobilises, na.rm = TRUE),
            min(e23$fdo_mobilises, na.rm = TRUE), max(e23$fdo_mobilises, na.rm = TRUE)))
p2_23 <- predict(m2, newdata = e23)

# Variante avec ln(FDO) en modele lineaire : l'effet des effectifs est borne,
# mais le lien identite n'interdit pas une prevision negative (seul le lien log
# de la section 2.4 le garantit).
m2ln <- lm(vehicules_incendies ~ interpellations + log(fdo_mobilises), data = e05)
resume_lm(m2ln, "M2ln lineaire avec ln(FDO), 2005")
p2ln_23 <- predict(m2ln, newdata = e23)
cat(sprintf("M2ln : prevision minimale sur 2023 = %d\n", round(min(p2ln_23, na.rm = TRUE))))

# Variante en intensite : vehicules par interpellation selon le ratio
# interpellations / FDO (taux d'interpellation par agent engage)
d$interp_par_1000_fdo <- 1000 * d$interpellations / d$fdo_mobilises
m2p <- lm(vehicules_incendies ~ interpellations + fdo_mobilises + factor(evenement),
          data = d)
resume_lm(m2p, "M2p lineaire empile 2005+2023 avec effet fixe evenement")

# =============================================================================
# 2.3  Effet retard : I_t = a + b.V_t + c.V_{t-1}  (le dommage precede
#      l'interpellation), puis inversion pour estimer V_t
#      V_t = (I_t - a - c.V_{t-1}) / b
# =============================================================================
cat("\n================ 2.3  I_t = f(V_t, V_t-1) ================\n")
m3 <- lm(interpellations ~ vehicules_incendies + veh_lag1, data = e05)
resume_lm(m3, "M3  2005")
a <- coef(m3)[1]; b <- coef(m3)[2]; cc <- coef(m3)[3]
cat(sprintf("Racine de la recurrence inversee -c/b = %.2f (stable si |.| < 1)\n", -cc / b))

inverse_un_pas <- function(I, Vlag) pmax(0, (I - a - cc * Vlag) / b)

inverse_recursif <- function(I, V0) {
  # V0 : vehicules de la premiere nuit (observes) ; les suivants sont reconstruits
  V <- numeric(length(I)); V[1] <- V0
  for (t in 2:length(I)) V[t] <- max(0, (I[t] - a - cc * V[t - 1]) / b)
  V
}

# Controle 2023 : (i) un pas (V_{t-1} observe), (ii) recursif (seule la nuit 1 observee)
p3a_23 <- inverse_un_pas(e23$interpellations, e23$veh_lag1)
p3b_23 <- inverse_recursif(e23$interpellations, e23$vehicules_incendies[1])
p3b_23[1] <- NA   # la nuit 1 est une donnee, pas une prevision

# Verification dans l'echantillon 2005
p3a_05 <- inverse_un_pas(e05$interpellations, e05$veh_lag1)

# =============================================================================
# 2.4  GLM de comptage : quasi-Poisson, lien log
#      G1 : V ~ log(I)             G2 : V ~ log(I) + log(FDO)
#      Le lien log interdit les previsions negatives ; le quasi-Poisson
#      laisse la dispersion libre (comptages tres sur-disperses).
# =============================================================================
cat("\n================ 2.4  GLM quasi-Poisson, lien log ================\n")
resume_glm <- function(g, titre) {
  cat("\n---", titre, "---\n")
  print(round(coef(summary(g)), 4))
  cat(sprintf("n = %d | dispersion = %.1f | deviance expliquee = %.3f\n",
              length(residuals(g)), summary(g)$dispersion,
              1 - g$deviance / g$null.deviance))
}
g1 <- glm(vehicules_incendies ~ log(interpellations), family = quasipoisson(link = "log"),
          data = e05)
g2 <- glm(vehicules_incendies ~ log(interpellations) + log(fdo_mobilises),
          family = quasipoisson(link = "log"), data = e05)
resume_glm(g1, "G1  V ~ log(I), cale sur 2005")
resume_glm(g2, "G2  V ~ log(I) + log(FDO), cale sur 2005 (FDO en partie reconstruits)")
pg1_23 <- predict(g1, newdata = e23, type = "response")
pg2_23 <- predict(g2, newdata = e23, type = "response")

# Sensibilite de G2 a la serie d'effectifs 2005 (reconstituee a dire d'expert)
#  - central / bas / haut : fourchettes du dire d'expert
#  - senat : points sources du rapport du Senat n 84 imposes pour les bilans
#    des 7, 8 et 9 novembre (8 000, 8 000, 9 500) a la place de 11 500
sens_g2 <- function(fdo05, etiquette) {
  dd <- e05; dd$fdo_mobilises <- fdo05
  g <- glm(vehicules_incendies ~ log(interpellations) + log(fdo_mobilises),
           family = quasipoisson(link = "log"), data = dd)
  cs <- coef(summary(g))
  data.frame(serie_fdo_2005 = etiquette,
             coef_log_I = round(cs[2, 1], 2), coef_log_FDO = round(cs[3, 1], 2),
             p_log_FDO = round(cs[3, 4], 3),
             total_predit_2023 = round(sum(predict(g, newdata = e23, type = "response"))))
}
fdo_senat <- e05$fdo_mobilises
fdo_senat[e05$date_bilan %in% as.Date(c("2005-11-07", "2005-11-08"))] <- 8000
fdo_senat[e05$date_bilan == as.Date("2005-11-09")] <- 9500
sens <- rbind(sens_g2(e05$fdo_mobilises, "dire d'expert, central"),
              sens_g2(e05$fdo_bas,       "dire d'expert, bas"),
              sens_g2(e05$fdo_haut,      "dire d'expert, haut"),
              sens_g2(fdo_senat,         "central + points Senat n 84"))
cat("\nSensibilite de G2 a la serie d'effectifs 2005 :\n"); print(sens, row.names = FALSE)
write.csv(sens, "sorties/sensibilite_fdo_2005.csv", row.names = FALSE)

# Sens inverse : calage sur 2023 (effectifs sources pour les 9 nuits), controle sur 2005
g1r <- glm(vehicules_incendies ~ log(interpellations), family = quasipoisson(link = "log"),
           data = e23)
g2r <- glm(vehicules_incendies ~ log(interpellations) + log(fdo_mobilises),
           family = quasipoisson(link = "log"), data = e23)
resume_glm(g1r, "G1r V ~ log(I), cale sur 2023")
resume_glm(g2r, "G2r V ~ log(I) + log(FDO), cale sur 2023")
ctrl05 <- rbind(
  scores(e05$vehicules_incendies, predict(g1r, newdata = e05, type = "response"),
         "G1r (2023) -> 2005"),
  scores(e05$vehicules_incendies, predict(g2r, newdata = e05, type = "response"),
         "G2r (2023) -> 2005"))
cat("\nControle inverse sur 2005 :\n"); print(ctrl05, row.names = FALSE)
write.csv(ctrl05, "sorties/controle_inverse_2005.csv", row.names = FALSE)

# =============================================================================
# Tableau de controle
# =============================================================================
preds23 <- list(
  "M1  V~I (2005)"              = p1_23,
  "M1o V~I sans constante"      = p1o_23,
  "M1l log-log"                 = p1l_23,
  "M2  V~I+FDO (extrapolation)" = p2_23,
  "M2ln V~I+ln(FDO)"            = p2ln_23,
  "M3  inversion un pas"        = p3a_23,
  "M3  inversion recursive"     = p3b_23,
  "G1  quasi-Poisson V~log(I)"  = pg1_23,
  "G2  quasi-Poisson +log(FDO)" = pg2_23
)
refs23 <- list(
  "tableau journalier (5 954)"        = e23$vehicules_incendies,
  "borne basse France Assureurs"      = e23$vehicules_borne_basse,
  "borne haute 12 031 (non etayee)"   = e23$vehicules_borne_haute
)
ctrl <- do.call(rbind, lapply(names(refs23), function(r)
  do.call(rbind, lapply(names(preds23), function(m)
    cbind(reference = r, scores(refs23[[r]], preds23[[m]], m))))))
ctrl <- rbind(ctrl, cbind(reference = "2005 (in-sample)",
  scores(e05$vehicules_incendies, p3a_05, "M3  inversion un pas")))
cat("\n================ Controle des modeles sur 2023 ================\n")
print(ctrl, row.names = FALSE)
write.csv(ctrl, "sorties/controle_modeles.csv", row.names = FALSE)

# Intervalle de prevision a 95 % du total 2023 pour M1 (coefficients + bruit residuel)
X23 <- cbind(1, e23$interpellations); w <- colSums(X23)
se_tot <- sqrt(as.numeric(t(w) %*% vcov(m1) %*% w) + nrow(e23) * summary(m1)$sigma^2)
tq <- qt(0.975, m1$df.residual)
cat(sprintf("\nM1 : total 2023 predit = %d | intervalle de prevision 95 %% = [%d ; %d]\n",
            round(sum(p1_23)), round(sum(p1_23) - tq * se_tot), round(sum(p1_23) + tq * se_tot)))
cat(sprintf("References 2023 : tableau = %d | borne basse = %d | borne haute = %d\n",
            VEH_2023_TAB, VEH_2023_BAS, VEH_2023_HAUT))

pred23 <- data.frame(
  date_bilan = e23$date_bilan,
  interpellations = e23$interpellations,
  fdo_mobilises = e23$fdo_mobilises,
  vehicules_tableau = e23$vehicules_incendies,
  borne_basse = e23$vehicules_borne_basse,
  borne_haute = e23$vehicules_borne_haute,
  M1 = round(p1_23), M1o = round(p1o_23), M1l = round(p1l_23),
  M2 = round(p2_23), G1 = round(pg1_23), G2 = round(pg2_23), M3_un_pas = round(p3a_23), M3_recursif = round(p3b_23)
)
cat("\n================ Previsions 2023 nuit par nuit ================\n")
print(pred23, row.names = FALSE)
write.csv(pred23, "sorties/previsions_2023.csv", row.names = FALSE)

# =============================================================================
# Illustration 2026 : ce que la relation 2005 "predirait" a partir des
# interpellations journalieres connues. Ce n'est PAS une estimation :
# c'est une mesure de la rupture de regime.
# =============================================================================
cat("\n================ Illustration 2026 (rupture de regime) ================\n")
m26 <- read.csv("data/mouvement_2026.csv", na.strings = "NA")
i26 <- m26[m26$indicateur == "interpellations", c("date", "valeur")]
names(i26) <- c("date", "interpellations")
i26$veh_implicites_M1  <- round(predict(m1,  newdata = i26))
i26$veh_implicites_M1o <- round(predict(m1o, newdata = i26))
print(i26, row.names = FALSE)
write.csv(i26, "sorties/illustration_2026.csv", row.names = FALSE)

# =============================================================================
# Graphiques
# =============================================================================
png("sorties/fig1_vehicules_vs_interpellations.png", 1100, 700, res = 130)
plot(e05$interpellations, e05$vehicules_incendies, pch = 19, col = "#1f4e79",
     xlim = c(0, 1400), ylim = c(0, 2000),
     xlab = "Interpellations (par nuit)", ylab = "Vehicules incendies (par nuit)",
     main = "Vehicules incendies et interpellations : 2005 (calage) et 2023 (controle)")
points(e23$interpellations, e23$vehicules_incendies, pch = 17, col = "#c0392b")
abline(m1, col = "#1f4e79", lwd = 2)
abline(a = 0, b = coef(m1_23), col = "#c0392b", lty = 2)
legend("topleft", bty = "n",
       legend = c("2005 (par nuit)", "2023 (par nuit)", "Droite calee 2005", "Pente 2023"),
       pch = c(19, 17, NA, NA), lty = c(NA, NA, 1, 2), lwd = c(NA, NA, 2, 1),
       col = c("#1f4e79", "#c0392b", "#1f4e79", "#c0392b"))
dev.off()

png("sorties/fig2_controle_2023.png", 1100, 700, res = 130)
yl <- range(c(pred23$vehicules_tableau, pred23$borne_haute, pred23$M1,
              pred23$M3_recursif), na.rm = TRUE)
plot(pred23$date_bilan, pred23$vehicules_tableau, type = "n",
     ylim = yl, xlab = "Bilan au matin du", ylab = "Vehicules incendies",
     main = "Controle 2023 : fourchette de reference vs modeles cales sur 2005")
polygon(c(pred23$date_bilan, rev(pred23$date_bilan)),
        c(pred23$borne_basse, rev(pred23$borne_haute)), col = "#dddddd", border = NA)
lines(pred23$date_bilan, pred23$vehicules_tableau, type = "b", pch = 19, lwd = 2)
lines(pred23$date_bilan, pred23$M1, type = "b", pch = 1, col = "#1f4e79")
lines(pred23$date_bilan, pred23$M3_recursif, type = "b", pch = 4, col = "#c0392b", lty = 2)
legend("topright", bty = "n",
       legend = c("Tableau journalier (5 954)",
                  "Fourchette France Assureurs - 12 031", "M1 : V = f(I)",
                  "M3 inverse, recursif"),
       pch = c(19, 15, 1, 4), lty = c(1, NA, 1, 2),
       col = c("black", "#dddddd", "#1f4e79", "#c0392b"))
dev.off()

png("sorties/fig3_series_2005_2023.png", 1100, 800, res = 130)
par(mfrow = c(2, 1), mar = c(4, 4, 2.5, 1))
for (ev in list(e05, e23)) {
  plot(ev$date_bilan, ev$vehicules_incendies, type = "b", pch = 19, col = "#c0392b",
       xlab = "", ylab = "Par nuit", main = paste("Emeutes de", ev$evenement[1]),
       ylim = c(0, max(ev$vehicules_incendies, ev$interpellations, na.rm = TRUE)))
  lines(ev$date_bilan, ev$interpellations, type = "b", pch = 17, col = "#1f4e79")
  legend("topright", bty = "n", legend = c("Vehicules incendies", "Interpellations"),
         pch = c(19, 17), col = c("#c0392b", "#1f4e79"))
}
dev.off()

cat("\nTermine. Sorties ecrites dans sorties/\n")
