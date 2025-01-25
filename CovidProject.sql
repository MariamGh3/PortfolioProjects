SELECT * 
FROM coviddeaths;

/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM coviddeaths
order by location, date;


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, total_deaths*100/total_cases AS DeathPercentage
FROM coviddeaths
WHERE location = 'United Kingdom'
order by location, date;


SELECT location, avg(total_deaths*100/total_cases) AS DeathPercentage
FROM coviddeaths
group by location
order by location;

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

SELECT location, date, population, total_cases, total_deaths, total_cases*100/population AS TotalCasesPercentage
FROM coviddeaths
WHERE location = 'United Kingdom'
order by location, date;

-- Looking at countries with highest infection rates compared to population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX(total_cases*100/population) AS InfectionRate
FROM coviddeaths
GROUP BY location, population
ORDER BY InfectionRate DESC
LIMIT 10;

-- Looking at countries with highest death rates compared to population

SELECT location, 
       MAX(CAST(total_deaths AS SIGNED)) AS TotalDeathCount
FROM coviddeaths
WHERE continent != ''
GROUP BY location
ORDER BY TotalDeathCount DESC
LIMIT 10;



SELECT location, 
       MAX(CAST(total_deaths AS SIGNED)) AS TotalDeathCount
FROM coviddeaths
WHERE continent = ''
GROUP BY location
ORDER BY TotalDeathCount DESC;


-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

SELECT continent, MAX(CAST(total_deaths AS SIGNED)) AS TotalDeathCount
FROM coviddeaths
WHERE continent != ''
GROUP BY continent
ORDER BY TotalDeathCount DESC;


-- Global numbers

SELECT date, SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_death, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
FROM coviddeaths
WHERE continent !=''
GROUP BY DATE
ORDER BY date;



-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations)OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM coviddeaths dea
JOIN covidvaccinations vac
ON dea.location=vac.location
and dea.date=vac.date
WHERE dea.continent !=''
ORDER BY dea.location, dea.date;


-- Using CTE to perform Calculation on Partition By in previous query

WITH VaccinationCTE AS (
    SELECT dea.continent, 
           dea.location, 
           dea.date, 
           dea.population, 
           vac.new_vaccinations, 
           SUM(vac.new_vaccinations) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
    FROM coviddeaths dea
    JOIN covidvaccinations vac ON dea.location = vac.location AND dea.date = vac.date
    WHERE dea.continent != ''
)
SELECT *, RollingPeopleVaccinated/population*100 AS percentageofVac
FROM VaccinationCTE
ORDER BY location, date;



-- Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations)OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM coviddeaths dea
JOIN covidvaccinations vac
ON dea.location=vac.location
and dea.date=vac.date
WHERE dea.continent !=''
ORDER BY dea.location, dea.date;



SELECT *
FROM PercentPopulationVaccinated;










