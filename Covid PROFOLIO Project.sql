SELECT *
FROM ProtfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 3,4

SELECT * 
FROM ProtfolioProject..CovidVaccinations
ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
from ProtfolioProject..CovidDeaths
ORDER BY 1,2

-- looking at total cases vs total deaths
-- shows likelihood of dying if you have covid in your country 
SELECT location, date, total_cases, total_deaths, population, (total_deaths/total_cases)*100 AS percentage_of_deaths
from ProtfolioProject..CovidDeaths
WHERE location like '%china%'
ORDER BY 1,2

-- looking at total cases vs population
SELECT location, date, total_cases, population, (total_cases/population)*100 AS percentage_of_cases
from ProtfolioProject..CovidDeaths
WHERE location like '%china%'
ORDER BY 1,2

-- looking at courtries with higheset infections rate compared to populaction 
SELECT location, MAX(total_cases)AS HighestInfectionCount, 
population, MAX(total_cases/population)*100 AS MaxPercentagePopulactionInfected
from ProtfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY MaxPercentagePopulactionInfected DESC


-- showing courtries with higheset death count per populaction 
SELECT location, MAX(CAST(total_deaths AS int))AS HighestDeathCount
FROM ProtfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY HighestDeathCount DESC

-- let's break things down by continent
SELECT continent, MAX(CAST(total_deaths AS int))AS HighestDeathCount
FROM ProtfolioProject..CovidDeaths
where continent is not null
GROUP BY continent
ORDER BY HighestDeathCount DESC

-- showing continents with the hightest count per population
SELECT continent,total_cases, population,(((total_cases)/population)*100) AS PercentagePopulactionInfected
FROM ProtfolioProject..CovidDeaths
where continent is not null
GROUP BY continent
ORDER BY PercentagePopulactionInfected DESC

-- global numbers
-- total cases by date
SELECT date, sum(new_cases)as total_cases, SUM(CAST(new_deaths AS INT)) as total_deaths, 
(SUM(CAST(new_deaths AS INT)))/(sum(new_cases))*100 AS percentage_of_deaths
from ProtfolioProject..CovidDeaths
WHERE continent is not null
group by date
ORDER BY 1,2

-- total death of the world
SELECT sum(new_cases)as total_cases, SUM(CAST(new_deaths AS INT)) as total_deaths, 
(SUM(CAST(new_deaths AS INT)))/(sum(new_cases))*100 AS percentage_of_deaths
from ProtfolioProject..CovidDeaths
WHERE continent is not null
--group by date
ORDER BY 1,2

SELECT *
FROM ProtfolioProject..CovidVaccinations

--looking at total populasaion vs vaccinations 
-- use common table expression (CTE).
with PopvsVac (Continent,Location, Date,Population,New_Vaccinations,RollingPeopleVaccinated)
as 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	    SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION by dea.location order by dea.location, dea.date)
		AS RollingPeopleVaccinated
		--,(RollingPeopleVaccinated/population)*100
FROM ProtfolioProject..CovidDeaths  dea
	JOIN ProtfolioProject..CovidVaccinations vac
	ON dea.location =vac.location 
	AND dea.date=vac.date
WHERE dea.continent is not null
--order by 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac

-- GET RID OF DATE

with PopvsVac (Continent,Location, Population,New_Vaccinations,RollingPeopleVaccinated)
as 
(
SELECT dea.continent, dea.location, dea.population, vac.new_vaccinations, 
	    SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION by dea.location order by dea.location, dea.date)
		AS RollingPeopleVaccinated
		--,(RollingPeopleVaccinated/population)*100
FROM ProtfolioProject..CovidDeaths  dea
	JOIN ProtfolioProject..CovidVaccinations vac
	ON dea.location =vac.location 
	AND dea.date=vac.date
WHERE dea.continent is not null
--order by 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac


-- TEMP TABLE
DROP TABLE IF EXISTS #RarioPopulactionVaccinated
CREATE TABLE #RarioPopulactionVaccinated
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime, 
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #RarioPopulactionVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	    SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION by dea.location order by dea.location, dea.date)
		AS RollingPeopleVaccinated
		--,(RollingPeopleVaccinated/population)*100
FROM ProtfolioProject..CovidDeaths  dea
	JOIN ProtfolioProject..CovidVaccinations vac
	ON dea.location =vac.location 
	AND dea.date=vac.date
WHERE dea.continent is not null
--order by 2,3

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #RarioPopulactionVaccinated


-- CREATE VIEW TO STORE data for later visualization
CREATE VIEW #RarioPopulactionVaccinated AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	    SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION by dea.location order by dea.location, dea.date)
		AS RollingPeopleVaccinated
		--,(RollingPeopleVaccinated/population)*100
FROM ProtfolioProject..CovidDeaths  dea
	JOIN ProtfolioProject..CovidVaccinations vac
	ON dea.location =vac.location 
	AND dea.date=vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

