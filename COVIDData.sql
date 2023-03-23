use PortfolioProjectCOVID;


select * from CovidDeaths order by 3,4; 

--Select Data to be used
SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
ORDER BY 1,2;

--Viewing the Total Cases vs Total Deaths
--Calculating likelihood of dying from COVID in India
SELECT Location, date, total_cases, total_deaths, ROUND((100*(total_deaths/total_cases)),3) AS DeathPercentages
FROM CovidDeaths
WHERE Location = 'India'
ORDER BY 1,2;

--Looking at Total Cases vs Population
--Calculating the total percentage of population that contracted COVID
SELECT Location, date, Population, total_cases, ROUND((100*(total_cases/population)),3) AS COVIDPositivePopulation
FROM CovidDeaths
WHERE Location = 'India'
ORDER BY 1,2;

--Countries with Highest infection rate compared to Population
SELECT Location, Population, MAX(total_cases) AS HighestInfectionCount, ROUND(MAX(100*(total_cases/population)),3) AS COVIDPositivePopulation
FROM CovidDeaths
GROUP BY Location, Population
ORDER BY 4 DESC;

--Countries with Highest Death Count per Population
--We cast total_deaths here to get more accurate data from varchar to INT
--#CAST() function converts a value (of any type) into a specified datatype.
SELECT Location, Population, MAX(cast(total_deaths AS int)) AS TotalDeathCount
FROM CovidDeaths
WHERE continent is NOT NULL
GROUP BY Location, Population
ORDER BY 3 DESC;


-- Looking at countries with Highest Infection Rate compared to population
SELECT Location, Population, MAX(total_cases) HighInfectionCount, MAX(ROUND((total_cases/population)*100,2)) AS HighInfectionRate
FROM CovidDeaths
GROUP BY Location, Population
ORDER BY 4 DESC;

-- Looking at countries with Highest Death Rate compared to population
SELECT Location, Population, MAX(cast(total_deaths as int)) HighDeathCount, MAX(ROUND((total_deaths/population)*100,2)) AS HighDeathRate
FROM CovidDeaths
WHERE Continent is not null
GROUP BY Location, Population
ORDER BY 3  DESC;

--Showing continent-wise Total Death Count
SELECT Continent, MAX(cast(total_deaths AS int)) AS TotalDeathCount
FROM CovidDeaths
WHERE continent is NOT NULL
GROUP BY Continent
ORDER BY 2 DESC;

--Global Numbers
SELECT date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE continent is NOT NULL
GROUP BY date
ORDER BY 1,2;

--Joining CovidDeath table with CovidVaccination table
SELECT * 
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON  dea.location = vac.location
AND dea.date = vac.date;

--Looking at Total Population vs Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON  dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3;

--Rolling count of vaccinated people
--Parition function: used to restart count for every location
--Order by: to order the sum by date and location every time
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as INT)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON  dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null and dea.Location = 'India'
ORDER BY 2,3;

--Number of People vaccinated in a country
--Here we need to find the max of the rollingpeoplevaccinated to find total number of people vaccinated
--but we can't just use the column like that
--we will be using a CTE - common table expression
--CTE needs to have same number of columns 
WITH PopVSVac(Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as INT)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
	FROM CovidDeaths dea
	JOIN CovidVaccinations vac
	ON	dea.location = vac.location
	AND dea.date = vac.date
	WHERE dea.continent is not null
	--ORDER BY 2,3
)
SELECT L


--Creating a temp table
--Need to specify data type of column names here
DROP TABLE IF EXISTS #PercentagePeopleVaccinated
CREATE TABLE #PercentagePeopleVaccinated
(
	Continent nvarchar(255),
	Location nvarchar(255),
	Date datetime,
	Population numeric,
	New_Vaccinations numeric,
	RollingPeopleVaccinated numeric
)
INSERT INTO #PercentagePeopleVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as INT)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
	FROM CovidDeaths dea
	JOIN CovidVaccinations vac
	ON	dea.location = vac.location
	AND dea.date = vac.date
	--WHERE dea.continent is not null
	--ORDER BY 2,3
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentagePeopleVaccinated

--Creating View to store data for Visualization
--View 1: Percentage of Population Vaccinated
CREATE VIEW PercentPeopleVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as INT)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
	FROM CovidDeaths dea
	JOIN CovidVaccinations vac
	ON	dea.location = vac.location
	AND dea.date = vac.date
	WHERE dea.continent is not null