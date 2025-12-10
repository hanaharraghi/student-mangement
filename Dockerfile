# Étape 1 — Construction du JAR avec Maven
FROM maven:3.9.6-eclipse-temurin-17 AS build
WORKDIR /app

# Copier tout le projet
COPY . .

# Compiler et générer le .jar
RUN mvn clean package -DskipTests


# Étape 2 — Image finale minimale
FROM eclipse-temurin:17-jdk
WORKDIR /app

# Copier le .jar depuis l’étape build
COPY --from=build /app/target/*.jar app.jar

# Port exposé (doit correspondre à ton application)
EXPOSE 8089

# Commande de démarrage
ENTRYPOINT ["java", "-jar", "app.jar"]
