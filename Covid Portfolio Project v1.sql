SELECT *
FROM [Covid Portfolio Project]..CovidDeaths
WHERE continent is not null
ORDER BY 3,4

--SELECT *
--FROM [Covid Portfolio Project]..CovidVaccinations
--ORDER BY 3,4

--Select Data that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM [Covid Portfolio Project]..CovidDeaths
WHERE continent is not null
ORDER BY 1, 2

--Total Cases vs Total Deaths
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
FROM [Covid Portfolio Project]..CovidDeaths
WHERE location LIKE '%states%'
and continent is not null
ORDER BY 1, 2

--Total Cases vs Population, % of population that contracted Covid
SELECT Location, date, population, total_cases, (total_cases/population) * 100 as ContractedCovid
FROM [Covid Portfolio Project]..CovidDeaths
WHERE location LIKE '%states%'
and continent is not null
ORDER BY 1, 2

--Countries with the highest infection rate compared to population
SELECT continent, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)) * 100 as PercentContractedCovid
FROM [Covid Portfolio Project]..CovidDeaths
WHERE continent is not null
--WHERE location LIKE '%states%'
GROUP BY continent, population
ORDER BY PercentContractedCovid DESC

--Countries with the Highest Death Count per Population
SELECT Location, MAX(CAST(Total_deaths as int)) as TotalDeathCount
FROM [Covid Portfolio Project]..CovidDeaths
WHERE continent is not null
GROUP BY Location
ORDER BY TotalDeathCount DESC

--Continents with the Highest Death Count per Population
SELECT location, MAX(CAST(Total_deaths as int)) as TotalDeathCount
FROM [Covid Portfolio Project]..CovidDeaths
WHERE continent is null
GROUP BY location
ORDER BY TotalDeathCount DESC

--Continents with the Highest Death Count per Population
SELECT continent, MAX(CAST(Total_deaths as int)) as TotalDeathCount
FROM [Covid Portfolio Project]..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC

--Global Number
SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM [Covid Portfolio Project]..CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1, 2

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM [Covid Portfolio Project]..CovidDeaths
WHERE continent is not null
--GROUP BY date
ORDER BY 1, 2

--Total Population vs Vaccination
WITH PopvsVac(Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint, vac.new_vaccinations)) 
	OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--	,( RollingPeopleVaccinated/population) *100
FROM [Covid Portfolio Project]..CovidDeaths dea
JOIN [Covid Portfolio Project]..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2, 3
)
SELECT *, (RollingPeopleVaccinated/Population) *100
FROM PopvsVac


--use CTE
WITH PopvsVac(Continent, Location, Date, Population, RollingPeopleVaccinated)



--temp table

DROP TABLE IF exists #PercentPopulationVaccinated
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
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint, vac.new_vaccinations)) 
	OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--	,( RollingPeopleVaccinated/population) *100
FROM [Covid Portfolio Project]..CovidDeaths dea
JOIN [Covid Portfolio Project]..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date 
--WHERE dea.continent is not null
--ORDER BY 2, 3
SELECT *, (RollingPeopleVaccinated/Population) *100
FROM #PercentPopulationVaccinated

--Creating View to Store Data for Visualization

CREATE VIEW PercentPopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint, vac.new_vaccinations)) 
	OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--	,( RollingPeopleVaccinated/population) *100
FROM [Covid Portfolio Project]..CovidDeaths dea
JOIN [Covid Portfolio Project]..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date 
WHERE dea.continent is not null
--ORDER BY 2, 3

SELECT *
FROM PercentPopulationVaccinated

