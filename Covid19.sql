SELECT*
FROM PoforlioProject..CovidDeaths$
-- WHERE continent IS NOT NULL
ORDER BY 3,4

SELECT*
FROM PoforlioProject..CovidVaccinations$
ORDER BY 3,4

 --SELECT DATA that we're going to using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PoforlioProject..CovidDeaths$
WHERE continent IS NOT NULL
ORDER BY 1,2

-- Looking at Total Cases with Total Deaths.
-- Show the likelihood dying if you contract covid in United States
SELECT location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 AS DeathPercentage
FROM PoforlioProject..CovidDeaths$
WHERE location LIKE '%states%'
ORDER BY 1,2

-- Looking Total Cases with population
-- Show the percenteage of population get covid

SELECT location, date, population,total_cases, (total_cases/population)*100 AS PopulationPercentage
FROM PoforlioProject..CovidDeaths$
WHERE location LIKE '%states%'
ORDER BY 1,2


-- Looking at country with highest Infection Rate  to Pouplation
SELECT location, population, MAX((total_cases/population))*100 AS InfectionPercentage
FROM PoforlioProject..CovidDeaths$
--WHERE location LIKE '%states%'
GROUP BY location, population
ORDER BY InfectionPercentage DESC

-- SHOWING THE COUNTRY WITH THE HIGHEST DEATH COUNT PER Populcation

SELECT location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM PoforlioProject..CovidDeaths$
--WHERE location LIKE '%states%'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC


-- Let's Breakthings Down By Contitent.

SELECT location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM PoforlioProject..CovidDeaths$
--WHERE location LIKE '%states%'
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

SELECT continent, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM PoforlioProject..CovidDeaths$
--WHERE location LIKE '%states%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


-- Showing the Cotinent have highest death count per population 

SELECT continent,  MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM PoforlioProject..CovidDeaths$
--WHERE location LIKE '%states%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


-- Global Numbers
-- Showing the percentage death per date| The total new case with Total new death across the world 

SELECT date, SUM(new_cases) As total_new_case, SUM(CAST(new_deaths AS INT)) AS total_new_death,
SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS  DeathPercentage
FROM PoforlioProject..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1, 2

-- Showing the percentage death| The total_new case with total_new_death

SELECT SUM(new_cases) As total_new_case, SUM(CAST(new_deaths AS INT)) AS total_new_death,
SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS  DeathPercentage
FROM PoforlioProject..CovidDeaths$
WHERE continent IS NOT NULL
-- GROUP BY date
ORDER BY 1, 2


-- Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population,
vac.new_vaccinations
FROM PoforlioProject..CovidDeaths$ AS dea
JOIN PoforlioProject..CovidVaccinations$ AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3


-- How Each Country get their vaccination in progress|Rolling Count

SELECT dea.continent, dea.location, dea.date, dea.population,
vac.new_vaccinations, SUM(CAST(new_vaccinations AS INT)) OVER(PARTITION BY dea.Location)
FROM PoforlioProject..CovidDeaths$ AS dea
JOIN PoforlioProject..CovidVaccinations$ AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

SELECT dea.continent, dea.location, dea.date, dea.population,
vac.new_vaccinations, 
SUM(CONVERT(INT,new_vaccinations )) OVER(PARTITION BY dea.Location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PoforlioProject..CovidDeaths$ AS dea
JOIN PoforlioProject..CovidVaccinations$ AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

-- USE CTE

WITH PopvsVAC(continent, Location, Date, Population,New_Vaccinations, RollingPeopleVaccinated) AS
(
SELECT dea.continent, dea.location, dea.date, dea.population,
vac.new_vaccinations, 
SUM(CONVERT(INT,new_vaccinations )) OVER(PARTITION BY dea.Location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PoforlioProject..CovidDeaths$ AS dea
JOIN PoforlioProject..CovidVaccinations$ AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

)

SELECT *,(RollingPeopleVaccinated/Population)*100 As #PecentagePopulationVaccinated
FROM  PopvsVAC


-- TEMP Table 

DROP TABLE if exists #PecentagePopulationVaccinated
CREATE TABLE #PecentagePopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PecentagePopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population,
vac.new_vaccinations, 
SUM(CONVERT(INT,new_vaccinations )) OVER(PARTITION BY dea.Location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PoforlioProject..CovidDeaths$ AS dea
JOIN PoforlioProject..CovidVaccinations$ AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL

SELECT *,(RollingPeopleVaccinated/Population)*100 As #PecentagePopulationVaccinated
FROM  #PecentagePopulationVaccinated



-- Creating View to Store Data For Visualization 

CREATE VIEW PecentagePopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population,
vac.new_vaccinations, 
SUM(CONVERT(INT,new_vaccinations )) OVER(PARTITION BY dea.Location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PoforlioProject..CovidDeaths$ AS dea
JOIN PoforlioProject..CovidVaccinations$ AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--Order By 2, 3 


SELECT *
FROM PecentagePopulationVaccinated