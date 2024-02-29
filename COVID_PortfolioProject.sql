SELECT *
FROM PortfolioProject.dbo.Deaths
--WHERE continent IS NOT NULL
ORDER BY 2,3

--SELECT *
--FROM PortfolioProject.dbo.Vaccinations 
--ORDER BY 3,4

--Select data that we are going to use

SELECT location, date, total_cases, new_cases, total_deaths, population 
FROM PortfolioProject.dbo.Deaths
WHERE continent IS NOT NULL
ORDER BY 1,2

--Looking at the Total Cases vs Total Deaths based on country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject.dbo.Deaths
WHERE location LIKE '%vietnam%' AND continent IS NOT NULL
ORDER BY 1,2

-- Looking at Total Cases vs Population based on country 

SELECT location, date, total_cases, population, (total_cases/population)*100 AS CasePercentage
FROM PortfolioProject.dbo.Deaths
WHERE location LIKE '%vietnam%' AND continent IS NOT NULL
ORDER BY 1,2

--Looking at Countries with Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) as HighestInfectionCount
, MAX((total_cases/population))*100 AS InfectedPercentage
FROM PortfolioProject.dbo.Deaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY InfectedPercentage DESC

-- Looking at Countries with Highest DeathCount per Population

SELECT location, MAX(CAST(total_deaths AS int)) as TotalDeathCount
FROM PortfolioProject.dbo.Deaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

---- Breakdown by Continent

-- Showing Continent with the Highest Death Count per Population

--SELECT location, MAX(CAST(total_deaths AS int)) as TotalDeathCount
--FROM PortfolioProject.dbo.Deaths
--WHERE continent IS NULL
--GROUP BY location
--ORDER BY TotalDeathCount DESC

SELECT continent, MAX(CAST(total_deaths AS int)) as TotalDeathCount
FROM PortfolioProject.dbo.Deaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

--Global Numbers

SELECT SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, 
	SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject.dbo.Deaths
--WHERE location LIKE '%state%'
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1, 2

--Looking at Total Population vs Vaccinations

--Using CTE
WITH PopvsVac (continent, location, date, population, new_vacc, AccumulatedVaccinated)-- Must = the number of column called in SELECT statement
AS
(
SELECT death.continent, death.location, death.date, death.population, vaccine.new_vaccinations, 
	SUM(CONVERT(int, vaccine.new_vaccinations)) OVER (PARTITION BY death.location ORDER BY death.location, death.date) 
	AS AccumulatedVaccinated
FROM PortfolioProject.dbo.Deaths death
JOIN PortfolioProject.dbo.Vaccinations vaccine
	ON death.location = vaccine.location
	and death.date = vaccine.date
WHERE death.continent IS NOT NULL
--ORDER BY 2, 3
)

SELECT *, (AccumulatedVaccinated/Population)*100
FROM PopvsVac

--Temp Table
DROP Table IF exists #PopVac
CREATE TABLE #PopVac
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vacc numeric, 
AccumulatedVaccinated numeric
)

INSERT INTO #PopVac
SELECT death.continent, death.location, death.date, death.population, vaccine.new_vaccinations, 
	SUM(CONVERT(int, vaccine.new_vaccinations)) OVER (PARTITION BY death.location ORDER BY death.location, death.date) 
	AS AccumulatedVaccinated
FROM PortfolioProject.dbo.Deaths death
JOIN PortfolioProject.dbo.Vaccinations vaccine
	ON death.location = vaccine.location
	and death.date = vaccine.date
--WHERE death.continent IS NOT NULL
--ORDER BY 2, 3

SELECT *, (AccumulatedVaccinated/Population)*100
FROM #PopVac

--Creating View to store data for later visualizations

USE PortfolioProject;
GO

CREATE VIEW PercentPopulationVaccinated AS 
SELECT death.continent, death.location, death.date, death.population, vaccine.new_vaccinations, 
	SUM(CONVERT(int, vaccine.new_vaccinations)) OVER (PARTITION BY death.location ORDER BY death.location, death.date) 
	AS AccumulatedVaccinated
FROM PortfolioProject.dbo.Deaths death
JOIN PortfolioProject.dbo.Vaccinations vaccine
	ON death.location = vaccine.location
	and death.date = vaccine.date
WHERE death.continent IS NOT NULL
--ORDER BY 2, 3

SELECT *
FROM PercentPopulationVaccinated