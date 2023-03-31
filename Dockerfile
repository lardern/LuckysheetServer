FROM openjdk:11
ADD luckysheet/target/web-lockysheet-postgres.jar /home/java/web-lockysheet-postgres.jar
EXPOSE 8080
CMD ["java","-jar","/home/java/web-lockysheet-postgres.jar"]
