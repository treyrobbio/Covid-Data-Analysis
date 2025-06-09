-- Total Cases vs Total Deaths
-- Shows probability of dying from covid in the US
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
FROM coviddeaths1
WHERE location = 'United States';


-- Total Cases vs Population
-- Shows the percentage of the US population that has covid 
SELECT location, date, total_cases, population, (total_cases/population)*100 as Infection_Percentage
FROM coviddeaths1
WHERE location = 'United States';


-- Countries and their Highest Infection/Population Rate
 
SELECT location, population, MAX(total_cases) as Highest_Infection_Count, MAX((total_cases/population))*100 
as Infection_Percentage
FROM coviddeaths1
GROUP BY location, population
ORDER BY Infection_Percentage DESC;


-- Countries with Highest Death Count per Population

SELECT location, MAX(cast(total_deaths as signed)) as TotalDeathCount
FROM coviddeaths1
WHERE continent IS NOT NULL AND continent != ''
GROUP BY location
ORDER BY TotalDeathCount DESC;


-- Breaking Things Down by Continent
-- Shows total death count for each continent

SELECT continent, MAX(cast(total_deaths as signed)) as TotalDeathCount
FROM coviddeaths1
WHERE continent != '' AND continent is not null 
GROUP BY continent
ORDER BY TotalDeathCount DESC;


-- Global Numbers

-- Shows total cases, total deaths, and percent of people who died from covid for each date in the data set
SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as signed)) as total_deaths, SUM(cast(new_deaths as signed))/SUM(new_Cases)*100 as DeathPercentage
FROM coviddeaths1
WHERE continent is not null AND continent != '' 
GROUP BY date
order by 1,2;

-- shows total cases, total deaths, and death percentage of covid for all dates in the data set
SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as signed)) as total_deaths, SUM(cast(new_deaths as signed))/SUM(new_Cases)*100 as DeathPercentage
FROM coviddeaths1
WHERE continent is not null AND continent != '';


-- Looking at percent of the world population that is vaccinated


-- base query
Select deaths.continent, deaths.location, deaths.date, deaths.population, vax.new_vaccinations
, SUM(CAST(vax.new_vaccinations as signed)) OVER (Partition by deaths.location ORDER BY deaths.location, deaths.date) as RollingPeopleVaccinated
From coviddeaths1 deaths
Join covidvax vax
	On deaths.location = vax.location
	and deaths.date = vax.date
where deaths.continent != '';

-- Using CTE to get percentages
With PopvsVax (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select deaths.continent, deaths.location, deaths.date, deaths.population, vax.new_vaccinations
, SUM(CAST(vax.new_vaccinations as signed)) OVER (Partition by deaths.location ORDER BY deaths.location, deaths.date) as RollingPeopleVaccinated
From coviddeaths1 deaths
Join covidvax vax
	On deaths.location = vax.location
	and deaths.date = vax.date
where deaths.continent != ''
)
SELECT *, (RollingPeopleVaccinated/population)*100 as percentVaccinated
FROM PopvsVax;

-- Using temp table to get percentages

DROP Table if exists PercentPopulationVaccinated;
CREATE TEMPORARY TABLE PercentPopulationVaccinated
(
Continent char(255),
Location char(255),
Date char(255),
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
);

Insert into PercentPopulationVaccinated
Select deaths.continent, deaths.location, deaths.date, deaths.population, vax.new_vaccinations
, SUM(CAST(vax.new_vaccinations as signed)) OVER (Partition by deaths.location ORDER BY deaths.location, deaths.date) as RollingPeopleVaccinated
From coviddeaths1 deaths
Join covidvax vax
	On deaths.location = vax.location
	and deaths.date = vax.date
where deaths.continent != '' AND new_vaccinations != '';

SELECT *, (RollingPeopleVaccinated/population)*100 as percentVaccinated
FROM PercentPopulationVaccinated;

-- Creating View for later data visualtion...
Create View PopulationVaccinated as
Select deaths.continent, deaths.location, deaths.date, deaths.population, vax.new_vaccinations
, SUM(CAST(vax.new_vaccinations as signed)) OVER (Partition by deaths.location ORDER BY deaths.location, deaths.date) as RollingPeopleVaccinated
From coviddeaths1 deaths
Join covidvax vax
	On deaths.location = vax.location
	and deaths.date = vax.date
where deaths.continent != ''
;

SELECT *, (RollingPeopleVaccinated/population)*100 as percentVaccinated
FROM PopulationVaccinated;