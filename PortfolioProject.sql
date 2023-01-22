SELECT * 
FROM CovidDeaths$

-- Probability in terms of percentage of Dying if infected with covid!
SELECT location, date, total_cases, total_deaths, ((total_deaths/total_cases)*100) AS DeathPercentage
FROM CovidDeaths$
WHERE location LIKE '%states%'
ORDER BY 1,2

--Percentage of population that got covid
SELECT location, date, total_cases, population, ((total_cases/population)*100) AS PercentPopulationInfected
FROM CovidDeaths$
WHERE location LIKE '%states%'
ORDER BY 1,2

--Countries with highest Infection rate compared to Population
SELECT location, MAX(total_cases) AS HighestInfectionCount, population, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM CovidDeaths$
--WHERE location LIKE '%states%'
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

--Countries with Highest Death Count per population
SELECT location, MAX(CAST(total_deaths AS INT)) AS HighestDeathCount
FROM CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY HighestDeathCount DESC

--Lets break things down by continent
--OR
--Showing the continents with the highest death count
SELECT continent, MAX(CAST(total_deaths AS INT)) AS HighestDeathCount,
FROM CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY HighestDeathCount DESC

--GLOBAL NUMBERS
SELECT date, SUM(new_cases) AS TotalNewCases, SUM(cast(new_deaths AS INT)) AS TotalNewDeaths, SUM(cast(new_deaths AS INT))/(SUM(new_cases))*100 AS DeathPercentage
FROM CovidDeaths$
WHERE continent IS NOT NULL 
GROUP BY date
ORDER BY 1,2

--tHE OVERALL TOTAL CASES
SELECT SUM(new_cases) AS TotalNewCases, SUM(cast(new_deaths AS INT)) AS TotalNewDeaths, SUM(cast(new_deaths AS INT))/(SUM(new_cases))*100 AS DeathPercentage
FROM CovidDeaths$
WHERE continent IS NOT NULL 
ORDER BY 1,2
------------------------------------------------------------

--COVID VACCINATIONS 

SELECT * 
FROM CovidDeaths$ dea
JOIN CovidVaccinations$ vac
ON dea.location = vac.location AND dea.date = vac.date

--Looking at total population vs vaccination

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopeleVaccinated
FROM CovidDeaths$ dea
JOIN CovidVaccinations$ vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL AND vac.new_vaccinations IS NOT NULL 
--AND dea.location LIKE '%INDIA%'
ORDER BY 2,3


--Use CTE

WITH PopvVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopeleVaccinated
FROM CovidDeaths$ dea
JOIN CovidVaccinations$ vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL AND vac.new_vaccinations IS NOT NULL 
AND dea.location LIKE '%INDIA%'
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100 AS PercentagePopulationVaccinated
FROM PopvVac




