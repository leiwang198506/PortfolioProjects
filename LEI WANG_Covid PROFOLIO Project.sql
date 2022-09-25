-- Looking At The Data 
SELECT *
FROM PortfolioProject_Lei..CovidDeaths$
ORDER BY 3,4

SELECT *
FROM PortfolioProject_Lei..CovidVaccinations$
ORDER BY 3,4

SELECT location, date, population, total_cases, new_cases, total_deaths
FROM PortfolioProject_Lei..CovidDeaths$
ORDER BY 1,2

select location, continent, date, population, total_cases, new_cases, total_deaths
FROM PortfolioProject_Lei..CovidDeaths$
ORDER BY 1,2

-- Looking at total cases vs total deaths in Canada
SELECT location, date, population, total_cases, total_deaths, ((total_deaths/total_cases)*100) AS PercentageDeath
FROM PortfolioProject_Lei..CovidDeaths$
WHERE location LIKE '%canada%'
ORDER BY 1,2

-- Looking at total cases vs population in Canada
SELECT location, date, population, total_cases,(total_cases/population)*100 AS PercentageInfected
FROM PortfolioProject_Lei..CovidDeaths$
WHERE location LIKE '%canada%'
ORDER BY 1,2

-- Looking at courtries with higheset infections rate compared to population 
SELECT location, population, (MAX(total_cases))AS HighestInfectionCount, 
MAX((total_cases/population)*100) AS HighestPercentageInfected
FROM PortfolioProject_Lei..CovidDeaths$
GROUP BY location,population
ORDER BY HighestPercentageInfected DESC 

-- Showing courtries with higheset death count 
SELECT location, (MAX(CAST(total_deaths AS INT))) AS TotalDeathCount --total_deaths is nvarchar（255）
FROM PortfolioProject_Lei..CovidDeaths$ 
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Looking at continent's total death count
SELECT continent, (MAX(CAST(total_deaths AS INT))) AS TotalDeathCount --total_deaths is nvarchar（255）
FROM PortfolioProject_Lei..CovidDeaths$ 
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

--Data is not correct, North Amerca only includeds United States, so I changed to location. 
SELECT location, (MAX(CAST(total_deaths AS INT))) AS TotalDeathCount --total_deaths is nvarchar（255）
FROM PortfolioProject_Lei..CovidDeaths$ 
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Looking at total cases by date globally
SELECT date, sum(new_cases)as total_cases, SUM(CAST(new_deaths AS INT)) as total_deaths, --sum of new cases=total cases
(SUM(CAST(new_deaths AS INT)))/(sum(new_cases))*100 AS percentage_of_deaths
FROM PortfolioProject_Lei..CovidDeaths$ 
WHERE continent is not null
group by date
ORDER BY 1,2

-- Looking at the total death of the world
SELECT sum(new_cases)as total_cases, SUM(CAST(new_deaths AS INT)) as total_deaths, 
(SUM(CAST(new_deaths AS INT)))/(sum(new_cases))*100 AS percentage_of_deaths
FROM PortfolioProject_Lei..CovidDeaths$ 
WHERE continent is not null
--group by date
ORDER BY 1,2

--Looking at Vacccination table too
SELECT *
FROM PortfolioProject_Lei..CovidVaccinations$

--Joining 2 tables
SELECT *
FROM PortfolioProject_Lei..CovidDeaths$ dea
JOIN PortfolioProject_Lei..CovidVaccinations$ vac
	ON dea.location=vac.location
	and dea.date=vac.date

--looking at total populasaion vs vaccinations 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM PortfolioProject_Lei..CovidDeaths$ dea
JOIN PortfolioProject_Lei..CovidVaccinations$ vac
	ON dea.location=vac.location
	and dea.date=vac.date
WHERE dea.continent is not null
ORDER BY 2,3

--Looking at rolling people vaccinated and using CTE and Temp Table
--Using common table expression (CTE)
WITH PopvsVac (continent, location,date, population, new_vaccinations,  RollingPeopleVaccinated)
AS 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	    SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION by dea.location order by dea.location, dea.date)
		AS RollingPeopleVaccinated-- I use CONVERT instead of CAST.
		--,(RollingPeopleVaccinated/population)*100-- creat a CTE or Temp Table so that I can use it right away
FROM PortfolioProject_Lei..CovidDeaths$ dea
	JOIN PortfolioProject_Lei..CovidVaccinations$ vac
	ON dea.location =vac.location 
	AND dea.date=vac.date
WHERE dea.continent is not null
--order by 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac

-- TEMP TABLE
DROP TABLE IF EXISTS #RatioPopulactionVaccinated
CREATE TABLE #RatioPopulactionVaccinated
	(Continent nvarchar(255),
	Location nvarchar(255),
	Date datetime, 
	Population numeric,
	New_Vaccinations numeric,
	RollingPeopleVaccinated numeric
	)
INSERT INTO #RatioPopulactionVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	    SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION by dea.location order by dea.location, dea.date)
		AS RollingPeopleVaccinated
FROM PortfolioProject_Lei..CovidDeaths$ dea
	JOIN PortfolioProject_Lei..CovidVaccinations$ vac
	ON dea.location =vac.location 
	AND dea.date=vac.date
--WHERE dea.continent is not null
--order by 2,3
SELECT *, (RollingPeopleVaccinated/population)*100 
FROM #RatioPopulactionVaccinated

-- Creating view to store data for later visualization 
CREATE VIEW RatioPopulactionVaccinated AS
SELECT dea.continent, 
		dea.location, 
		dea.date, 
		dea.population, 
		vac.new_vaccinations, 
	    SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION by dea.location order by dea.location, dea.date)
			AS RollingPeopleVaccinated
FROM PortfolioProject_Lei..CovidDeaths$ dea
	JOIN PortfolioProject_Lei..CovidVaccinations$ vac
	ON dea.location =vac.location 
	AND dea.date=vac.date
WHERE dea.continent is not null

SELECT *
FROM RatioPopulactionVaccinated

