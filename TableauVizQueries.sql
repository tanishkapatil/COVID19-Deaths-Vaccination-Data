--Queries for Tableau Vizualization

--Query 1: Total Cases, Total Deaths, Death Percentage
SELECT SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, ROUND(SUM(cast(new_deaths as int))/SUM(new_cases)*100,3) AS DeathPercentage
FROM PortfolioProjectCOVID..CovidDeaths
WHERE continent is NOT NULL
--GROUP BY date
ORDER BY 1,2;

--Query 2: Continent wise Death Count
SELECT Location, SUM(cast(new_deaths as INT)) AS TotalDeaths
FROM PortfolioProjectCOVID..CovidDeaths
WHERE continent is NULL
--Removing locations that are not continents
AND location NOT IN('European Union','World','International')
GROUP BY Location
ORDER BY TotalDeaths DESC;

--Query 3: Countries with Highest infection rate compared to Population
SELECT Location, Population, MAX(total_cases) AS HighestInfectionCount, ROUND(MAX(100*(total_cases/population)),3) AS COVIDPositivePopulation
FROM CovidDeaths
GROUP BY Location, Population, date
ORDER BY 4 DESC;

--Query 4: Time series of COVID positive population
SELECT Location, Population, date, MAX(total_cases) AS HighestInfectionCount, ROUND(MAX(100*(total_cases/population)),3) AS COVIDPositivePopulation
FROM CovidDeaths
GROUP BY Location, Population, date
ORDER BY 5 DESC;
