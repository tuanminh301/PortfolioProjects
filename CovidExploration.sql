/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

SELECT * 
FROM PortfolioProject2..CovidDeaths$ 
WHERE continent IS NOT NULL
ORDER BY 3,4

SELECT * 
FROM PortfolioProject2..CovidVaccinations$
ORDER BY 3,4

-- Select Data that we are going to start with 

SELECT location, date, total_cases, new_cases, total_deaths, population 
FROM PortfolioProject2..CovidDeaths$ 
ORDER BY 1,2 

-- Total Cases vs Total Deaths
-- Show the likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject2..CovidDeaths$ 
WHERE location LIKE '%Vietnam%' AND continent IS NOT NULL
ORDER BY 1,2  

-- Total Cases vs Population 
-- Show what percentage of population infected with covid

SELECT location, date, total_cases, population, (total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject2..CovidDeaths$ 
ORDER BY 1,2 

-- Looking at Countries with highest Infection Rate compared to Population 

SELECT location, MAX(total_cases) AS HighestInfectionCount, population, MAX((total_cases/population)*100) AS PercentPopulationInfected
FROM PortfolioProject2..CovidDeaths$ 
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY  PercentPopulationInfected DESC;

-- Showing the Countries with the highest Death Counts 

SELECT location, MAX(CONVERT(INT, total_deaths)) AS TotalDeathCount
FROM PortfolioProject2..CovidDeaths$ 
WHERE continent IS NOT NULL
GROUP BY location 
ORDER BY TotalDeathCount DESC

-- BREAKING THINGS DOWN BY CONTINENT

-- Showing continents with the highest death count per population

SELECT continent, MAX(CONVERT(INT, total_deaths)) AS TotalDeathCount
FROM PortfolioProject2..CovidDeaths$ 
WHERE continent IS NOT NULL
GROUP BY continent 
ORDER BY TotalDeathCount DESC 

-- Global numbers 

SELECT  date, SUM(new_cases) AS TotalCases, SUM(CONVERT(INT, new_deaths)) AS TotalDeaths, SUM(CONVERT(INT, new_deaths))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject2..CovidDeaths$  
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2   

-- Total Population vs Total Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
FROM PortfolioProject2..CovidDeaths$ dea
JOIN PortfolioProject2..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

-- Using CTE to perform Calculation on Partition By in previous query

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
FROM PortfolioProject2..CovidDeaths$ dea
JOIN PortfolioProject2..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
-- ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac

-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
FROM PortfolioProject2..CovidDeaths$ dea
JOIN PortfolioProject2..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
-- WHERE dea.continent IS NOT NULL
-- ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
FROM PortfolioProject2..CovidDeaths$ dea
JOIN PortfolioProject2..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
