/*

Queries used for Tableau Project - Overview of COVID-19 Data

*/


-- 1. Total Cases, Total Deaths, and Death Percentage by Continent

-- This query calculates the total cases, total deaths, and death percentage for each continent, 
-- excluding locations where the continent is null. The death percentage is calculated as (Total Deaths / Total Cases) * 100.
Select SUM(new_cases) as total_cases, 
       SUM(cast(new_deaths as int)) as total_deaths, 
       SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From SQLProject..CovidDeaths
where continent is not null 
-- Order the results by total cases and total deaths
order by 1, 2


-- 2. Total Deaths by Location (Excluding certain locations)

-- This query calculates the total number of deaths for each location excluding 'World', 'European Union', 
-- and 'International'. Locations with null continent values are filtered out.
Select location, 
       SUM(cast(new_deaths as int)) as TotalDeathCount
From SQLProject..CovidDeaths
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
-- Order by the total number of deaths, from highest to lowest
order by TotalDeathCount desc


-- 3. Highest Infection Count and Percent Population Infected by Location

-- This query calculates the highest number of cases recorded and the percentage of the population infected 
-- (using the formula: (Total Cases / Population) * 100) for each location.
Select Location, Population, 
       MAX(total_cases) as HighestInfectionCount,  
       Max((total_cases/population))*100 as PercentPopulationInfected
From SQLProject..CovidDeaths
Group by Location, Population
-- Order by percentage of population infected in descending order
order by PercentPopulationInfected desc


-- 4. Highest Infection Count and Percent Population Infected by Location and Date

-- This query is similar to the previous one, but it breaks down the data by both location and date. 
-- It calculates the highest number of cases recorded and the infection percentage for each location on each date.
Select Location, Population, date, 
       MAX(total_cases) as HighestInfectionCount,  
       Max((total_cases/population))*100 as PercentPopulationInfected
From SQLProject..CovidDeaths
Group by Location, Population, date
-- Order by percentage of population infected in descending order
order by PercentPopulationInfected desc


-- 5. Total Cases, Total Deaths, and Population by Location and Date

-- This query shows the total number of cases, deaths, and population for each location by date.
-- This allows us to analyze trends over time for each location.
Select Location, date, population, total_cases, total_deaths
From SQLProject..CovidDeaths
where continent is not null 
-- Order by location and date
order by 1, 2


-- 6. Rolling Vaccination Numbers and Percent Vaccinated by Location and Date

-- This query calculates the rolling total of vaccinations for each location and calculates the percentage of the population vaccinated.
-- The rolling total is computed using the SUM function with a windowed partition by location and ordered by date.
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
    Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
           SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
    From SQLProject..CovidDeaths dea
    Join SQLProject..CovidVaccinations vac
        On dea.location = vac.location
        and dea.date = vac.date
    where dea.continent is not null 
)
-- Calculate the percentage of people vaccinated by dividing the rolling vaccinated number by the population
Select *, 
       (RollingPeopleVaccinated/Population)*100 as PercentPeopleVaccinated
From PopvsVac


-- 7. Highest Infection Count and Percent Population Infected by Location, Population, and Date

-- This query is a variation of query 4 but explicitly focuses on calculating the highest infection count 
-- and percent population infected for each location, population, and date.
Select Location, Population, date, 
       MAX(total_cases) as HighestInfectionCount,  
       Max((total_cases/population))*100 as PercentPopulationInfected
From SQLProject..CovidDeaths
Group by Location, Population, date
-- Order by percentage of population infected in descending order
order by PercentPopulationInfected desc
