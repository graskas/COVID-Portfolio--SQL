/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 3,4



--Select the data we are going to be using

SELECT location,date,total_cases,new_cases,total_deaths,population
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1,2


--Total Cases Verus Total Deaths
--Shows the likelihood of dying if you contract covid in Ghana

SELECT location,date,total_cases,total_deaths, (total_deaths/ total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%ghana%' and continent is not null
ORDER BY 1,2



--Total Cases Versus Population
--Shows what percentage of pouplation has COVID

SELECT location,date,population,total_cases, (total_cases/ population)*100 as TotalCasesPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%ghana%'and continent is not null
ORDER BY 1,2



--Countries with Highest Infection Rate Compared to Population

SELECT location,population,MAX(total_cases) as HighestInfectionCount, ((MAX(total_cases))/ population)*100 as PercentageofPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location,population
ORDER BY 4 DESC



--Countries with the Highest Death Count per Population

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC


--BREAKING THINGS DOWN BY CONTINENT


--Showing Continents with the Highest Death Count per Population

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC



--GLOBAL NUMBERS

SELECT SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/ SUM(new_cases) *100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location like '%ghana%' 
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2


--Total Population vs Vaccinations

-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population,New_Vaccinations, RollingPeopleVaccinated)
as 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, |(RollingPeopleVaccinated/ population) *100
FROM PortfolioProject..CovidDeaths as dea
JOIN PortfolioProject..CovidVaccination as vac
    ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3 
)


SELECT *, (RollingPeopleVaccinated/ Population)*100
FROM PopvsVac



--OR Using Temp Table to perform Calculation on Partition By in previous query

Drop Table if exists #PercentPopulationVaccinated 
 CREATE TABLE #PercentPopulationVaccinated
 (
 continent nvarchar(255),
 location nvarchar(255),
 Date datetime,
 Population numeric,
 New_vaccinations numeric,
 RollingPeopleVaccinated numeric
 )

 INSERT INTO #PercentPopulationVaccinated
 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, |(RollingPeopleVaccinated/ population) *100
FROM PortfolioProject..CovidDeaths as dea
JOIN PortfolioProject..CovidVaccination as vac
    ON dea.location = vac.location
	and dea.date = vac.date
--WHERE dea.continent is not null
--ORDER BY 2,3 

SELECT *, (RollingPeopleVaccinated/ Population)*100
FROM #PercentPopulationVaccinated



--Creating View to store data for later visualisation

Create View PercentPopulationVaccinated as 
 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, |(RollingPeopleVaccinated/ population) *100
FROM PortfolioProject..CovidDeaths as dea
JOIN PortfolioProject..CovidVaccination as vac
    ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3 


SELECT *
FROM PercentPopulationVaccinated 
