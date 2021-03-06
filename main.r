## ---- eval=FALSE, include=TRUE-------------------------------------------------------
## "Protocolo:
## 
##  1. Daniel Felipe Villa Rengifo
## 
##  2. Lenguaje: R
## 
##  3. Tema: MÉTODOS DE REMUESTREO Y VALIDACIÓN DE MODELOS: VALIDACIÓN CRUZADA Y BOOTSTRAP [Parte 3]
## 
##  4. Fuentes:
##     https://rpubs.com/rdelgado/405322
##     https://tereom.github.io/est-computacional-2018/bootstrap-en-r.html"


## ------------------------------------------------------------------------------------
# Guardamos los Outputs:
sink("OUTPUTS.txt")

# Cargamos los .RData:
#load("~/R/100DaysOfCode/Dia_95_19junio/.RData")


## ------------------------------------------------------------------------------------
# Cargamos la libreria
library(boot)
library(ggplot2)

# Vector donde se almacenarán los 10 test error estimados
k_cv.MSE <- rep(NA, 4)

for (i in 1:4) {
modelo <- glm(y ~ poly(x, i), data = datos)
# Especificamos los folds con el argumento k. Almacenamos en el vector los valores estándar del test error (delta[1]).
set.seed(20)
k_cv.MSE[i] <- cv.glm(data = datos, glmfit = modelo, K = 10)$delta[1]
}


# valores estándar del test error
print("# valores estándar del test error")
print(k_cv.MSE)

# Graficmos el modelo:
png(filename = "TestError.png")

ggplot(data = data.frame(polinomio = 1:4, k_cv.MSE = k_cv.MSE), 
       aes(x = polinomio, y = k_cv.MSE))+
  geom_point(color = "orangered2") +
  geom_path()+
  labs(title = "MSE ~ Grado del polinomio") +
  theme(plot.title = element_text(hjust = 0.5))

dev.off()

# Resultado:
"Hemos obtenido resultados muy similares al LOOCV en cuanto a la estimación del test error por cada grado de polinomio (siendo el grado 2 de nuevo, el mejor). En casos con un gran número de datos, k-fold cross validation supondría una ventaja al ser computacionalmente más rápido."


## ------------------------------------------------------------------------------------
# Creamos una semilla:
set.seed(1)

# Creamos una función
fun.boot <- function(data, index) {
  "Función que devuelve las estimaciones de los coeficientes del modelo. Con “index” se seleccionan las observaciones para la muestra bootstrap"
  modelo.glm <- glm(Direction ~ Lag2, data = data, family = "binomial", 
                    subset = index)
  return (coef(modelo.glm))
}

# Bootstrap con 1000 pseudomuestras
library(boot)
estimacion.boot <- boot(data = Weekly, statistic = fun.boot, R = 1000)

print("# Bootstrap con 1000 pseudomuestras")
print(estimacion.boot)


# Resultado:
"Si compararemos los estimadores del error estándar para cada coeficiente obtenidos mediante bootstrap con los que se obtiene mediante la fórmula del error estándar usada por el modelo glm(), podemos ver que obtenemos valores casi iguales"

print("estimadores del error estándar para cada coeficiente obtenidos mediante bootstrap")
print(summary(glm(Direction ~ Lag2, data = Weekly, family = "binomial"))$coef)

png(filename = "bootstrap1.png")

# Distribución bootstrap de Intercept
plot(estimacion.boot, index = 1)

dev.off()


png(filename = "bootstrap2.png")

# Distribución bootstrap de Lag2
plot(estimacion.boot, index = 2)

dev.off()

"También podemos obtener los intervalos de confianza para los coeficientes"

# Intervalo de confianza para Intercept
print("# Intervalo de confianza para Intercept")
boot.ci(boot.out = estimacion.boot, type = "norm", index = 1)

# Intervalo de confianza para Lag2
print("# Intervalo de confianza para Lag2")
boot.ci(boot.out = estimacion.boot, type = "norm", index = 2)
